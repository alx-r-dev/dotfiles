-- lua/plugins/lualine.lua
return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        globalstatus = true,
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
      })

      -- keep your filename config
      opts.sections = vim.tbl_deep_extend("force", opts.sections or {}, {
        lualine_c = {
          { "filename", path = 1, shorting_target = 0, padding = { left = 1, right = 1 } },
        },
      })
    end,
  },
}
