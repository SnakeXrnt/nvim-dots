-- https://github.com/neovim/nvim-lspconfig
return {
  {
    'mikebentley15/vim-pio', -- Syntax highlighting for PIO files.
  },
  {
    'saghen/blink.cmp',
    version = '1.*',
    opts = {
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      --
      -- See :h blink-cmp-config-keymap
      keymap = {
        preset = 'default',
        ['<CR>'] = { 'accept', 'fallback' },
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
      },

      appearance = {
        nerd_font_variant = 'mono'
      },

      signature = { enabled = true },

      sources = {
        default = { "lsp", "path", "snippets", "buffer", "jupynium" },
        providers = {
          jupynium = {
            name = "Jupynium",
            module = "jupynium.blink_cmp",
            score_offset = 100,
          },
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Set capabilities globally for all servers
      vim.lsp.config("*", { capabilities = capabilities })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
            },
          },
        },
      })

      vim.lsp.config("tinymist", {
        settings = {
          formatterMode = "typstyle",
          exportPdf = "onType",
          semanticTokens = "disable",
        },
      })

      vim.lsp.config("htmx", {
        filetypes = { "html", "templ" },
      })

      vim.lsp.config("nixd", {
        settings = {
          nixd = {
            formatting = {
              command = { "nixfmt" },
            },
          },
        },
      })

      -- Enable all servers
      vim.lsp.enable({
        "lua_ls",
        "tinymist",
        "clangd",
        "cmake",
        "pyright",
        "gopls",
        "templ",
        "htmx",
        "golangci_lint_ls",
        "astro",
        "eslint",
        "ruff",
        "pyright",
        "csharp_ls",
        "terraform_lsp",
        "nixd",
        "ts_ls",
      })

      -- Prior to nvim 0.11 (where they are the defaults)

      -- https://github.com/neovim/neovim/pull/28650
      vim.keymap.set("n", "grn", vim.lsp.buf.rename)
      vim.keymap.set("n", "gra", vim.lsp.buf.code_action)
      vim.keymap.set("n", "grr", vim.lsp.buf.references)
      vim.keymap.set("n", "gri", vim.lsp.buf.implementation)
      vim.keymap.set("n", "gd", vim.lsp.buf.definition)
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
      vim.keymap.set("n", "gO", vim.lsp.buf.document_symbol)
      vim.keymap.set("i", "<C-S>", vim.lsp.buf.signature_help)
      vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

      -- Command for "NixFormat" that calls `nix fmt` on the current buffer.
      local call_nix_fmt = function(buf)
        local filename = vim.api.nvim_buf_get_name(buf)

        vim.api.nvim_buf_call(buf, function()
          vim.cmd("write")
        end)

        local obj = vim.system(
          { "nix", "fmt", filename }, { text = true }
        ):wait()

        if obj.code ~= 0 then
          vim.notify(
            "nix fmt failed: " .. (obj.stderr or "error"),
            vim.log.levels.ERROR
          )
          return
        end

        if not vim.api.nvim_buf_is_valid(buf) then return end
        vim.api.nvim_buf_call(buf, function()
          vim.cmd("edit!")
          vim.notify(
            "nix fmt has formatted the file",
            vim.log.levels.INFO
          )
        end)
      end

      local function format_with_prettierd(buf)
        local filename = vim.api.nvim_buf_get_name(buf)
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local input = table.concat(lines, "\n")

        -- Pass buffer content via stdin to prettierd
        local output = vim.fn.system(
          { "prettierd", "--stdin-filepath", filename },
          input
        )

        if vim.v.shell_error ~= 0 then
          vim.notify("prettierd failed:\n" .. output, vim.log.levels.ERROR)
          return
        end

        -- Replace entire buffer with prettified output
        local new_lines = vim.split(output, "\n", { plain = true })
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
      end

      local lsp_keymaps = function(buf)
        local map = function(mode, keys, func, desc)
          vim.keymap.set(mode, keys, func, { buffer = buf, desc = "LSP: " .. desc })
        end

        map("n", "grn", vim.lsp.buf.rename, "[R]e[n]ame")
        map({ "n", "x" }, "gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction")
        map("n", "grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
        map("n", "gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
        map("n", "gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

        --  In C this would take you to the header.
        map("n", "gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        -- Fuzzy find all the symbols in your current document.
        --  Symbols are things like variables, functions, types, etc.
        map("n", "gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")

        -- Fuzzy find all the symbols in your current workspace.
        --  Similar to document symbols, except searches over your entire project.
        map("n", "gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end

          local buf = args.buf
          local filetype = vim.bo.filetype

          -- In case Telescope is not installed, default LSP keymaps remain.
          pcall(lsp_keymaps, buf)

          -- `nixd` timeouts if `nix fmt` is used as its formatting command.
          -- Provide a "NixFormat" command that will call `nix fmt` on
          -- the current buffer, if it is a *.nix file. Note that `nix fmt`
          -- evaluates and parses *.nix files, which is much slower than just
          -- running a formatter directly.
          if filetype == "nix" then
            vim.api.nvim_buf_create_user_command(
              buf, "NixFormat", function() call_nix_fmt(buf) end,
              { desc = "Run nix fmt on the current file" })
          end

          local prettier_filetypes = {
            javascript = true,
            typescript = true,
            javascriptreact = true,
            typescriptreact = true,
            json = true,
            yaml = true,
            html = true,
            css = true,
            scss = true,
            markdown = true,
            graphql = true,
          }

          if client.supports_method("textDocument/formatting", nil) then
            -- Format the current buffer on save.
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = buf,
              callback = function()
                if prettier_filetypes[filetype] and vim.fn.executable("prettierd") == 1 then
                  format_with_prettierd(buf)
                else
                  -- Use LSP formatting if not handled by prettier
                  vim.lsp.buf.format({ bufnr = buf, id = client.id })
                end
              end,
            })
          else
            -- Notify if no formatter is available
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = buf,
              callback = function()
                if prettier_filetypes[filetype] and vim.fn.executable("prettierd") == 1 then
                  format_with_prettierd(buf)
                else
                  vim.notify(
                    "No formatter available for " .. filetype,
                    vim.log.levels.WARN
                  )
                end
              end,
            })
          end
        end,
      })

      local border = "rounded"

      -- Neovim 0.11+ replacement for deprecated vim.lsp.with()
      vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
        return vim.lsp.handlers.hover(err, result, ctx, vim.tbl_extend("force", config or {}, { border = border }))
      end

      vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
        return vim.lsp.handlers.signature_help(err, result, ctx, vim.tbl_extend("force", config or {}, { border = border }))
      end
      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuOpen",
        callback = function()
          vim.b.copilot_suggestion_hidden = true
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuClose",
        callback = function()
          vim.b.copilot_suggestion_hidden = false
        end,
      })
    end,
  },
}
