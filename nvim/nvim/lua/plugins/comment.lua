-- gcc to comment line, gc to comment highlighted area, gc{value} to comment that
return {
	"numToStr/Comment.nvim",
	event = "VeryLazy",
	config = function()
		require("Comment").setup()
	end,
}
