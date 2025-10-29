return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      sections = {
        lualine_c = {
          { "filename", path = 1, shorting_target = 0 }, -- relative to cwd (project root)
        },
      },
    },
  },
}
