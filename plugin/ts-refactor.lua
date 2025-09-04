vim.api.nvim_create_user_command("TsRefactor", function()
  vim.print("Hey there bucko")
end, {
  desc = "ts-refactor.nvim",
})
