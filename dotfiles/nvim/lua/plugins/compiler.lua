return {
	{ -- This plugin
		"Zeioth/compiler.nvim",
		cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
		dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
		config = function()
			-- Optional: Set up key mappings for compiler.nvim
			vim.api.nvim_set_keymap("n", "<F6>", "<cmd>CompilerOpen<cr>", { noremap = true, silent = true })
			vim.api.nvim_set_keymap(
				"n",
				"<S-F6>",
				"<cmd>CompilerStop<cr>" -- (Optional, to dispose all tasks before redo)
					.. "<cmd>CompilerRedo<cr>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap("n", "<S-F7>", "<cmd>CompilerToggleResults<cr>", { noremap = true, silent = true })
		end,
	},
	{ -- The task runner we use
		"stevearc/overseer.nvim",
		commit = "6271cab7ccc4ca840faa93f54440ffae3a3918bd",
		config = function()
			require("overseer").setup({
				task_list = {
					direction = "bottom",
					min_height = 25,
					max_height = 25,
					default_detail = 1,
				},
			})
		end,
	},
}
