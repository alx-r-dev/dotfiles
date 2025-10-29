if true then
  return {}
end

return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local transform_mod = require("telescope.actions.mt").transform_mod
    local trouble = require("trouble")
    local trouble_telescope = require("trouble.sources.telescope")

    local custom_actions = transform_mod({
      open_trouble_qflist = function()
        trouble.toggle("quickfix")
      end,
    })

    telescope.setup({
      defaults = {
        path_display = { "smart" },
        -- ⬇️ ignore these files/folders everywhere
        file_ignore_patterns = {
          "node_modules/.*",
          "package.json",
          "package%-lock.json",
          "%.lock$",
        },
        -- ⬇️ ripgrep args for live_grep / grep_string, etc.
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--glob",
          "!node_modules/*",
          "--glob",
          "!package.json",
          "--glob",
          "!package-lock.json",
          "--glob",
          "!*.lock",
        },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
            ["<C-t>"] = trouble_telescope.open,
          },
        },
      },

      pickers = {
        live_grep = {
          -- if you ever want to *add* ignores on top of the above defaults,
          -- you could use additional_args instead of redefining vimgrep_arguments:
          -- additional_args = function()
          --   return { "--glob", "!*.test.js" }
          -- end,
        },
      },

      extensions = {
        file_browser = {
          hijack_netrw = true,
          mappings = {
            n = {
              ["a"] = telescope.extensions.file_browser.actions.create,
            },
          },
        },
      },
    })

    -- load extensions
    telescope.load_extension("fzf")
    telescope.load_extension("file_browser")

    -- your existing mappings
    local km = vim.keymap
    km.set("n", "<leader>ff", function()
      require("telescope.builtin").find_files({ hidden = true })
    end, { desc = "Find files (incl. hidden)" })
    km.set("n", "<leader>fr", require("telescope.builtin").oldfiles, { desc = "Recent files" })
    km.set("n", "<leader>fs", require("telescope.builtin").live_grep, { desc = "Live grep" })
    km.set("n", "<leader>fc", require("telescope.builtin").grep_string, { desc = "Grep word under cursor" })
    km.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find TODOs" })
    km.set("n", "<leader>fb", "<cmd>Telescope file_browser<cr>", { desc = "File browser" })
    km.set("n", "<leader>gs", function()
      require("telescope.builtin").git_status({
        layout_config = { width = 0.8, height = 0.6 },
        prompt_title = " Changed Files",
      })
    end, { desc = "Git status (changed files)" })
  end,
}
