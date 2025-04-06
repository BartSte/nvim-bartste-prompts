# nvim-prompts - AI-Powered Code Enhancements for Neovim

![Demo](https://via.placeholder.com/800x400.png?text=Demo+Animation+Here)

A Neovim plugin that uses AI prompts to help with code documentation, refactoring, type hints, and test generation.

## Features

- Generate docstrings for code
- Add type hints automatically
- Refactor code with AI suggestions
- Fix common code issues
- Generate unit tests
- Interactive diff view for changes
- Non-blocking asynchronous operations

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'your-username/nvim-prompts',
  config = function()
    require('prompts').setup({
      -- Disable all default keymaps
      disable_keymaps = true,
    })
  end
}
```

## Commands

| Command             | Description                          | Mode   |
|---------------------|--------------------------------------|--------|
| `:PromptDocstrings` | Generate documentation for code      | Normal |
| `:PromptTypehints`  | Add type annotations                 | Normal |
| `:PromptRefactor`   | Suggest refactoring improvements     | Normal |
| `:PromptFix`        | Identify and fix code issues         | Normal |
| `:PromptTests`      | Generate unit tests for current code | Normal |

## Configuration

```lua
require('prompts').setup({
  disable_keymaps = false,  -- Set to true to disable default keymaps
  timeout_ms = 3000,        -- Process timeout in milliseconds
  -- Add custom keymaps (example):
  on_attach = function(client, bufnr)
    vim.keymap.set('n', '<leader>pd', '<cmd>PromptDocstrings<CR>', { buffer = bufnr })
  end
})
```

## Usage

1. Open a code file
2. Run any `:Prompt*` command
3. Review changes in the vertical diff view
4. Accept (y) or reject (n) changes

![Diff View](https://via.placeholder.com/800x400.png?text=Diff+View+Screenshot)

## Troubleshooting

Common issues:

**Q: Commands not working?**
- Ensure `prompts` CLI is installed and in PATH
- Check network connection

**Q: Diff view layout issues?**
- Try closing other tabs/buffers first
- Use `:tabclose` to clean up after accepting/rejecting changes

## Contributing

1. Fork the repository
2. Create feature branch
3. Submit PR with detailed description
4. Follow existing code style

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## License

MIT License - See [LICENCE](LICENCE) for details
