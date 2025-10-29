return {
	"nvim-neotest/neotest",
	dependencies = {
	  "nvim-neotest/nvim-nio",
	  "nvim-lua/plenary.nvim",
	  "antoinemadec/FixCursorHold.nvim",
	  "nvim-treesitter/nvim-treesitter",
	  "marilari88/neotest-vitest",
	  "nvim-neotest/neotest-jest",
	},
	keys = {
	  { "<leader>tr", function() require("neotest").run.run() end, desc = "Run test under cursor" },
	  { "<leader>tn", function() require("neotest").run.run() end, desc = "Run nearest" },
	  { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run current file" },
	  { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" },
	  { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Open test output" },
	  { "<leader>ta", function() require("neotest").run.run() end, desc = "Run whole project" },
	},
	config = function()
	  local function nearest_pkg_root(path)
		local hit = vim.fs.find(
			{ "package.json", "jest.config.js", "jest.config.ts", "vitest.config.ts", "vitest.config.js", "vite.config.ts", "vite.config.js" },
		  { upward = true, type = "file", path = path }
		)[1]
	  return hit and vim.fs.dirname(hit) or vim.loop.cwd()
	  end
  
	  require("neotest").setup({
		adapters = {
		  require("neotest-vitest")({
			-- Use npm so we don't depend on pnpm/yarn being in Neovim's PATH
			vitestCommand = "npm run test --",
			cwd = function(path) return nearest_pkg_root(path) end,
			-- match both __tests__ and *.test.tsx files
			is_test_file = function(file)
			  return file:match("__tests__/.+%.tsx?$")
				  or file:match("%.test%.tsx?$")
				  or file:match("%.spec%.tsx?$")
			end,
			filter_dir = function(name) return name ~= "node_modules" and name ~= "dist" and name ~= "build" end,
		  }),
		},
	  })
	end,
  }
  