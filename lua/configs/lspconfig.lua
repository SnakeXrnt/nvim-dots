require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls" }
vim.lsp.enable(servers)

vim.lsp.config("roslyn", {})



-- extend the vhdl_ls config that nvim-lspconfig provides
vim.lsp.config('vhdl_ls', {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- enable it so it auto starts for its filetypes and root markers
vim.lsp.enable('vhdl_ls')



-- read :h vim.lsp.config for changing options of lsp servers 
