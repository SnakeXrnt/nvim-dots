-- https://github.com/chomosuke/typst-preview.nvim
return {
  {
    "chomosuke/typst-preview.nvim",
    lazy = false, -- or ft = 'typst'
    version = "1.*",
    cond = function()
      -- https://lazy.folke.io/spec#spec-loading
      -- Disable this plugin if `tinymist` or `websocat` is not installed.
      return vim.fn.executable("tinymist") == 1 and vim.fn.executable("websocat") == 1
    end,
    config = function()
      require("typst-preview").setup({
        dependencies_bin = {
          ["tinymist"] = "tinymist",
          ["websocat"] = "websocat",
        },
      })

      -- https://myriad-dreamin.github.io/tinymist/frontend/neovim.html
      vim.api.nvim_create_user_command("TypstPreviewPdf", function()
        local filepath = vim.api.nvim_buf_get_name(0)
        if not filepath:match("%.typ$") then return end

        local pdfpath = filepath:gsub("%.typ$", ".pdf")

        vim.system({ "zathura", pdfpath }) -- Zathura is used to preview PDFs
      end, { desc = "Start the preview in PDF format" })
    end,
  }
}
