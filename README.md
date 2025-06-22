# nvim-bartste-prompts - AI-Powered Code Enhancements for Neovim

A Neovim plugin that uses AI prompts to help with code documentation,
refactoring, type hints, and test generation.

## Features

- Generate docstrings for code
- Add type hints automatically
- Refactor code with AI suggestions
- Fix common code issues
- Generate unit tests
- Operate on entire files or visual selections
- Show spinner icon with current command and file in statusline (using lualine integration)
- Abort running command
- Undo the last AI-generated change
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

## Configuration Options

The `setup()` function accepts the following options:

- `notify` (boolean): Whether to show spinner notification after AI commands complete. Default: `false`.
- `backup_dir` (string): Directory path where backups are stored. Default: `vim.fn.stdpath("cache") .. "/prompts_backup"`.

Example:

```lua
require('prompts').setup({
  notify = true,
  backup_dir = vim.fn.stdpath("cache") .. "/prompts_backup",
})
```

## Commands

| Command              | Description                                    | Mode           |
| -------------------- | ---------------------------------------------- | -------------- |
| `:AiDocstrings`      | Generate documentation for code                | Normal, Visual |
| `:AiTypehints`       | Add type hints automatically                   | Normal, Visual |
| `:AiRefactor`        | Suggest refactoring improvements               | Normal, Visual |
| `:AiExplain`         | Explain the selected code                      | Normal, Visual |
| `:AiFix`             | Identify and fix code issues                   | Normal, Visual |
| `:AiTests`           | Generate unit tests for current code           | Normal, Visual |
| `:AiIsRunning`       | Check if a prompt command is currently running | Normal         |
| `:AiAbort`           | Abort the currently running prompt command     | Normal         |
| `:AiUndo`            | Undo the last AI-generated change              | Normal         |
| `:AiShowOutput [file]` | View output buffer for job                   | Normal         |

## Usage

1. Open a code file
2. (Optional) Select a code range in Visual mode to focus on specific code
3. Run any `:Ai*` command
4. Review changes in the commit that has been created.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## License

MIT License - See [LICENCE](LICENCE) for details
