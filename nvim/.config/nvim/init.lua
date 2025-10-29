-- 1) your leader
vim.g.mapleader = " "

-- prefer root for searches and grepping
vim.g.root_spec = { { ".root", ".git" }, "lsp", "cwd" }
-- 2) bootstrap LazyVim
require("config.lazy")
-- Now override defaults AFTER LazyVim
vim.opt.clipboard = "" -- keep global sync OFF

local map = vim.keymap.set
-- yanks go to system clipboard explicitly
map({ "n", "x" }, "y", '"+y')
map("n", "Y", '"+Y')

-- deletes/changes go to black-hole
map({ "n", "x" }, "d", '"_d', { desc = "Delete (black hole)" })
map({ "n", "x" }, "D", '"_D')
map({ "n", "x" }, "c", '"_c', { desc = "Change (black hole)" })
map({ "n", "x" }, "C", '"_C')
map({ "n", "x" }, "x", '"_x')
map({ "n", "x" }, "X", '"_X')
map({ "n", "x" }, "s", '"_s')
map({ "n", "x" }, "S", '"_S')

-- be extra explicit for line ops
map("n", "dd", '"_dd')
map("n", "cc", '"_cc')
-- 3) visual and select‑mode mapping to uppercase the selection
vim.keymap.set(
  { "v", "s" }, -- "v" = Visual mode, "s" = Select mode (Shift+Arrows)
  "<leader>u",
  "gU", -- in Visual/Select, gU uppercases the selection
  { noremap = true, silent = true }
)

-- 2) Make `y` in Visual mode copy to system clipboard
vim.keymap.set("v", "y", '"+y', { noremap = true, silent = true })

-- 3) Shift+Arrows start & stop selection like GUI editors
vim.opt.keymodel = "startsel,stopsel"
vim.opt.selection = "exclusive"

-- bootstrap lazy.nvim, LazyVim and your plugins

-- 1) Mappings for quick save
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>W", ":wa<CR>", { desc = "Save all files" })

-- 2) Treat .env.* as shell scripts for syntax highlighting
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { ".env.*" },
  callback = function()
    vim.bo.filetype = "sh"
  end,
})

-- 3) Strip out any ^M before saving .env files
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.env",
  command = "silent! %s/\\r//g",
})

vim.o.showtabline = 0

-- set the tabline to expand to the full file path
-- %F = full file path, %f = filename only
vim.o.tabline = ""

-- Toggle LSP hover: open if closed, close if open
local function toggle_hover()
  -- find any floating windows
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg.relative ~= "" then
      -- it’s a float: close it!
      vim.api.nvim_win_close(win, true)
      return
    end
  end
  -- no float found → open hover
  vim.lsp.buf.hover()
end

-- Map <leader>h to our toggle
vim.keymap.set("n", "<leader>h", toggle_hover, { desc = "Toggle LSP Hover" })

vim.api.nvim_set_keymap(
  "t", -- terminal-mode
  "<Esc>", -- key you press
  "<C-\\><C-n>", -- what it sends
  { silent = true, noremap = true }
)

vim.keymap.set({ "n", "v" }, "<C-d>", "<C-d>zz", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<C-u>", "<C-u>zz", { noremap = true, silent = true })

-- map <leader>cl to our “log this prop” helper
vim.keymap.set("n", "<leader>cn", function()
  -- 1) yank the prop name
  local prop = vim.fn.expand("<cword>")

  -- 2) save cursor so we can come back
  local save_cursor = vim.api.nvim_win_get_cursor(0)

  -- 3) find the start of the function body
  if vim.fn.search("=> {", "W") > 0 then
    -- go one line down, into the braces
    vim.cmd("normal! j")

    -- figure out how much indent is on THIS line
    local indent_spaces = vim.fn.indent(".")
    local indent = string.rep(" ", indent_spaces)

    -- 4) insert our log statement
    vim.api.nvim_put(
      { indent .. "console.log('" .. prop .. "', " .. prop .. ");" },
      "l", -- put after the current line
      false, -- don't re-select the put text
      true -- keep autoindent off (we manually added it)
    )
  end

  -- 5) jump back to the original prop
  vim.api.nvim_win_set_cursor(0, save_cursor)
end, {
  noremap = true,
  silent = true,
  desc = "Log current prop under cursor",
})

-- Use service names; creds come from ~/.pgpass or env

vim.g.dbs = {
  ["dev/postgres"] = "postgresql:///?service=dev&dbname=postgres",
  ["dev/vsnx"] = "postgresql:///?service=dev&dbname=vsnx",
  ["dev/community_2024_07"] = "postgresql:///?service=dev&dbname=community_2024_07",
}

-- Nice to have for DBUI
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_auto_execute_table_helpers = 1

--#region

-- trigger your <leader>, mapping when you hit F10
-- vim.keymap.set("n", ",", "<leader>,", {
--   remap = true, -- allow it to call your existing <leader>, mapping
--   silent = true,
--   desc = "Open buffer list", -- heads‑up for :which-key (or LSP)
-- })

-- makes easy way to create a new file in the current folder
-- vim.api.nvim_create_user_command("Nf", function(opts)
--   -- %:h = current buffer’s directory
--   local dir = vim.fn.expand("%:h")
--   local file = opts.args
--   vim.cmd("edit " .. dir .. "/" .. file)
-- end, { nargs = 1, complete = "file" })

-- keymap to open toggleable cheatpad

-- === Global Cheatpad command + keymap (works in any repo/profile) ===
-- do
--   local function load_cheatpad()
--     -- 1) If already loaded, just return it
--     local ok, mod = pcall(require, "cheatpad")
--     if ok and type(mod) == "table" then
--       return mod
--     end
--
--     -- 2) Make sure your config dir is on runtimepath (in case something clobbered it)
--     local cfg = vim.fn.stdpath("config")
--     if not vim.o.runtimepath:find(cfg, 1, true) then
--       vim.opt.runtimepath:append(cfg)
--     end
--
--     -- 3) Find the module anywhere on runtimepath
--     local hits = vim.api.nvim_get_runtime_file("/cheatpad.lua", true)
--     local path = hits[1] or (cfg .. "/cheatpad.lua")
--     if vim.fn.filereadable(path) == 1 then
--       local mod2 = dofile(path) -- load directly
--       package.loaded["cheatpad"] = mod2 -- register for future require()
--       return mod2
--     end
--
--     vim.notify("Cheatpad not found. Expected at: " .. path, vim.log.levels.ERROR)
--     return nil
--   end
--
--   vim.api.nvim_create_user_command("Cheatpad", function()
--     local cp = load_cheatpad()
--     if cp and cp.toggle then
--       cp.toggle()
--     end
--   end, {})
--
--   -- if you don't like the accidental '>' above, use "<leader>ch" exactly:
--   vim.keymap.set("n", "<leader>ch", "<cmd>Cheatpad<CR>", { desc = "Toggle Cheatpad", silent = true })
-- end
