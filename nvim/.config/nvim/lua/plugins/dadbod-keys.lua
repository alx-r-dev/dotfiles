-- ~/.config/nvim/lua/plugins/dadbod-keys.lua
return {
  {
    "kristijanhusak/vim-dadbod-ui",
    keys = {
      { "<leader>dc", "<cmd>DBUIAddConnection<cr>", desc = "DB: Add Connection" },
      { "<leader>dq", "<cmd>DBUILastQueryInfo<cr>", desc = "DB: Last Query Info" },

      -- Refresh DBUI (open if needed, then press R)
      {
        "<leader>df",
        function()
          local open = false
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "dbui" then
              open = true
              break
            end
          end
          if not open then
            vim.cmd("DBUI")
          end
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "dbui" then
              vim.api.nvim_set_current_win(win)
              vim.api.nvim_feedkeys("R", "n", false)
              break
            end
          end
        end,
        desc = "DB: Refresh UI",
      },

      -- Focus DBUI list (don’t refresh)
      {
        "<leader>dd",
        function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "dbui" then
              vim.api.nvim_set_current_win(win)
              return
            end
          end
          vim.cmd("DBUI") -- open if not present
        end,
        desc = "DB: Focus UI",
      },

      -- New, clean SQL buffer (connected); close the current buffer
      {
        "<leader>db",
        function()
          local cur = vim.api.nvim_get_current_buf()
          vim.cmd("enew") -- keep window, new buffer
          pcall(vim.api.nvim_buf_delete, cur, {}) -- close old buffer
          vim.bo.filetype = "sql"
          vim.bo.bufhidden = "wipe"
          -- seed connection from first vim.g.dbs entry if present
          local dsn
          if type(vim.g.dbs) == "table" then
            for _, v in pairs(vim.g.dbs) do
              dsn = v
              break
            end
          end
          if dsn then
            vim.b.db = dsn
          end
          vim.api.nvim_buf_set_name(0, "new_query.sql")
        end,
        desc = "DB: New Query (fresh buffer)",
      },
    },
  },

  {
    "tpope/vim-dadbod",
    keys = {
      -- Execute whole buffer
      {
        "<leader>dw",
        function()
          if vim.bo.filetype ~= "sql" then
            vim.bo.filetype = "sql"
          end
          if not vim.b.db and type(vim.g.dbs) == "table" then
            for _, dsn in pairs(vim.g.dbs) do
              vim.b.db = dsn
              break
            end
          end
          vim.cmd([[%DB]])
        end,
        mode = "n",
        desc = "DB: Execute Buffer",
      }, -- Execute visual selection
      { "<leader>dw", ":'<,'>DB<cr>", mode = "v", desc = "DB: Execute Selection" },
    },
  },

  -- Mac: Command- hjkl for window nav (note: terminal must pass ⌘ keys through)
  {
    -- any small always-loaded plugin is fine to host these mappings
    "nvim-lua/plenary.nvim",
    keys = {
      { "<D-h>", "<C-w>h", desc = "Window ←" },
      { "<D-j>", "<C-w>j", desc = "Window ↓" },
      { "<D-k>", "<C-w>k", desc = "Window ↑" },
      { "<D-l>", "<C-w>l", desc = "Window →" },
    },
  },
}
