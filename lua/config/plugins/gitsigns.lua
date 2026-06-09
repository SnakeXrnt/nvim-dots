-- https://github.com/lewis6991/gitsigns.nvim

local signs = {
  add          = { text = "+" },
  change       = { text = "~" },
  delete       = { text = "_" },
  topdelete    = { text = "‾" },
  changedelete = { text = "~" },
  untracked    = { text = "┆" },
}

return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = signs,
      signs_staged = signs,
      attach_to_untracked = true,
    },
  },
}
