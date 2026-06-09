-- https://github.com/nvim-telescope/telescope.nvim
return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      {
        'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font
      },
      { 'KirilStrezikozin/telescope-py-super-types.nvim' },
    },
    config = function()
      require('telescope').setup({
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
          py_super_types = {
            style = "flatten",
          },
        },
      })

      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
      pcall(require("telescope").load_extension, "py_super_types")

      vim.keymap.set("n", "<leader>st", function()
        require("telescope").extensions.py_super_types.py_super_types()
      end, { desc = "Search [S]uper [T]ypes" })

      local pickers = require('telescope.pickers')
      local finders = require('telescope.finders')
      local conf = require('telescope.config').values

      -- `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })

      -- When searching files, list hidden and ignored in .gitignore,
      -- except the ones listed in `ignore_globs` below.
      -- See :help telescope.builtin.find_files,
      local ignore_globs = {
        '.next/',
        '.git/',
        'node_modules/',
        '.ruff_cache/',
        '.direnv/',
        '.venv/',
        '*/**/__pycache__',
      }

      -- Assemble the find_command taking the `ignore_globs` above into account.
      local find_command = { 'rg', '--files', '--hidden', '--no-ignore', '--no-ignore-vcs' }
      for i = 1, #ignore_globs do
        table.insert(find_command, '--glob')
        table.insert(find_command, '!' .. ignore_globs[i])
      end

      vim.keymap.set(
        'n', '<leader>sf',
        function() builtin.find_files({ find_command = find_command }) end,
        { desc = '[S]earch [F]iles' }
      )

      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
          winblend = 0,
          previewer = false,
        }))
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        })
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
}
