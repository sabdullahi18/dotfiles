return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	build = "cd app && npm install",
	ft = { "markdown" },
	config = function()
		vim.g.mkdp_auto_start = 1
		vim.g.mkdp_auto_close = 1
		vim.g.mkdp_refresh_slow = 0
		vim.g.mkdp_command_for_global = 0
		vim.g.mkdp_open_to_the_world = 0
		vim.g.mkdp_browser = ""
		vim.g.mkdp_echo_preview_url = 1
		vim.g.mkdp_preview_options = {
			katex = {},
			maid = {},
		}
	end,
	keys = {
		{ "<leader>mp", ":MarkdownPreview<CR>", desc = "Markdown Preview" },
		{ "<leader>ms", ":MarkdownPreviewStop<CR>", desc = "Markdown Preview Stop" },
		{ "<leader>mt", ":MarkdownPreviewToggle<CR>", desc = "Markdown Preview Toggle" },
	},
}
