vim.api.nvim_create_user_command("TsRefactor", function()
  local node = vim.treesitter.get_node()

  if node == nil then
    vim.print("Not a node")
    return
  end

  vim.print(node.type(node))
end, {
  desc = "ts-refactor.nvim",
})
