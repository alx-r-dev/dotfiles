local M = {}

local sep = package.config:sub(1, 1)
local NOTES_DIR = vim.fn.expand(vim.env.NOTES_DIR or "~/Notes")
local last_explorer_dir

local function join(...)
  return table.concat({ ... }, sep)
end

local function ensure_dir(path)
  if path ~= "" and vim.fn.isdirectory(path) == 0 then
    vim.fn.mkdir(path, "p")
  end
end

local function explorer_at(dir, opts)
  ensure_dir(dir)
  last_explorer_dir = dir
  local S = require("snacks")
  local open_explorer = (S.explorer and S.explorer.open) or S.explorer
  open_explorer(vim.tbl_extend("force", { cwd = dir, toggle = true }, opts or {}))
end

function M.setup()
  -- single command to open your notes vault in Snacks Explorer
  vim.api.nvim_create_user_command("NotesOpen", function()
    explorer_at(NOTES_DIR)
  end, {})
end

return M
