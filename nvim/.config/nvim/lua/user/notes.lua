local M = {}

-- --- basics ---------------------------------------------------------------
local sep = package.config:sub(1, 1)
local NOTES_DIR = vim.fn.expand(vim.env.NOTES_DIR or "~/Notes")
local last_explorer_dir -- remembers the last Snacks Explorer cwd we opened

local function join(...)
  return table.concat({ ... }, sep)
end
local function ensure_dir(path)
  if path ~= "" and vim.fn.isdirectory(path) == 0 then
    vim.fn.mkdir(path, "p")
  end
end
local function slugify(str)
  return (str or ""):gsub("[^%w%s%-_]", ""):gsub("%s+", "-"):gsub("%-+", "-"):lower()
end
local function write_if_new(path, lines)
  ensure_dir(vim.fn.fnamemodify(path, ":h"))
  if vim.fn.filereadable(path) == 0 then
    vim.fn.writefile(lines or { "" }, path)
  end
end
local function open_file(path, lines_if_new)
  write_if_new(path, lines_if_new)
  vim.cmd.edit(vim.fn.fnameescape(path))
end

-- --- paths ----------------------------------------------------------------
local function index_path()
  return join(NOTES_DIR, "index.md")
end
local function daily_path()
  local y, m, d = os.date("%Y"), os.date("%m"), os.date("%Y-%m-%d")
  return join(NOTES_DIR, "daily", y, m, d .. ".md")
end

-- --- Snacks Explorer ------------------------------------------------------
local function explorer_at(dir, opts)
  ensure_dir(dir)
  last_explorer_dir = dir
  local S = require("snacks")
  local open_explorer = (S.explorer and S.explorer.open) or S.explorer
  open_explorer(vim.tbl_extend("force", { cwd = dir, toggle = true }, opts or {}))
end

-- --- index & daily --------------------------------------------------------
local function open_index()
  open_file(index_path(), {
    "# Notes Index",
    "",
    "- [daily](daily/)",
    "- [notes](notes/)",
    "- [projects](projects/)",
    "- [templates](templates/)",
  })
end

local function open_daily()
  local d = os.date("%Y-%m-%d")
  open_file(daily_path(), {
    "> [!NOTE] Daily ToDos",
    "> " .. d,
    "",
    "# Tasks",
    "",
    "- ",
    "",
    "## Notes",
    "",
    "- ",
    "",
    "## What went well",
    "",
    "- ",
    "",
    "## What didn't go well",
    "",
    "- ",
  })
end

-- --- create note in *current* folder -------------------------------------
local function current_dir_in_vault()
  if last_explorer_dir and last_explorer_dir:sub(1, #NOTES_DIR) == NOTES_DIR then
    return last_explorer_dir
  end
  local buf = vim.fn.expand("%:p")
  if buf ~= "" and buf:sub(1, #NOTES_DIR) == NOTES_DIR then
    return vim.fn.fnamemodify(buf, ":h")
  end
  return NOTES_DIR
end

local function new_note_here()
  local base = current_dir_in_vault()
  vim.ui.input({ prompt = "Note (title or path): " }, function(raw)
    if not raw or #raw == 0 then
      return
    end
    raw = raw:gsub("\\", "/"):gsub("%s+$", "")
    local is_vault_abs = raw:sub(1, 1) == "/"
    local dir_part = raw:match("^(.*)/")
    local name_part = (raw:match("([^/]+)$") or raw)
    name_part = name_part:gsub("%.md$", "")
    local filename = slugify(name_part) .. ".md"

    local target_dir
    if dir_part and #dir_part > 0 then
      if is_vault_abs then
        dir_part = dir_part:gsub("^/*", "")
        local clean = dir_part:gsub("/", sep)
        target_dir = join(NOTES_DIR, clean)
      else
        local rel = dir_part:gsub("^%./", "")
        local clean = rel:gsub("/", sep)
        target_dir = join(base, clean)
      end
    else
      target_dir = base
    end

    ensure_dir(target_dir)
    local path = join(target_dir, filename)
    local d = os.date("%Y-%m-%d")
    open_file(path, { "> [!NOTE] " .. name_part, ">", "> " .. d })
  end)
end

-- --- follow link to explorer ----------------------------------------------
local function follow_index_link_to_explorer()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local target

  -- [text](target)
  local i = 1
  while true do
    local s, e, inner = line:find("()%b[]%((.-)%)()", i)
    if not s then
      break
    end
    if col >= s and col <= e then
      target = inner
      break
    end
    i = e + 1
  end
  -- [[wiki]]
  if not target then
    i = 1
    while true do
      local s, e, inner = line:find("()%[%[%s*(.-)%s*%]%]()", i)
      if not s then
        break
      end
      if col >= s and col <= e then
        target = inner
        break
      end
      i = e + 1
    end
  end
  if not target or #target == 0 then
    return
  end
  target = target:gsub("^%s+", ""):gsub("%s+$", ""):gsub("^%./", "")

  local abs = join(NOTES_DIR, target)
  if target:sub(-1) == "/" then
    abs = abs:sub(1, -2)
  end

  if vim.fn.isdirectory(abs) == 1 or target:sub(-1) == "/" then
    explorer_at(abs, { toggle = true })
  else
    open_file(abs)
  end
end

-- --- Snacks search ---------------------------------------------------------
local function files()
  require("snacks").picker.files({ cwd = NOTES_DIR, hidden = true, follow = true })
end
local function grep()
  require("snacks").picker.grep({ cwd = NOTES_DIR, hidden = true })
end

-- optional fallback (unused once autolist owns <CR>)
local function md_smart_cr()
  local ok, al = pcall(require, "autolist")
  if ok then
    return al.new()
  end
  local line = vim.api.nvim_get_current_line()
  local indent = line:match("^%s*") or ""
  if line:match("^%s*[-*+] %[[ xX%-]%]") then
    return "\n" .. indent .. "- [ ] "
  end
  local bullet = line:match("^%s*([-*+])%s+")
  if bullet then
    return "\n" .. indent .. bullet .. " "
  end
  local num = line:match("^%s*(%d+)%.%s+")
  if num then
    return "\n" .. indent .. (tonumber(num) + 1) .. ". "
  end
  if line:match("^%s*#+%s+Tasks%s*$") then
    return "\n" .. indent .. "- [ ] "
  end
  return "\n"
end

-- --- setup ----------------------------------------------------------------
function M.setup()
  -- commands
  vim.api.nvim_create_user_command("NotesIndex", open_index, {})
  vim.api.nvim_create_user_command("NotesDaily", open_daily, {})
  vim.api.nvim_create_user_command("NotesNew", new_note_here, {})
  vim.api.nvim_create_user_command("NotesFiles", files, {})
  vim.api.nvim_create_user_command("NotesGrep", grep, {})

  -- keymaps
  local map = vim.keymap.set
  map("n", "<leader>nv", open_index, { desc = "Notes: index" })
  map("n", "<leader>ne", function()
    explorer_at(NOTES_DIR)
  end, { desc = "Notes: Explorer (Snacks)" })
  map("n", "<leader>nn", new_note_here, { desc = "Notes: new in current folder" })
  map("n", "<leader>nd", open_daily, { desc = "Notes: today's daily" })
  map("n", "<leader>nf", files, { desc = "Notes: find (Snacks)" })
  map("n", "<leader>ng", grep, { desc = "Notes: grep (Snacks)" })

  -- Markdown QoL + special behavior on index.md
  vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
      if vim.bo.filetype ~= "markdown" then
        return
      end

      -- QoL
      vim.opt_local.conceallevel = 2
      vim.opt_local.spell = true
      vim.opt_local.wrap = true
      vim.opt_local.linebreak = true

      -- DO NOT map <CR> in insert here — autolist owns it.
      -- If autolist is missing, enable our fallback:
      if not package.loaded["autolist"] then
        vim.keymap.set("i", "<CR>", md_smart_cr, { buffer = true, expr = true, desc = "MD: smart newline (fallback)" })
      end

      local this = vim.fn.expand("%:p")
      local idx = (function()
        local s = package.config:sub(1, 1)
        return NOTES_DIR .. s .. "index.md"
      end)()
      if this == idx then
        -- On index.md, <CR> follows link to Snacks Explorer (normal mode)
        vim.keymap.set(
          "n",
          "<CR>",
          follow_index_link_to_explorer,
          { buffer = true, desc = "Notes: open Explorer at link" }
        )
      else
        -- Don't steal <CR> in normal mode (autolist toggles checkbox there).
        -- Provide a separate key to start a new task item:
        vim.keymap.set("n", "<leader>tt", function()
          return "o- [ ] "
        end, { buffer = true, expr = true, desc = "MD: start new task item" })
      end
    end,
  })
end

return M
