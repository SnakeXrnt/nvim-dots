-- https://github.com/nvim-treesitter/nvim-treesitter
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = {
          "c",
          "cpp",
          "python",
          "lua",
          "vim",
          "vimdoc",
          "query",
          "markdown",
          "markdown_inline",
        },
        sync_install = false,
        auto_install = true,
        ignore_install = {},
        modules = {},
        indent = { enable = true, disable = { "cpp", "c" } },
        highlight = {
          enable = true,
          ---@diagnostic disable-next-line: unused-local
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            ---@diagnostic disable-next-line: undefined-field
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
          additional_vim_regex_highlighting = false,
        },
      }
    end,
  },
}
