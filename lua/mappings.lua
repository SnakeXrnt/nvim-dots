require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<leader>rr", function()
  for name, _ in pairs(package.loaded) do
    if name:match("^config") or name:match("^plugins") or name:match("^mappings") then
      package.loaded[name] = nil
    end
  end
  dofile(vim.env.MYVIMRC)
  vim.notify("Config reloaded!", vim.log.levels.INFO)
end, { desc = "Reload Config" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
