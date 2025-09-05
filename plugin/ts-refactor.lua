vim.api.nvim_create_autocmd("FileType", {
  pattern = "typescript",
  callback = function(args)
    vim.treesitter.start(args.buf)
  end,
})

vim.api.nvim_create_user_command("TsRefactor", function()
  require("ts-refactor").open_action_menu()
end, {
  desc = "ts-refactor.nvim",
})
