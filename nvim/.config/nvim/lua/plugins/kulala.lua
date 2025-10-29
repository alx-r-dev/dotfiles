return {
  {
    "mistweaverco/kulala.nvim",
    event = "VeryLazy",
    keys = function()
      local dir = vim.fn.stdpath("data") .. "/kulala" -- ~/.local/share/nvim/kulala
      local pad = dir .. "/requests.http"

      local function open_pad()
        vim.cmd("lcd " .. dir) -- make Kulala look here for the env
        vim.cmd.edit(pad) -- open the pad
        vim.bo.filetype = "http" -- ensure ft so Kulala activates
        -- if you use nested env blocks, select one once:
        pcall(require("kulala").set_selected_env, "dev")
      end

      local function run_here(fn)
        -- temporarily run from the global dir so {{vars}} resolve
        local prev = vim.fn.getcwd()
        vim.cmd("lcd " .. dir)
        local ok, err = pcall(fn)
        vim.cmd("lcd " .. prev)
        if not ok then
          vim.notify(err, vim.log.levels.ERROR)
        end
      end

      vim.api.nvim_create_user_command("KulalaEnvEdit", function()
        vim.cmd.edit(vim.fn.stdpath("data") .. "/kulala/http-client.env.json")
      end, {})

      return {
        { "<leader>rb", open_pad, desc = "Open global HTTP pad" },
        {
          "<leader>rs",
          function()
            run_here(function()
              require("kulala").run()
            end)
          end,
          desc = "Send request",
        },
        {
          "<leader>rt",
          function()
            require("kulala").toggle_view()
          end,
          desc = "Toggle response view",
        },
        { "<leader>rw", "<C-w>w", desc = "Toggle request/response window" },
        { "<leader>re", "<cmd>KulalaEnvEdit<cr>", desc = "Edit Kulala env" },
      }
    end,
  },
}
