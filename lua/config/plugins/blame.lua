-- https://github.com/f-person/git-blame.nvim
return {
  {
    "f-person/git-blame.nvim",
    opts = {
      enabled = true,
      message_template = "<summary> • <date> • <<sha>>",
      date_format = "%r",
      virtual_text_column = 80,
      delay = 0,
      ignored_filetypes = { "oil" },
    },
  },
}
