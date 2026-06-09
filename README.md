# My Neovim Configuration

This is a personalized Neovim configuration based on a fork of [KirilStrezikozin/nvim-dots](https://github.com/KirilStrezikozin/nvim-dots).

## Custom Features & Changes

### 🚀 Advanced Floating Terminals
I've implemented two distinct terminal behaviors to improve workflow efficiency:
- **`Ctrl + h` (Persistent Terminal):** Toggles a floating terminal that stays in its current working directory. It remembers its state even when closed and reopened.
- **`Ctrl + j` (Context Terminal):** Toggles a temporary floating terminal that always follows you to the directory of the file you are currently editing. It resets every time you toggle it.

### 🛠️ Enhanced Autocompletion & Editing
- **`blink.cmp` Integration:** High-performance autocompletion across all languages (C, C++, Python, Lua, etc.).
  - `Enter`: Accept completion.
  - `Tab` / `Shift + Tab`: Navigate completion suggestions.
- **Auto-pairing & Tabbing:** 
  - Automatic closing of brackets `()`, braces `{}`, and quotes `""`.
  - Intelligent auto-tabbing when pressing `Enter` inside braces, optimized specifically for C, C++, and Python.
- **Auto-Save:** Configuration includes an autosave feature that triggers when leaving Insert mode or holding the cursor.

### ⌨️ Custom Keymaps
- `<leader>rr`: **Reload Configuration** without restarting Neovim.
- `<leader>x`: Execute the current line/selection as Lua code.
- `<leader>fp`: Copy current file path to clipboard.
- `yp`: Duplicate current line (similar to `yyp`).
- `<leader>h`: Toggle highlight on the current visual selection.

## Tech Stack
- **Plugin Manager:** [lazy.nvim](https://github.com/folke/lazy.nvim)
- **LSP Management:** [mason.nvim](https://github.com/williamboman/mason.nvim) & [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- **Completion:** [blink.cmp](https://github.com/Saghen/blink.cmp)
- **Syntax:** [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- **UI:** [tokyonight.nvim](https://github.com/folke/tokyonight.nvim) with transparent backgrounds.
