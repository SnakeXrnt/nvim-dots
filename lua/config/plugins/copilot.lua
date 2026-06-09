return {
  {
    'zbirenbaum/copilot.lua',
    config = function()
      require("copilot").setup({
        suggestion = {
          keymap = {
            accept = "<M-a>",
            next = "<M-l>",
            prev = "<M-h>",
            dismiss = "<M-q>",
          },
        },
      })
    end,
  }
}
