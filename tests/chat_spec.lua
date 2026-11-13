local Chat = require('CopilotChat.ui.chat')
local config = require('CopilotChat.config')
local constants = require('CopilotChat.constants')

describe('CopilotChat.ui.chat bounds', function()
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
end)

