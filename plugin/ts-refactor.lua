vim.api.nvim_create_autocmd("FileType", {
  pattern = "typescript",
  callback = function(args)
    vim.treesitter.start(args.buf)
  end,
})

vim.api.nvim_create_user_command("TsRefactor", function()
  local actions = require("ts-refactor/actions")
  actions.simplify_if_else()
end, {
  desc = "ts-refactor.nvim",
})
