-- ~/.config/nvim/lua/plugins/markdown-look.lua
return {
  -- Treesitter (needed by both plugins)

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts = opts or {}
      opts.ensure_installed = opts.ensure_installed or {}
      for _, l in ipairs({ "markdown", "markdown_inline" }) do
        if not vim.tbl_contains(opts.ensure_installed, l) then
          table.insert(opts.ensure_installed, l)
        end
      end
      opts.highlight = opts.highlight or {}
      opts.highlight.enable = true

      -- ⬇️ IMPORTANT: turn off TS indent just for markdown
      opts.indent = opts.indent or {}
      opts.indent.enable = true
      local disable = opts.indent.disable or {}
      if not vim.tbl_contains(disable, "markdown") then
        table.insert(disable, "markdown")
      end
      if not vim.tbl_contains(disable, "markdown_inline") then
        table.insert(disable, "markdown_inline")
      end
      opts.indent.disable = disable
    end,
  },

  -- Render Markdown: lists/checkboxes/callouts/code/tables/indent (NOT headings)

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" }, -- add "mdx" if you need it
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = function(_, opts)
      opts = opts or {}
      local function norm(tbl, key, extra)
        local v = tbl[key]
        if type(v) == "boolean" then
          tbl[key] = vim.tbl_extend("force", { enabled = v }, extra or {})
        end
      end

      -- your desired behavior
      opts.file_types = { "markdown" }
      opts.render_modes = { "n", "i" }
      opts.checkbox = true

      norm(opts, "heading", { icons = { "(1)", "(2)", "(3)", "(4)", "(5)", "(6)" } })
      norm(opts, "bullet", { icons = { "●", "◦", "▪" } })
      norm(opts, "indent", { character = "│" })
      norm(opts, "anti_conceal")
      norm(opts, "checkbox")
      norm(opts, "callout")
      norm(opts, "code")
      norm(opts, "table")

      return opts
    end,

    config = function(_, opts)
      require("render-markdown").setup(opts)

      local function set_blockquote_color()
        vim.api.nvim_set_hl(0, "@punctuation.special.markdown", { fg = "#00e8c6" })
      end

      set_blockquote_color()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = set_blockquote_color,
      })
    end,
  },

  -- Full-width TWO-LINE header bars + color pinning
  {
    "lukas-reineke/headlines.nvim",
    version = false, -- unpin; ensure latest so fat_headlines works
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      markdown = {
        headline_highlights = { "MDH1", "MDH2", "MDH3", "MDH4", "MDH5", "MDH6" },
        bullets = {},
        fat_headlines = false,
        fat_headline_upper_string = "▄",
        fat_headline_lower_string = "▀",
      },
    },
    config = function(_, opts)
      require("headlines").setup(opts)

      -- ======= COLORS: bright HFG from your screenshot + softer Andromeda-ish HBG =======
      local HFG = { "#00e8c6", "#ffa930", "#3bed4a", "#3ebced", "#a068fc", "#ff8bd1" }

      -- mix `a` (hex) toward `b` by t (0..1)
      local function hex2rgb(h)
        h = h:gsub("#", "")
        return tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16)
      end
      local function rgb2hex(r, g, b)
        return ("#%02x%02x%02x"):format(r, g, b)
      end
      local function mix(a, b, t)
        local ar, ag, ab = hex2rgb(a)
        local br, bg, bb = hex2rgb(b)
        local r = math.floor(ar + (br - ar) * t + 0.5)
        local g = math.floor(ag + (bg - ag) * t + 0.5)
        local bl = math.floor(ab + (bb - ab) * t + 0.5)
        return rgb2hex(r, g, bl)
      end

      -- base = your editor background
      local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
      local base_bg = normal and normal.bg and ("#" .. string.format("%06x", normal.bg)) or "#1e1e2e"

      -- gentle tints to blend with base (lighter / less harsh)
      local TINTS = { "#60a8a1", "#9a6b1f", "#2f7d49", "#1e6a87", "#4d3d7a", "#7a2b5e" }
      local HBG = {}
      for i = 1, 6 do
        HBG[i] = mix(base_bg, TINTS[i], 0.22)
      end -- 22% toward tint

      local function HL(g, spec)
        vim.api.nvim_set_hl(0, g, spec)
      end
      for i = 1, 6 do
        -- headlines (two-line bars)
        HL(("MDH%d"):format(i), { fg = HFG[i], bg = HBG[i], bold = true })
        -- keep render-markdown / treesitter in lockstep with the same colors
        HL(("RenderMarkdownH%d"):format(i), { fg = HFG[i], bg = HBG[i], bold = true })
        HL(("RenderMarkdownH%dBg"):format(i), { bg = HBG[i] })
        HL(("@markup.heading.%d.markdown"):format(i), { fg = HFG[i], bold = true })
        HL(("@markup.heading.%d"):format(i), { fg = HFG[i], bold = true })
      end
      -- bullets + indent rail
      HL("RenderMarkdownBullet", { fg = "#ff9e64" })
      HL("RenderMarkdownListMarker", { fg = "#ff9e64" })
      HL("RenderMarkdownIndent", { fg = mix(base_bg, "#7a849e", 0.45) })

      -- re-apply on theme switch and force a redraw
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          for i = 1, 6 do
            vim.api.nvim_set_hl(0, ("MDH%d"):format(i), { fg = HFG[i], bg = HBG[i], bold = true })
            vim.api.nvim_set_hl(0, ("RenderMarkdownH%d"):format(i), { fg = HFG[i], bg = HBG[i], bold = true })
            vim.api.nvim_set_hl(0, ("RenderMarkdownH%dBg"):format(i), { bg = HBG[i] })
            vim.api.nvim_set_hl(0, ("@markup.heading.%d.markdown"):format(i), { fg = HFG[i], bold = true })
            vim.api.nvim_set_hl(0, ("@markup.heading.%d"):format(i), { fg = HFG[i], bold = true })
          end
          require("headlines").refresh()
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(ev)
          vim.keymap.set("n", "<leader>ii", function()
            require("user.md_image_paste").paste()
          end, { buffer = ev.buf, desc = "Paste image → assets/ and insert link" })
        end,
      })
    end,
  },

  {
    "3rd/image.nvim",
    ft = { "markdown" },
    opts = {
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = true,
          only_render_image_at_cursor = true,
          -- "popup" = float near cursor, "inline" = inline overlay
          only_render_image_at_cursor_mode = "popup",
        },
      },
      -- optional clamp so the preview isn't huge
      max_width_window_percentage = 70,
      max_height_window_percentage = 50,
    },
  },

  {
    "dkarter/bullets.vim",
    ft = { "text", "gitcommit" }, -- <-- no markdown here
    init = function()
      vim.g.bullets_set_mappings = 0
    end,
  },

  -- --- autolist.nvim: the only list driver for Markdown -----------------------
  {
    "gaoDean/autolist.nvim",
    ft = { "markdown", "norg", "tex", "plaintex", "text" },
    config = function()
      require("autolist").setup({})

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(ev)
          local buf = ev.buf

          -- kill extra indent engines
          vim.bo[buf].indentexpr = ""
          vim.opt_local.smartindent = false
          vim.opt_local.cindent = false
          vim.opt_local.autoindent = true

          -- formatoptions: no auto-continue comments/lists; keep numbered recog
          vim.opt_local.formatoptions:remove({ "c", "r", "o" })
          vim.opt_local.formatoptions:append({ "n" })

          -- nuke any preexisting insert-mode <CR> in this buffer (cmp/autopairs/etc.)
          pcall(vim.keymap.del, "i", "<CR>", { buffer = buf })

          -- Insert mode (use commands, not Lua functions)
          vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>", { buffer = buf, desc = "Autolist: newline" })
          vim.keymap.set("i", "<Tab>", "<cmd>AutolistTab<cr>", { buffer = buf, desc = "Autolist: indent" })
          vim.keymap.set("i", "<S-Tab>", "<cmd>AutolistShiftTab<cr>", { buffer = buf, desc = "Autolist: dedent" })

          -- Normal mode
          vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>", { buffer = buf, desc = "Autolist: new below" })
          vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>", { buffer = buf, desc = "Autolist: new above" })
          vim.keymap.set(
            "n",
            "<CR>",
            "<cmd>AutolistToggleCheckbox<cr><CR>",
            { buffer = buf, desc = "Autolist: toggle" }
          )

          -- Keep numbers aligned after shifts/deletes
          vim.keymap.set("n", ">>", ">>:AutolistRecalculate<CR>", { buffer = buf, silent = true })
          vim.keymap.set("n", "<<", "<<:AutolistRecalculate<CR>", { buffer = buf, silent = true })
          vim.keymap.set("n", "dd", "dd:AutolistRecalculate<CR>", { buffer = buf, silent = true })
          vim.keymap.set("v", "d", "d:AutolistRecalculate<CR>", { buffer = buf, silent = true })
        end,
      })
    end,
  },
}
