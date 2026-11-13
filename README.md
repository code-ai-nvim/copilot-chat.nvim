# Acknowledgment

This repository is a fork of [CopilotChat.nvim](https://github.com/CopilotC-Nvim/CopilotChat.nvim), and I want to begin with a heartfelt thank-you to its author, [Thomas Slusny](https://github.com/deathbeam).

Thomas, your work is the foundation that makes this fork possible. The time, care, and expertise you have shared through CopilotChat.nvim have given this project far more than a starting point: they have provided something valuable to learn from, build upon, and carry forward. Without your efforts, this fork would not exist.

Thank you for creating CopilotChat.nvim and sharing it with the Neovim community. As this fork takes its own direction, I remain deeply grateful for your contributions and proud to acknowledge the work it builds on.

<div align="center">

# Copilot Chat for Neovim

[![Release](https://img.shields.io/github/v/release/code-ai-nvim/copilot-chat.nvim?logo=github&style=for-the-badge)](https://github.com/code-ai-nvim/copilot-chat.nvim/releases/latest)
[![Build](https://img.shields.io/github/actions/workflow/status/code-ai-nvim/copilot-chat.nvim/ci.yml?logo=github&style=for-the-badge)](https://github.com/code-ai-nvim/copilot-chat.nvim/actions/workflows/ci.yml)
[![Documentation](https://img.shields.io/badge/documentation-up-green.svg?logo=vim&style=for-the-badge)](https://code-ai-nvim.github.io/copilot-chat.nvim/)

[![Contributors](https://img.shields.io/github/all-contributors/code-ai-nvim/copilot-chat.nvim?color=ee8449&logo=github&label=contributors&style=for-the-badge)](#contributors)
[![Discord](https://img.shields.io/discord/1200633211236122665?logo=discord&label=discord&style=for-the-badge)](https://discord.gg/vy6hJsTWaZ)
[![Dotfyle](https://dotfyle.com/plugins/code-ai-nvim/copilot-chat.nvim/shield?style=for-the-badge)](https://dotfyle.com/plugins/code-ai-nvim/copilot-chat.nvim)

![image](https://github.com/user-attachments/assets/9ee30811-0fb8-4500-91f6-34ea6b26adea)

https://github.com/user-attachments/assets/8cad5643-63b2-4641-a5c4-68bc313f20e6

</div>

copilot-chat.nvim brings GitHub Copilot Chat capabilities directly into Neovim with a focus on transparency and user control.

- 🤖 **Multiple AI Models** - GitHub Copilot (including GPT-4o, Gemini 2.5 Pro, Claude 4 Sonnet, Claude 3.7 Sonnet, Claude 3.5 Sonnet, o3-mini, o4-mini) + custom providers (Ollama, Mistral.ai). The exact list of available models depends on your [GitHub Copilot settings](https://github.com/settings/copilot/features) and the models provided by GitHub's API.
- 🔧 **Tool Calling** - LLM can call workspace functions (file reading, git operations, search) with manual approval or automatic execution for trusted tools
- 🔒 **Privacy First** - Only shares what you explicitly request - no background data collection
- 📝 **Interactive Chat** - Interactive UI with completion, diffs, and quickfix integration
- 🎯 **Smart Prompts** - Composable templates and sticky prompts for consistent context
- ⚡ **Token Efficient** - Resource replacement prevents duplicate context, history management via tiktoken counting
- 🔗 **Scriptable** - Comprehensive Lua API for automation and headless mode operation
- 🔌 **Extensible** - [Custom functions](https://github.com/code-ai-nvim/copilot-chat.nvim/discussions/categories/functions) and [providers](https://github.com/code-ai-nvim/copilot-chat.nvim/discussions/categories/providers), plus integrations like [mcphub.nvim](https://github.com/ravitemer/mcphub.nvim)

# Installation

## Requirements

- [Neovim 0.10.0+](https://neovim.io/)
- [curl 8.0.0+](https://curl.se/)
- [Copilot chat in the IDE](https://github.com/settings/copilot) enabled in GitHub settings
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

> [!WARNING]
> For Neovim < 0.11.0, add `noinsert` or `noselect` to your `completeopt` otherwise chat autocompletion will not work.
> For best autocompletion experience, also add `popup` to your `completeopt` (even on Neovim 0.11.0+).

## Optional Dependencies

- [tiktoken_core](https://github.com/gptlang/lua-tiktoken) - For accurate token counting
  - Arch Linux: Install [`luajit-tiktoken-bin`](https://aur.archlinux.org/packages/luajit-tiktoken-bin) or [`lua51-tiktoken-bin`](https://aur.archlinux.org/packages/lua51-tiktoken-bin) from AUR
  - Via luarocks: `sudo luarocks install --lua-version 5.1 tiktoken_core`
  - Manual: Download from [lua-tiktoken releases](https://github.com/gptlang/lua-tiktoken/releases) and save as `tiktoken_core.so` in your Lua path
- [git](https://git-scm.com/) - For git diff context features
- [ripgrep](https://github.com/BurntSushi/ripgrep) - For improved search performance
- [lynx](https://lynx.invisible-island.net/) - For improved URL context features

## Integration with pickers

For various plugin pickers to work correctly, you need to replace `vim.ui.select` with your desired picker (as the default `vim.ui.select` is very basic). Here are some examples:

- [fzf-lua](https://github.com/ibhagwan/fzf-lua?tab=readme-ov-file#neovim-api) - call `require('fzf-lua').register_ui_select()`
- [telescope](https://github.com/nvim-telescope/telescope-ui-select.nvim?tab=readme-ov-file#telescope-setup-and-configuration) - setup `telescope-ui-select.nvim` plugin
- [snacks.picker](https://github.com/folke/snacks.nvim/blob/main/docs/picker.md#%EF%B8%8F-config) - enable `ui_select` config
- [mini.pick](https://github.com/echasnovski/mini.pick/blob/main/lua/mini/pick.lua#L1229) - set `vim.ui.select = require('mini.pick').ui_select`

## [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
  {
    "code-ai-nvim/copilot-chat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    opts = {
      -- See Configuration section for options
    },
  },
}
```

## [vim-plug](https://github.com/junegunn/vim-plug)

```vim
call plug#begin()
Plug 'nvim-lua/plenary.nvim'
Plug 'code-ai-nvim/copilot-chat.nvim'
call plug#end()

lua << EOF
require("copilot-chat").setup()
EOF
```

# Core Concepts

- **Resources** (`#<name>`) - Add specific content (files, git diffs, URLs) to your prompt
- **Tools** (`@<name>`) - Give LLM access to functions it can call during the chat, with manual approval by default
- **Sticky Prompts** (`> <text>`) - Persist context across single chat session
- **Models** (`$<model>`) - Specify which AI model to use for the chat
- **Prompts** (`/PromptName`) - Use predefined prompt templates for common tasks

> [!TIP]
> Press `<Tab>` after typing `#` or `@` to see available options and auto-complete. This is the easiest way to discover what's available!

# Usage

## Commands

| Command                    | Description                   |
| -------------------------- | ----------------------------- |
| `:CopilotChat <input>?`    | Open chat with optional input |
| `:CopilotChatOpen`         | Open chat window              |
| `:CopilotChatClose`        | Close chat window             |
| `:CopilotChatToggle`       | Toggle chat window            |
| `:CopilotChatStop`         | Stop current output           |
| `:CopilotChatReset`        | Reset chat window             |
| `:CopilotChatSave <name>?` | Save chat history             |
| `:CopilotChatLoad <name>?` | Load chat history             |
| `:CopilotChatPrompts`      | View/select prompt templates  |
| `:CopilotChatModels`       | View/select available models  |
| `:CopilotChat<PromptName>` | Use specific prompt template  |

The model picker shows AI Credit rates as `input/output` per million tokens. A `?` means the rate is unavailable.
These are default-tier rates; cached-token and long-context pricing may differ. Auto has no fixed model rate.
Auto is listed first. Other models are ordered by output rate, lowest first, with unavailable rates last.

## Chat Key Mappings

| Insert  | Normal  | Action                                               |
| ------- | ------- | ---------------------------------------------------- |
| `<Tab>` | -       | **Autocomplete resources/files/options** (use this!) |
| `<C-c>` | `q`     | Close the chat window                                |
| `<C-l>` | `<C-l>` | Reset and clear the chat window                      |
| `<C-s>` | `<CR>`  | Submit the current prompt                            |
| `<C-y>` | `<C-y>` | Accept nearest diff                                  |
| -       | `gj`    | Jump to section of nearest diff                      |
| -       | `gqa`   | Add all answers from chat to quickfix                |
| -       | `gqd`   | Add all diffs from chat to quickfix                  |
| -       | `gy`    | Yank nearest diff to register                        |
| -       | `gd`    | Show diff between source and nearest diff            |
| -       | `gc`    | Show info about current chat                         |
| -       | `gh`    | Show help message                                    |

**💡 Pro tip:** After typing `#`, `@`, `#buffer:`, or `#file:`, press `<Tab>` to see available options. This is the fastest way to work!

> [!NOTE]
> **Tab key not working?** Some plugins (e.g. `copilot.vim`) also map `<Tab>` in insert mode.  
> To fix conflicts, disable the other plugin's `<Tab>` mapping:
>
> ```lua
> -- For copilot.vim
> vim.g.copilot_no_tab_map = true
> vim.keymap.set('i', '<S-Tab>', 'copilot#Accept("\\<S-Tab>")', { expr = true, replace_keycodes = false })
> ```
>
> Or customize copilot-chat keymaps in your config.

## Predefined Functions

All predefined functions belong to the `copilot` group.

| Function    | Manual `#...` | Description                                            | Available Options                                                     |
| ----------- | ------------- | ------------------------------------------------------ | --------------------------------------------------------------------- |
| `bash`      | No            | Executes a bash command and returns output             | Tool-only (use `@copilot`)                                            |
| `buffer`    | Yes           | Retrieves content from buffer(s) with diagnostics      | `active`, `visible`, `listed`, `quickfix`, buffer number, or filename |
| `clipboard` | Yes           | Provides access to system clipboard content            | No options                                                            |
| `edit`      | No            | Applies a unified diff to a file                       | Tool-only (use `@copilot`)                                            |
| `file`      | Yes           | Reads content from a specified file path               | Any file path (use `<Tab>` for completion)                            |
| `gitdiff`   | Yes           | Retrieves git diff information                         | `unstaged` (default), `staged`, or commit SHA                         |
| `glob`      | Yes           | Lists filenames matching a pattern in workspace        | Any glob pattern (default: `**/*`)                                    |
| `grep`      | Yes           | Searches for a pattern across files in workspace       | Any search pattern                                                    |
| `selection` | Yes           | Includes the current visual selection with diagnostics | No options                                                            |
| `url`       | Yes           | Fetches content from a specified URL                   | Any HTTPS URL                                                         |

- **`#<function>`** - Embeds output directly in your message (e.g., `#buffer:listed`, `#file:src/main.lua`)
- **`@<function/group>`** - Makes function(s) available for LLM to call when needed (e.g., `@copilot`, `@file`)

## Predefined Prompts

| Prompt     | Description                                                            |
| ---------- | ---------------------------------------------------------------------- |
| `Explain`  | Write detailed explanation of selected code as paragraphs              |
| `Review`   | Comprehensive code review with line-specific issue reporting           |
| `Fix`      | Identify problems and rewrite code with fixes and explanation          |
| `Optimize` | Improve performance and readability with optimization strategy         |
| `Docs`     | Add documentation comments to selected code                            |
| `Tests`    | Generate tests for selected code                                       |
| `Commit`   | Generate commit message with commitizen convention from staged changes |

## Resource Usage

```markdown
# Current buffer

#buffer:active

# All open buffers (replaces old #buffers)

#buffer:listed

# All visible buffers

#buffer:visible

# Specific file

#file:src/main.lua

# Git changes

#gitdiff:staged

# URL content

#url:https://example.com/docs
```

## Tool Usage

When you use `@copilot`, the LLM can call functions from the `copilot` group such as `bash`, `edit`, `file`, `glob`, `grep`, and `gitdiff`.

```markdown
# Give LLM access to workspace tools

@copilot What files are in this project?

# Sticky context with tools

> #buffer:listed
> @copilot
> Refactor the authentication code
```

By default, tool calls require manual approval. Configure `trusted_tools` to automatically run specific tools (see [Functions](#functions)).

> [!WARNING]
> `trusted_tools = true` allows the model to run every enabled tool without asking. Only use it if you fully trust the tool set and workspace.

# Configuration

For all available configuration options, see [`lua/copilot-chat/config.lua`](lua/copilot-chat/config.lua).

## Quick Setup

Most users only need to configure a few options:

```lua
{
  model = 'gpt-5-mini',        -- AI model to use
  temperature = 0.1,           -- Lower = focused, higher = creative
  trusted_tools = nil,         -- Require approval for all tool calls
  window = {
    layout = 'vertical',       -- 'vertical', 'horizontal', 'float'
    width = 0.5,              -- 50% of screen width
  },
  auto_insert_mode = true,     -- Enter insert mode when opening
}
```

## Window & Appearance

```lua
{
  window = {
    layout = 'float',
    width = 80, -- Fixed width in columns
    height = 20, -- Fixed height in rows
    border = 'rounded', -- 'single', 'double', 'rounded', 'solid'
    title = '🤖 AI Assistant',
    zindex = 100, -- Ensure window stays on top
  },

  headers = {
    user = '👤 You',
    assistant = '🤖 Copilot',
    tool = '🔧 Tool',
  },

  separator = '━━',
  auto_fold = true, -- Automatically folds non-assistant messages
}
```

`window.layout` also supports `'replace'` to reuse the current window.

## Buffer Behavior

```lua
-- Auto-command to customize chat buffer behavior
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = 'copilot-chat',
  callback = function()
    vim.opt_local.relativenumber = false
    vim.opt_local.number = false
    vim.opt_local.conceallevel = 0
  end,
})
```

## Highlights

You can customize colors by setting highlight groups in your config:

```lua
-- In your colorscheme or init.lua
vim.api.nvim_set_hl(0, 'CopilotChatHeader', { fg = '#7C3AED', bold = true })
vim.api.nvim_set_hl(0, 'CopilotChatSeparator', { fg = '#374151' })
```

Types of copilot highlights:

- `CopilotChatHeader` - Header highlight in chat buffer
- `CopilotChatSeparator` - Separator highlight in chat buffer
- `CopilotChatSelection` - Selection highlight in source buffer
- `CopilotChatStatus` - Status and spinner in chat buffer
- `CopilotChatHelp` - Help text in chat buffer
- `CopilotChatResource` - Resource highlight in chat buffer (e.g. `#file`, `#gitdiff`)
- `CopilotChatTool` - Tool call highlight in chat buffer (e.g. `@copilot`)
- `CopilotChatPrompt` - Prompt highlight in chat buffer (e.g. `/Explain`, `/Review`)
- `CopilotChatModel` - Model highlight in chat buffer (e.g. `$gpt-5-mini`)
- `CopilotChatUri` - URI highlight in chat buffer (e.g. `##https://...`)
- `CopilotChatAnnotation` - Annotation highlight in chat buffer (file headers, tool call headers, tool call body)
- `CopilotChatAnnotationHeader` - Annotation header highlight in chat buffer

## Prompts

Define your own prompts in the configuration:

```lua
{
  prompts = {
    MyCustomPrompt = {
      prompt = 'Explain how it works.',
      system_prompt = 'You are very good at explaining stuff',
      mapping = '<leader>ccmc',
      description = 'My custom prompt description',
    },
    Yarrr = {
      system_prompt = 'You are fascinated by pirates, so please respond in pirate speak.',
    },
    NiceInstructions = {
      system_prompt = 'You are a nice coding tutor, so please respond in a friendly and helpful manner.',
    }
  }
}
```

## Functions

Use `trusted_tools` to control which tool calls are executed automatically:

```lua
{
  trusted_tools = nil, -- default: require approval for all tool calls

  -- trust all functions in a group
  -- trusted_tools = 'copilot',

  -- trust specific functions by name or groups by name
  -- trusted_tools = { 'file', 'glob', 'grep' },

  -- trust every enabled tool call
  -- trusted_tools = true,
}
```

**How tool trust works:**

A tool is trusted when any of these match:

- Its function definition sets `trusted = true`
- Its function name appears in `trusted_tools`
- Its function group appears in `trusted_tools`
- `trusted_tools = true`

**Recommended setup:** Trust read-only functions like `file`, `glob`, or `grep` for a smoother workflow without compromising safety.

> [!WARNING]
> Trusted tools run without asking for confirmation. Be especially careful with tools like `bash` and `edit`, which can change your workspace.

Define your own functions in the configuration with input handling and schema:

```lua
{
  functions = {
    birthday = {
      description = 'Retrieves birthday information for a person',
      uri = 'birthday://{name}',
      trusted = false,
      schema = {
        type = 'object',
        required = { 'name' },
        properties = {
          name = {
            type = 'string',
            enum = { 'Alice', 'Bob', 'Charlie' },
            description = "Person's name",
          },
        },
      },
      resolve = function(input)
        return {
          {
            uri = 'birthday://' .. input.name,
            mimetype = 'text/plain',
            data = input.name .. ' birthday info',
          },
        }
      end,
    },
  }
}
```

If a function has a `uri`, it can be used manually with `#birthday:Alice`. Functions without a `uri` are tool-only and can only be called by the model.

## Providers

Add custom AI providers:

```lua
{
  providers = {
    my_provider = {
      get_url = function(opts) return 'https://api.example.com/chat' end,
      get_headers = function() return { ['Authorization'] = 'Bearer ' .. api_key } end,
      get_models = function() return { { id = 'gpt-5-mini', name = 'GPT-5 mini model' } } end,
      prepare_input = require('copilot-chat.config.providers').copilot.prepare_input,
      prepare_output = require('copilot-chat.config.providers').copilot.prepare_output,
    }
  }
}
```

**Provider Interface:**

```lua
{
  -- Optional: Disable provider
  disabled?: boolean,

  -- Optional: Extra info about the provider displayed in info panel
  get_info?(headers: table): string[]

  -- Optional: Get extra request headers with optional expiration time
  get_headers?(): table<string,string>, number?,

  -- Optional: Get API endpoint URL
  get_url?(opts: copilot_chat.Provider.options): string,

  -- Optional: Prepare request input
  prepare_input?(inputs: table<copilot_chat.Provider.input>, opts: copilot_chat.Provider.options): table,

  -- Optional: Prepare response output
  prepare_output?(output: table, opts: copilot_chat.Provider.options): copilot_chat.Provider.output,

  -- Optional: Get available models
  get_models?(headers: table): table<copilot_chat.Provider.model>,

  -- Optional: Resolve a user-facing model id to a provider model id.
  -- Second return value is optional extra request headers (e.g. Copilot-Session-Token).
  resolve_model?(headers: table, model: string): string, table?,
}
```

**Built-in providers:**

- `copilot` - GitHub Copilot (default)
- `github_models` - GitHub Models (disabled by default)

# API Reference

## Core

```lua
local chat = require('copilot-chat')

-- Basic Chat Functions
chat.ask(prompt, config)      -- Ask a question with optional config

-- Window Management
chat.open(config)             -- Open chat window with optional config
chat.close()                  -- Close chat window
chat.toggle(config)           -- Toggle chat window visibility with optional config
chat.reset()                  -- Reset the chat
chat.stop()                   -- Stop current output

-- Prompt & Model Management
chat.select_prompt(config)    -- Open prompt selector with optional config
chat.select_model()           -- Open model selector

-- History Management
chat.load(name, history_path) -- Load chat history
chat.save(name, history_path) -- Save chat history

-- Configuration
chat.setup(config)            -- Update configuration
chat.log_level(level)         -- Set log level (debug, info, etc.)
```

## Chat Window

You can also access the chat window UI methods through the `chat.chat` object:

```lua
local window = require('copilot-chat').chat

-- Chat UI State
window:visible()             -- Check if chat window is visible
window:focused()             -- Check if chat window is focused

-- Message Management
window:get_message(role, cursor)               -- Get chat message by role, either last or closest to cursor
window:add_message({ role, content }, replace) -- Add or replace a message in chat
window:remove_message(role, cursor)            -- Remove chat message by role, either last or closest to cursor
window:get_block(role, cursor)                 -- Get code block by role, either last or closest to cursor

-- Content Management
window:append(text)          -- Append text to chat window
window:clear()               -- Clear chat window content
window:start()               -- Start writing to chat window
window:finish()              -- Finish writing to chat window

-- Source Management
window:get_source()          -- Get the current source buffer and window
window:set_source(winnr)     -- Set the source window

-- Navigation
window:follow()              -- Move cursor to end of chat content
window:focus()               -- Focus the chat window

-- Advanced Features
window:overlay(opts)         -- Show overlay with specified options
```

## Prompt parser

```lua
local parser = require('copilot-chat.prompts')

parser.resolve_prompt()         -- Resolve prompt references
parser.resolve_tools()          -- Resolve tools shared with the model via @...
parser.resolve_functions()      -- Resolve manual function/resource references via #...
parser.resolve_model()          -- Resolve model from prompt (WARN: async, requires plenary.async.run)
```

## Example Usage

```lua
-- Open chat, ask a question and handle response
require('copilot-chat').open()
require('copilot-chat').ask('#buffer Explain this code', {
  callback = function(response)
    vim.notify('Got response: ' .. vim.trim(response.content):sub(1, 50) .. '...')
  end,
})

-- Save and load chat history
require('copilot-chat').save('my_debugging_session')
require('copilot-chat').load('my_debugging_session')

-- Use custom sticky and model
require('copilot-chat').ask('How can I optimize this?', {
  model = 'gpt-5-mini',
  sticky = { '#buffer', '#gitdiff:staged' },
})

-- Automatically trust a small read-only tool set
require('copilot-chat').setup({
  trusted_tools = { 'file', 'glob', 'grep' },
})
```

For more examples, see the [examples wiki page](https://github.com/code-ai-nvim/copilot-chat.nvim/wiki/Examples-and-Tips).

# Development

## Setup

To set up the environment:

1. Clone the repository:

```bash
git clone https://github.com/code-ai-nvim/copilot-chat.nvim
cd copilot-chat.nvim
```

2. Install development dependencies:

```bash
make install-pre-commit
```

To run tests:

```bash
make test
```

To run the same formatting check as CI:

```bash
stylua --check .
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Make your changes
4. Run tests and lint checks
5. Submit a pull request

See [CONTRIBUTING.md](/CONTRIBUTING.md) for detailed guidelines.

# Contributors

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/gptlang"><img src="https://avatars.githubusercontent.com/u/121417512?v=4?s=100" width="100px;" alt="gptlang"/><br /><sub><b>gptlang</b></sub></a><br /><a href="https://github.com/code-ai-nvim/copilot-chat.nvim/commits?author=gptlang" title="Code">💻</a> <a href="https://github.com/code-ai-nvim/copilot-chat.nvim/commits?author=gptlang" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://productsway.com/"><img src="https://avatars.githubusercontent.com/u/870029?v=4?s=100" width="100px;" alt="Dung Duc Huynh (Kaka)"/><br /><sub><b>Dung Duc Huynh (Kaka)</b></sub></a><br /><a href="https://github.com/code-ai-nvim/copilot-chat.nvim/commits?author=jellydn" title="Code">💻</a> <a href="https://github.com/code-ai-nvim/copilot-chat.nvim/commits?author=jellydn" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://qoobes.dev"><img src="https://avatars.githubusercontent.com/u/58834655?v=4?s=100" width="100px;" alt="Ahmed Haracic"/><br /><sub><b>Ahmed Haracic</b></sub></a><br /><a href="https://github.com/code-ai-nvim/copilot-chat.nvim/commits?author=qoobes" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://youtube.com/@ziontee113"><img src="https://avatars.githubusercontent.com/u/102876811?v=4?s=100" width="100px;" alt="Trí Thiện Nguyễn"/><br /><sub><b>Trí Thiện Nguyễn</b></sub></a><br /><a href="https://github.com/code-ai-nvim/copilot-chat.nvim/commits?author=ziontee113" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Cassius0924"><img src="https://avatars.githubusercontent.com/u/62874592?v=4?s=100" width="100px;" alt="He Zhizhou"/><br /><sub><b>He Zhizhou</b></sub></a><br /><a href="https://github.com/code-ai-nvim/copilot-chat.nvim/commits?author=Cassius0924" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.linkedin.com/in/guruprakashrajakkannu/"><img src="https://avatars.githubusercontent.com/u/9963717?v=4?s=100" width="100px;" alt="Guruprakash Rajakkannu"/><br /><sub><b>Guruprakash Rajakkannu</b></sub></a><br /><a href="https://github.com/code-ai-nvim/copilot-chat.nvim/commits?author=rguruprakash" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/kristofka"><img src="https://avatars.githubusercontent.com/u/140354?v=4?s=100" width="100px;" alt="kristofka"/><br /><sub><b>kristofka</b></sub></a><br /><a href="https://github.com/code-ai-nvim/copilot-chat.nvim/commits?author=kristofka" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/PostCyberPunk"><img src="https://avatars.githubusercontent.com/u/134976996?v=4?s=100" width="100px;" alt="PostCyberPunk"/><br /><sub><b>PostCyberPunk</b></sub></a><br /><a href="https://github.com/code-ai-nvim/copilot-chat.nvim/commits?author=PostCyberPunk" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ctns"><img src="https://avatars.githubusercontent.com/u/1302759?v=4?s=100" width="100px;" alt="Katsuhiko Nishimra"/><br /><sub><b>Katsuhiko Nishimra</b></sub></a><br /><a href="https://github.com/code-ai-nvim/copilot-chat.nvim/commits?author=ktns" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/qoobes"><img src="https://avatars.githubusercontent.com/u/4156525?v=4?s=100" width="100px;" alt="Sjon-Paul Brown"/><br /><sub><b>Sjon-Paul Brown</b></sub></a><br /><a href="https://github.com/code-ai-nvim/copilot-chat.nvim/commits?author=sjonpaulbrown-cc" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind are welcome!

# Stargazers

[![Stargazers over time](https://starchart.cc/code-ai-nvim/copilot-chat.nvim.svg?variant=adaptive)](https://starchart.cc/code-ai-nvim/copilot-chat.nvim)


