return function()
  local lib = require("ts-refactor/lib")

  local node = vim.treesitter.get_node()

  if node == nil then
    vim.print("Cursor is not on a node.")
    return
  end

  local if_statement = lib.get_first_matching_ancestor(node, "if_statement")

  if if_statement == nil then
    vim.print("Not on an if statement")
    return
  end

  local alternative = lib.get_named_child(if_statement, "alternative")

  if alternative == nil then
    vim.print("Not on an if/else else statement")
    return
  end

  -- local consequence = lib.force_get_named_child(if_statement, "consequence")
  -- local contains_return = lib.find_child_of_type(consequence, "return_statement")
  local alternative_block = lib.find_child_of_type(alternative, "statement_block")

  if alternative_block == nil then
    error("No block found in else statement")
  end

  local alternative_contents = lib.get_block_contents(alternative_block)

  lib.replace_node_with_lines(alternative, { "", alternative_contents })
end
