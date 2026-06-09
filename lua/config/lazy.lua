-- https://lazy.folke.io/installation
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

---@diagnostic disable-next-line: undefined-field
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    {
      "folke/tokyonight.nvim",
      opts = {
        transparent = true,
        styles = {
          floats = "transparent",
          sidebars = "transparent",
        },
      },
      config = function(_, opts)
        require("tokyonight").setup(opts)
        vim.cmd.colorscheme "tokyonight-night"
      end,
    },
    { import = "config.plugins" },
    { import = "plugins" },
  },
})
