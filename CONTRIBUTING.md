# Contributing to copilot-chat.nvim

## Where do I go from here?

If you've noticed a bug or have a feature request, make sure to check our
[Issues](https://github.com/code-ai-nvim/copilot-chat.nvim/issues) page to see
if someone else in the community has already created a ticket. If not, go ahead
and make one!

## Fork & create a branch

If this is something you think you can fix, then fork copilot-chat.nvim and
create a branch with a descriptive name.

A good branch name would be (where issue #325 is the ticket you're working on):

```bash
git checkout -b 325-add-japanese-localization
```

Make sure to check [Structure](#Structure) first to understand the project structure.

## Implement your fix or feature

At this point, you're ready to make your changes! Feel free to ask for help;
everyone is a beginner at first. You can also ask in our Discord server, see [README](/README.md).

## Make a Pull Request

At this point, you should switch back to your main branch and make sure it's
up to date with copilot-chat.nvim's main branch:

```bash
git remote add upstream git@github.com:code-ai-nvim/copilot-chat.nvim.git
git checkout main
git pull upstream main
```

Then update your feature branch from your local copy of master and push your branch to your GitHub account:

```bash
git checkout 325-add-japanese-localization
git rebase main
git push --set-upstream origin 325-add-japanese-localization
```

Go to the copilot-chat.nvim in your GitHub account, select your branch, and click the "Pull Request" button.

## Structure

TODO: draw a diagram of the structure using [Mermaid](https://mermaid.js.org/).

### Core

- [init.lua](/lua/copilot-chat/init.lua): Main module. Plugin initialization
  (`setup()`), chat lifecycle (`ask()`, `open()`, `close()`, `toggle()`,
  `reset()`), save/load, and sticky prompt processing.

- [client.lua](/lua/copilot-chat/client.lua): Copilot API client. Handles
  authentication, model listing, streaming requests, and tool call execution.

- [config.lua](/lua/copilot-chat/config.lua): Default configuration schema.

- [config/](/lua/copilot-chat/config/): Sub-configs for
  [functions](/lua/copilot-chat/config/functions.lua),
  [mappings](/lua/copilot-chat/config/mappings.lua),
  [prompts](/lua/copilot-chat/config/prompts.lua), and
  [providers](/lua/copilot-chat/config/providers.lua).

- [constants.lua](/lua/copilot-chat/constants.lua): Shared constants (plugin
  name, roles).

### Chat and UI

- [ui/chat.lua](/lua/copilot-chat/ui/chat.lua): Chat window management.
  Creating, appending to, clearing, opening, closing, and focusing the chat
  window. Handles fold expressions and section parsing.

- [ui/overlay.lua](/lua/copilot-chat/ui/overlay.lua): Overlay buffer used for
  displaying diff previews and other transient content.

- [ui/spinner.lua](/lua/copilot-chat/ui/spinner.lua): Loading spinner indicator
  for the chat window.

### Features

- [prompts.lua](/lua/copilot-chat/prompts.lua): Prompt resolution, custom
  instruction loading, system prompt building, and sticky/resource/tool
  parsing from user input.

- [functions.lua](/lua/copilot-chat/functions.lua): Built-in functions/tools
  exposed to the LLM (e.g., file editing, searching).

- [resources.lua](/lua/copilot-chat/resources.lua): Resource handling for file
  and URL content retrieval with caching.

- [completion.lua](/lua/copilot-chat/completion.lua): Completion source for the
  chat window (`@tools`, `/prompts`, `#resources`, `$models`).

- [select.lua](/lua/copilot-chat/select.lua): Selection strategies for providing
  context (visual selection, buffer, diagnostics, git diff, etc.).

- [tiktoken.lua](/lua/copilot-chat/tiktoken.lua): Token counting via native
  tiktoken library.

- [instructions/](/lua/copilot-chat/instructions/): System prompt templates
  injected into LLM conversations (edit formats, tool use instructions, custom
  instructions wrapper).

### Utilities

- [utils.lua](/lua/copilot-chat/utils.lua): General utility functions.

- [utils/](/lua/copilot-chat/utils/): Utility modules
  [class.lua](/lua/copilot-chat/utils/class.lua) (OOP helper),
  [curl.lua](/lua/copilot-chat/utils/curl.lua) (HTTP requests),
  [diff.lua](/lua/copilot-chat/utils/diff.lua) (unified diff parsing and application),
  [files.lua](/lua/copilot-chat/utils/files.lua) (file I/O and filetype detection),
  [notify.lua](/lua/copilot-chat/utils/notify.lua) (pub/sub notification system for status and message events)
  [orderedmap.lua](/lua/copilot-chat/utils/orderedmap.lua) (insertion-ordered map),
  [stringbuffer.lua](/lua/copilot-chat/utils/stringbuffer.lua) (efficient string concatenation).

### Other

- [health.lua](/lua/copilot-chat/health.lua): `:checkhealth` integration.
  Verifies commands, libraries, and Treesitter parsers.
