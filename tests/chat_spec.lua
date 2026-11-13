local Chat = require('copilot-chat.ui.chat')
local config = require('copilot-chat.config')
local constants = require('copilot-chat.constants')

describe('copilot-chat.ui.chat bounds', function()
  local chat

  local function parsing_available()
    local ok, parser = pcall(vim.treesitter.get_parser, chat.bufnr, 'markdown')
    if not ok or not parser then
      return false
    end
    return vim.treesitter.query.get('markdown', 'copilotchat') ~= nil
  end

  before_each(function()
    chat = Chat(vim.tbl_extend('force', config, {
      auto_fold = true,
      show_help = true,
      highlight_headers = true,
    }))
    chat:append('') -- creates the buffer
    chat.winnr = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(chat.winnr, chat.bufnr)
  end)

  after_each(function()
    chat.winnr = nil
    pcall(function()
      vim.cmd('enew')
    end)
    chat:delete()
  end)

  local function fill_with_tool_call()
    chat:add_message({ role = constants.ROLE.USER, content = '\nhello\n' })
    chat:add_message({
      role = constants.ROLE.ASSISTANT,
      content = '\nrunning\n',
      tool_calls = { { id = 'call_1', name = 'grep', arguments = '{"pattern":"x"}' } },
    })
    chat:add_message({ role = constants.ROLE.USER, content = '\n#grep:call_1\n\n' })
  end

  it('highlights the tool call line without going out of bounds', function()
    if not parsing_available() then
      return pending('markdown parser or copilotchat query not available')
    end

    fill_with_tool_call()

    assert.has_no.errors(function()
      chat:parse()
      chat:render()
    end)

    local ns = vim.api.nvim_create_namespace('copilot-chat-headers')
    local marks = vim.api.nvim_buf_get_extmarks(chat.bufnr, ns, 0, -1, { details = true })
    local highlighted
    for _, mark in ipairs(marks) do
      if mark[4].hl_group == 'CopilotChatAnnotationHeader' then
        highlighted = vim.api.nvim_buf_get_lines(chat.bufnr, mark[2], mark[2] + 1, false)[1]
      end
    end
    assert.equals('#grep:call_1', highlighted)
  end)

  it('keeps every section inside the buffer', function()
    if not parsing_available() then
      return pending('markdown parser or copilotchat query not available')
    end

    fill_with_tool_call()

    local count = vim.api.nvim_buf_line_count(chat.bufnr)
    for _, message in ipairs(chat:get_messages()) do
      assert.is_true(message.section.start_line >= 1)
      assert.is_true(message.section.end_line <= count)
      for _, block in ipairs(message.section.blocks) do
        assert.is_true(block.start_line >= 1)
        assert.is_true(block.end_line <= count)
      end
    end
  end)

  it('renders after removing and replacing the last message', function()
    if not parsing_available() then
      return pending('markdown parser or copilotchat query not available')
    end

    fill_with_tool_call()

    assert.has_no.errors(function()
      chat:remove_message(constants.ROLE.USER)
      chat:render()
    end)

    assert.has_no.errors(function()
      chat:add_message({ role = constants.ROLE.USER, content = '\nagain\n' })
      chat:add_message({ role = constants.ROLE.USER, content = '\nreplaced\n' }, true)
      chat:render()
    end)
  end)

  local function assert_no_past_eof_extmarks(bufnr)
    local count = vim.api.nvim_buf_line_count(bufnr)
    for _, ns_name in ipairs({ 'copilot-chat-headers', 'copilot-chat-help', 'copilot-chat-spinner' }) do
      local ns = vim.api.nvim_create_namespace(ns_name)
      local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })
      for _, mark in ipairs(marks) do
        if not mark[4].invalid then
          assert.is_true(
            mark[2] < count,
            string.format('extmark in %s at row %d >= line_count %d', ns_name, mark[2], count)
          )
        end
      end
    end
  end

  it('never leaves active extmarks past EOF between buffer edits and debounced render', function()
    if not parsing_available() then
      return pending('markdown parser or copilotchat query not available')
    end

    chat:add_message({ role = constants.ROLE.USER, content = '\nhello\n' })
    chat:parse()
    chat:render()
    assert_no_past_eof_extmarks(chat.bufnr)

    -- Replace last message so buffer has 6 lines (previously pushed help extmark to row 6 = lnum 7)
    chat:add_message({ role = constants.ROLE.USER, content = '\n1\n2\n3\n' }, true)
    assert_no_past_eof_extmarks(chat.bufnr)

    -- Re-render, then delete last line via normal! Gdd
    chat:parse()
    chat:render()
    vim.bo[chat.bufnr].modifiable = true
    vim.cmd('normal! Gdd')
    assert_no_past_eof_extmarks(chat.bufnr)

    -- Multi-message tool call removal before render
    chat:clear()
    assert_no_past_eof_extmarks(chat.bufnr)

    fill_with_tool_call()
    chat:parse()
    chat:render()
    chat:remove_message(constants.ROLE.USER)
    assert_no_past_eof_extmarks(chat.bufnr)
  end)

  it('preserves section header when header is on the last line of the buffer', function()
    if not parsing_available() then
      return pending('markdown parser or copilotchat query not available')
    end

    chat:add_message({ role = constants.ROLE.USER, content = '\nfirst\n' })
    chat:add_message({ role = constants.ROLE.USER, id = 'second-id', content = '' })

    -- Strip trailing empty lines after the second header so it sits on the very last line
    vim.bo[chat.bufnr].modifiable = true
    local lines = vim.api.nvim_buf_get_lines(chat.bufnr, 0, -1, false)
    while #lines > 1 and lines[#lines] == '' do
      table.remove(lines)
    end
    vim.api.nvim_buf_set_lines(chat.bufnr, 0, -1, false, lines)

    local header_row = #lines - 1
    local expected_header = lines[#lines]
    chat:parse()
    chat:render()

    local ns = vim.api.nvim_create_namespace('copilot-chat-headers')
    local marks = vim.api.nvim_buf_get_extmarks(chat.bufnr, ns, { header_row, 0 }, { header_row, -1 }, {})
    assert.equals(1, #marks)

    -- Replacing the body of that trailing section must not overwrite its header line
    chat:add_message({ role = constants.ROLE.USER, id = 'second-id', content = '\nbody\n' }, true)
    local after_lines = vim.api.nvim_buf_get_lines(chat.bufnr, 0, -1, false)
    assert.equals(expected_header, after_lines[header_row + 1])
  end)

  it('redraws without E315 ml_get error in a TUI window', function()
    if vim.fn.has('unix') ~= 1 then
      return pending('PTY redraw test requires unix')
    end

    local sock = vim.fn.tempname() .. '.sock'
    local job = vim.fn.jobstart({ vim.v.progpath, '--clean', '--listen', sock }, {
      pty = true,
      width = 80,
      height = 24,
    })

    local ok_cleanup, test_err = pcall(function()
      assert.is_true(vim.wait(3000, function()
        return vim.uv.fs_stat(sock) ~= nil
      end))

      local chan = vim.fn.sockconnect('pipe', sock, { rpc = true })
      assert.is_true(vim.wait(3000, function()
        return vim.rpcrequest(chan, 'nvim_get_vvar', 'vim_did_enter') == 1
      end))

      local errmsg = vim.rpcrequest(
        chan,
        'nvim_exec_lua',
        [[
          local cwd = ...
          vim.opt.runtimepath:append(cwd)
          for _, dep in ipairs(vim.fn.glob(cwd .. '/.dependencies/*', false, true)) do
            vim.opt.runtimepath:append(dep)
          end
          vim.cmd('runtime plugin/copilot-chat.lua')

          local Chat = require('copilot-chat.ui.chat')
          local cfg = require('copilot-chat.config')
          local c = Chat(vim.tbl_extend('force', cfg, {
            show_help = true,
            highlight_headers = true,
            show_folds = true,
            auto_fold = true,
          }))
          c:open(c.config)
          c:add_message({ role = 'user', content = '' })
          c:parse()
          c:render()
          vim.cmd('redraw!')

          -- Replace user section so buffer has 6 lines (would trigger E315: ml_get: Invalid lnum: 7)
          c:add_message({ role = 'user', content = '\n1\n2\n3\n' }, true)
          vim.cmd('redraw!')

          -- Re-render and delete tail line before next render
          c:parse()
          c:render()
          vim.bo[c.bufnr].modifiable = true
          vim.api.nvim_set_current_win(c.winnr)
          vim.cmd('normal! Gdd')
          vim.cmd('redraw!')

          return vim.v.errmsg
        ]],
        { vim.fn.getcwd() }
      )

      vim.fn.chanclose(chan)
      assert.equals('', errmsg)
    end)

    pcall(vim.fn.jobstop, job)
    pcall(vim.uv.fs_unlink, sock)
    if not ok_cleanup then
      error(test_err)
    end
  end)
end)
