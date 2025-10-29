-- ~/.config/nvim/lua/plugins/formatting.lua
return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      -- only the filetypes you actually want formatted
      formatters_by_ft = {
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        svelte = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
        liquid = { "prettier" },
        lua = { "stylua" },
        python = { "isort", "black" },
        sql = { "pg_format" },
        terraform = { "terraform_fmt" },
        ["terraform-vars"] = { "terraform_fmt" }, -- .tfvars
        hcl = { "terraform_fmt" },
      },

      -- hard-disable format-on-save for http buffers
      -- format_on_save = function(bufnr)
      --   if vim.bo[bufnr].filetype == "http" then
      --     return nil -- disable
      --   end
      --   return { timeout_ms = 500, lsp_fallback = true }
      -- end,

      formatters = {
        prettier = {
          args = { "--stdin-filepath", "$FILENAME", "--trailing-comma", "none" },
        },
      },
    },

    keys = {
      {
        "<leader>mp",
        function()
          require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 1000 })
        end,
        mode = { "n", "v" },
        desc = "Format file or selection",
      },
    },
  },
}
