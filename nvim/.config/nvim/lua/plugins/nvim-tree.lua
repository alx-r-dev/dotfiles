-- ~/.config/nvim/lua/plugins/formatting.lua (or wherever you configure neo-tree)
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  lazy = false,
  opts = {
    filesystem = {
      filtered_items = {
        hide_dotfiles = false, -- show *.*
        hide_gitignored = false, -- show files in .gitignore (e.g. your .env)
        hide_by_name = {
          ".git",
          ".DS_Store",
        },
        always_show = { ".env" }, -- extra belt-and-suspenders
      },
    },
  },
}
