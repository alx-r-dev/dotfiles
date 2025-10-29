-- ── helpers (top of file) ───────────────────────────────────────────────
local uv = vim.uv or vim.loop

-- absolute repo root
local SD_GITHUB = vim.fn.fnamemodify("/Users/Work/Documents/sd_github", ":p")

local function list_repos(base)
  base = vim.fn.fnamemodify(base, ":p")
  if vim.fn.isdirectory(base) == 0 then
    return {}
  end
  local out = {}
  for _, name in ipairs(vim.fn.readdir(base)) do
    if name:sub(1, 1) ~= "." and vim.fn.isdirectory(base .. "/" .. name) == 1 then
      out[#out + 1] = { name = name, path = base .. "/" .. name }
    end
  end
  table.sort(out, function(a, b)
    return a.name:lower() < b.name:lower()
  end)
  return out
end

-- repo chooser for <leader>sr
local function pick_repo_and_open()
  local dirs = list_repos(SD_GITHUB)
  if #dirs == 0 then
    vim.notify("No repos found in " .. SD_GITHUB, vim.log.levels.WARN)
    return
  end
  vim.ui.select(
    vim.tbl_map(function(d)
      return d.name
    end, dirs),
    { prompt = "Open repo" },
    function(choice)
      if not choice then
        return
      end
      for _, d in ipairs(dirs) do
        if d.name == choice then
          require("snacks").picker.files({ cwd = d.path })
          break
        end
      end
    end
  )
end

-- ── plugin spec ─────────────────────────────────────────────────────────
return {
  {
    "folke/snacks.nvim",
    -- if you want latest Snacks API, keep version=false and run :Lazy sync
    -- version = false,
    priority = 1000,
    lazy = false,

    opts = {

      bufdelete = { quit = true },
      dashboard = {
        enabled = true,
        width = 56,
        formats = {
          file = function(item, ctx)
            local name = vim.fn.fnamemodify(item.file or "", ":t")
            -- ctx.width is provided by Snacks for the center column. Use it to pad so
            -- the autokeys column aligns perfectly.
            return { { name, hl = "file", align = "left", width = (ctx and ctx.width) or #name } }
          end,
        },
        preset = {
          keys = {
            {
              icon = " ",
              key = "f",
              desc = "Find File",
              action = function()
                Snacks.dashboard.pick("files")
              end,
            },
            {
              icon = " ",
              key = "n",
              desc = "New File",
              action = function()
                vim.cmd("ene | startinsert")
              end,
            },
            {
              icon = " ",
              key = "g",
              desc = "Find Text",
              action = function()
                Snacks.dashboard.pick("live_grep")
              end,
            },
            {
              icon = " ",
              key = "r",
              desc = "Recent",
              action = function()
                Snacks.dashboard.pick("oldfiles")
              end,
            },
            {
              icon = " ",
              key = "c",
              desc = "Config",
              action = function()
                Snacks.dashboard.pick("files", { cwd = vim.fn.stdpath("config") })
              end,
            },
            {
              icon = " ",
              key = "q",
              desc = "Quit",
              action = function()
                vim.cmd("qa")
              end,
            },
          },
        },

        sections = {
          { section = "header", padding = 1, align = "center" }, -- ← back on
          { section = "keys", gap = 1, padding = 1 },
        },
      },

      -- modules you asked for
      picker = { enabled = true },
      notifier = { enabled = true },
      gitbrowse = {},
      lazygit = {},
      input = { enabled = false },
      quickfile = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      -- words = { enabled = true },
      explorer = {
        enabled = true,
        keymaps = {
          ["a"] = "new", -- new file/folder
          ["A"] = "new_dir", -- (optional) force new folder
          ["d"] = "delete",
          ["r"] = "rename", -- <-- rename the selected file/folder
          ["R"] = "rename", -- (optional) uppercase alias
        },
      },
    },

    keys = function()
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { desc = desc })
      end

      -- --- Snacks Explorer helpers (add these) -----------------------------
      local S = require("snacks")
      -- Snacks changed API in recent builds: support both
      local open_explorer = (S.explorer and S.explorer.open) or S.explorer

      local function project_root()
        local ok, Util = pcall(require, "lazyvim.util")
        if ok and Util.root then
          return Util.root.get()
        end
        return (vim.uv or vim.loop).cwd() or vim.fn.getcwd()
      end

      local NOTES_DIR = vim.fn.expand(vim.env.NOTES_DIR or "~/Notes")

      -- Grep word under cursor (Snacks)
      map("n", "gc", function()
        require("snacks").picker.grep({ search = vim.fn.expand("<cword>") })
      end, "Grep <cword>")

      -- Project explorer (popup) – toggles if already open at same cwd
      map("n", "<leader>e", function()
        open_explorer({ cwd = project_root(), toggle = true })
      end, "Explorer (Snacks @ project root)")

      -- Notes explorer (popup) – toggles if already open at notes dir
      map("n", "<leader>ne", function()
        open_explorer({ cwd = NOTES_DIR, toggle = true })
      end, "Explorer (Snacks @ notes)")

      -- --------------------------------------------------------------------
      map("n", "<leader>ff", function()
        require("snacks").picker.files()
      end, "Find Files")
      map("n", "<leader>fs", function()
        require("snacks").picker.grep()
      end, "Grep")
      map("n", "<leader>fc", function()
        local word = vim.fn.expand("<cword>")
        if not word or word == "" then
          return
        end
        require("snacks").picker.grep({
          search = word,
          live = false, -- open results immediately
          args = { "--fixed-strings", "--word-regexp" }, -- whole-word, literal match (ripgrep)
        })
      end, "Find mentions of word under cursor")
      map("n", "<leader>,", function()
        require("snacks").picker.buffers()
      end, "Buffers")
      map("n", "<leader>fr", function()
        require("snacks").picker.recent()
      end, "Recent Files")
      map("n", "<leader>sk", function()
        require("snacks").picker.keymaps()
      end, "Search Keymaps")

      -- repos-only chooser (folders from /Users/Work/Documents/sd_github)
      map("n", "<leader>sr", pick_repo_and_open, "Repos in /Users/Work/Documents/sd_github")
      map("n", "<leader>s", function()
        require("user.cheatsheet").open()
      end, "Custom Cheatsheet")

      if vim.fn.executable("lazygit") == 1 then
        local uv_cwd = (vim.uv or vim.loop).cwd and (vim.uv or vim.loop).cwd() or vim.fn.getcwd()
        map("n", "<leader>gg", function()
          require("snacks").lazygit({ cwd = uv_cwd })
        end, "Lazygit (cwd)")
      end

      map({ "n", "x" }, "<leader>gB", function()
        require("snacks").gitbrowse()
      end, "Git Browse (open)")
      map({ "n", "x" }, "<leader>gY", function()
        require("snacks").gitbrowse({
          open = function(url)
            vim.fn.setreg("+", url)
          end,
          notify = false,
        })
      end, "Git Browse (copy URL)")
    end,
  },
}
