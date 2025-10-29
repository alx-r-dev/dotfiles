return {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {
    modes = {
      search = { enabled = true },
    },
  },
  config = function(_, opts)
    require("flash").setup(opts)

    local set_hl = vim.api.nvim_set_hl
    local highlights = {
      -- FlashBackdrop = { fg = "#545c7e" },
      FlashCurrent = { bg = "#c98002", fg = "#ffffff" },
      FlashLabel = { bg = "#ff007c", fg = "#ffffff", bold = true },
      FlashMatch = { bg = "#3e68d7", fg = "#ffffff" },
      FlashCursor = { reverse = true },
    }

    for group, spec in pairs(highlights) do
      set_hl(0, group, spec)
    end

    -- make sure overrides stick if colorscheme changes
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        for group, spec in pairs(highlights) do
          set_hl(0, group, spec)
        end
      end,
    })
  end,
  keys = {
    {
      "s",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Flash",
    },
    {
      "S",
      mode = { "n", "x", "o" },
      function()
        require("flash").treesitter()
      end,
      desc = "Flash Treesitter",
    },
    {
      "r",
      mode = "o",
      function()
        require("flash").remote()
      end,
      desc = "Remote Flash",
    },
    {
      "R",
      mode = { "o", "x" },
      function()
        require("flash").treesitter_search()
      end,
      desc = "Treesitter Search",
    },
    {
      "<c-s>",
      mode = { "c" },
      function()
        require("flash").toggle()
      end,
      desc = "Toggle Flash Search",
    },
  },
}
