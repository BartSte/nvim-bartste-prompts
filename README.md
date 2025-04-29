# nvim-bartste-prompts - AI-Powered Code Enhancements for Neovim

A Neovim plugin that uses AI prompts to help with code documentation,
refactoring, type hints, and test generation.

## Features

- Generate docstrings for code
- Add type hints automatically
- Refactor code with AI suggestions
- Fix common code issues
- Generate unit tests
- Show spinner icon with current command and file in statusline (using lualine integration)
- Abort running command
- Only aider is supported as AI framework for now.

## Installation

Make sure that [bartste-prompts](https://github.com/BartSte/bartste-prompts) is
installed and in your PATH. You can do this by running:

```bash
python --version # must be <=3.12 for aider to work
pipx install aider
pipx install git+https://github.com/BartSte/bartste-prompts.git
```

It is recommended to use `pipx` instead of `pip` so you can safely install it on
a global scope.

You can install this plugin using your favorite Neovim plugin manager. For
example, using `lazy.nvim`:

```lua
{
  "BartSte/nvim-bartste-prompts",
  config = function()
    require('prompts').setup()
  end
}
```

## Commands

| Command         | Description                                    | Mode   |
| --------------- | ---------------------------------------------- | ------ |
| `:AiDocstrings` | Generate documentation for code                | Normal |
| `:AiTypehints`  | Add type hints automatically                   | Normal |
| `:AiRefactor`   | Suggest refactoring improvements               | Normal |
| `:AiFix`        | Identify and fix code issues                   | Normal |
| `:AiTests`      | Generate unit tests for current code           | Normal |
| `:AiIsRunning`  | Check if a prompt command is currently running | Normal |
| `:AiAbort`      | Abort the currently running prompt command     | Normal |

## Usage

1. Open a code file
2. Run any `:Ai*` command
3. Review changes in the commit that has been created.

![Diff View](https://via.placeholder.com/800x400.png?text=Diff+View+Screenshot)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## License

MIT License - See [LICENCE](LICENCE) for details
