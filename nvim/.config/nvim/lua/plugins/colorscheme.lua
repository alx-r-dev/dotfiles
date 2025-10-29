return {
  {
    "navarasu/onedark.nvim",
    lazy = false, -- Load immediately at startup.
    priority = 1000, -- High priority to override other settings.
    opts = {
      style = "cool", -- Use the "cool" style.
      transparent = false,
      term_colors = true,
      ending_tildes = false,
      cmp_itemkind_reverse = false,

      -- Code style options for various syntax elements.
      code_style = {
        comments = "italic",
        keywords = "none",
        functions = "none",
        strings = "none",
        variables = "none",
      },

      lualine = {
        transparent = false,
      },

      -- Customized "cool" palette with brighter, more poppy colors.
      colors = {
        black = "#151820",
        bg1 = "#242b38",
        bg0 = "#2d3343",
        bg2 = "#343e4f",
        bg3 = "#363c51",
        bg_d = "#3c465e", -- was "#1e242e"
        bg_blue = "#7bd0ff", -- was "#6db9f7"
        bg_yellow = "#ffdf9a", -- was "#f0d197"
        fg = "#ffffff", -- was "#a5b0c5"
        purple = "#cc54ff", -- was "#ca72e4"
        green = "#97e072", -- was "#97ca72"
        orange = "#ff951c", -- was "#d99a5e"
        blue = "#00e8c6", -- was "#5ab0f6"
        yellow = "#ffee6d", -- was "#ebc275"
        cyan = "#00e8c6", -- was "#4dbdcb"
        red = "#ff6a75", -- was "#ef5f6b"
        grey = "#6b758d", -- was "#546178"
        light_grey = "#95a1b3", -- was "#7d899f"
        dark_cyan = "#339090", -- was "#25747d"
        dark_red = "#bd3d3d", -- was "#a13131"
        dark_yellow = "#b27a1b", -- was "#9a6b16"
        dark_purple = "#a14cab", -- was "#8f36a9"
        diff_add = "#3a4f35", -- was "#303d27"
        diff_delete = "#483239", -- was "#3c2729"
        diff_change = "#224b6f", -- was "#18344c"
        diff_text = "#3270a1", -- was "#265478"
      },

      -- Highlight group overrides using our custom palette.
      highlights = {
        Normal = { fg = "$fg", bg = "$bg0" },
        ["@punctuation.bracket"] = { fg = "#ffee6d", bg = "none" },
        CursorLine = { bg = "$bg_d" },
        Comment = { fg = "$grey", fmt = "italic" },
        Keyword = { fg = "$purple" },
        Identifier = { fg = "$orange" },
        Statement = { fg = "$red" },
        PreProc = { fg = "$cyan" },
        Type = { fg = "$yellow" },
        TSKeyword = { fg = "$purple" },
        TSString = { fg = "$yellow", fmt = "bold" },
        TSFunction = { fg = "$blue", sp = "$cyan", fmt = "underline,italic" },
        TSFuncBuiltin = { fg = "$blue" },
        -- Add more groups as needed.
      },

      diagnostics = {
        darker = false,
        undercurl = true,
        background = true,
      },
    },
    config = function(_, opts)
      require("onedark").setup(opts) -- Setup onedark with the provided options.
      require("onedark").load() -- Load the theme.
    end,
  },
}

