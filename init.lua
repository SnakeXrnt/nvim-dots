vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.lazy")

vim.o.colorcolumn = "80,120"
vim.o.clipboard = "unnamedplus"
vim.o.cursorline = true
vim.o.ignorecase = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.shiftwidth = 4
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.expandtab = true
vim.cmd("filetype indent on")
vim.o.cindent = true
vim.o.cinoptions = "g0,t0,(0" -- Typical C++ style
vim.o.spell = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.undofile = true
vim.o.wrap = false
-- vim.o.autochdir = true

vim.keymap.set("n", "<leader>x", ":.lua<CR>")
vim.keymap.set("v", "<leader>x", ":lua<CR>")

vim.keymap.set("n", "yp", "yyp")

vim.keymap.set("n", "<C-b>", "<C-a>", { noremap = true, silent = true })

-- vim.keymap.set("n", "<leader>fp", ":let @+ = expand('%:p')<CR>", { desc = "Copy current file path to clipboard" })
vim.keymap.set("n", "<leader>fp", function()
  local file_path = vim.fn.expand("%:p")
  vim.fn.setreg("+", file_path)
  vim.notify("Copied file path to clipboard: " .. file_path, vim.log.levels.INFO)
end, { desc = "Copy current file path to clipboard" })

-- vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.cmd(":hi statusline guibg=NONE")

-- Prior to nvim 0.11
vim.diagnostic.config {
  float = {
    border = "rounded",
  },
  virtual_text = {
    prefix = "",
    virt_text_win_col = 120, -- Fixed column for the '3rd part' look
    source = "if_many",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
}

-- Create an autosave group
local autosave_group = vim.api.nvim_create_augroup("autosave", { clear = true })

vim.api.nvim_create_autocmd({ "InsertLeave", "CursorHold", "CursorHoldI" }, {
  group = autosave_group,
  callback = function()
    -- Only save if it's a real file
    if vim.fn.empty(vim.fn.expand("%:t")) ~= 1 and vim.bo.buftype == "" then
      if vim.bo.modified then
        vim.cmd("silent! write!")
        vim.notify("Autosaved: " .. vim.fn.expand("%:t"), vim.log.levels.INFO, {
          title = "Autosave",
          timeout = 500,
          render = "minimal",
        })
      end
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 100 })
  end,
})

-- https://www.youtube.com/watch?v=5PIiKDES_wc
local state = {
  floating = {
    buf = -1,
    win = -1,
  },
}

local create_floating_terminal = function(opts)
  opts = opts or {}
  local w = opts.width or math.floor(vim.o.columns * 0.8)
  local h = opts.height or math.floor(vim.o.lines * 0.8)

  local col = math.floor((vim.o.columns - w) / 2)
  local row = math.floor((vim.o.lines - h) / 2)

  local buf = nil
  if not vim.api.nvim_buf_is_valid(opts.buf) then
    buf = vim.api.nvim_create_buf(false, true)
  else
    buf = opts.buf
  end

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = w,
    height = h,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
  })

  return { buf = buf, win = win }
end

local toggle_terminal = function()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    -- Get the directory of the current file
    local current_file_dir = vim.fn.expand("%:p:h")

    state.floating = create_floating_terminal({ buf = state.floating.buf })
    if vim.bo[state.floating.buf].buftype ~= "terminal" then
      -- Launch terminal in the current file's directory
      vim.cmd.terminal()
      -- If it's a new terminal, we can send a 'cd' command or use the lcd command
      -- But the simplest way is to ensure the terminal starts in the right spot:
      vim.api.nvim_chan_send(vim.bo[state.floating.buf].channel, "cd " .. current_file_dir .. " && clear\n")
    end
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end

local state_j = {
  floating = {
    buf = -1,
    win = -1,
  },
}

local toggle_terminal_j = function()
  if not vim.api.nvim_win_is_valid(state_j.floating.win) then
    local current_file_dir = vim.fn.expand("%:p:h")
    state_j.floating = create_floating_terminal({ buf = -1 }) -- Always create a new buffer
    vim.cmd.terminal()
    vim.api.nvim_chan_send(vim.bo[state_j.floating.buf].channel, "cd " .. current_file_dir .. " && clear\n")
  else
    -- Delete the buffer and close the window
    if vim.api.nvim_buf_is_valid(state_j.floating.buf) then
      vim.api.nvim_buf_delete(state_j.floating.buf, { force = true })
    end
    state_j.floating.win = -1
  end
end

vim.api.nvim_create_user_command("ToggleFloatingTerminal", toggle_terminal, {})
vim.keymap.set({ "n", "t" }, "<C-h>", toggle_terminal, { desc = "[T]oggle Floating Terminal (Persistent)" })

vim.api.nvim_create_user_command("ToggleFloatingTerminalJ", toggle_terminal_j, {})
vim.keymap.set({ "n", "t" }, "<C-j>", toggle_terminal_j, { desc = "[T]oggle Floating Terminal (Follow & Reset)" })

-- Toggle highlights
local ns = vim.api.nvim_create_namespace("toggle_selection_highlight")
local active = false

function ToggleSelectionHighlight()
  local start_pos = vim.fn.getpos("'<")
  local end_pos   = vim.fn.getpos("'>")

  -- If no visual selection, do nothing
  if start_pos[2] == 0 or end_pos[2] == 0 then return end

  -- Clear previous highlight if active
  if active then
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    active = false
    return
  end

  -- Highlight the full range
  vim.highlight.range(
    0,                                      -- current buffer
    ns,                                     -- namespace
    "Visual",                               -- highlight group
    { start_pos[2] - 1, start_pos[3] - 1 }, -- start [line, col]
    { end_pos[2] - 1, end_pos[3] },         -- end [line, col]
    { inclusive = true }                    -- include end column
  )

  active = true
end

vim.api.nvim_set_keymap('v', '<leader>h', ':lua ToggleSelectionHighlight()<CR>', { noremap = true, silent = true })

vim.o.updatetime = 500
