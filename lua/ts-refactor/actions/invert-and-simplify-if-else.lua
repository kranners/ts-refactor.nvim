local M = {}

M.name = "Invert and simplify if/else"

M.parse_nodes = function()
  local lib = require("ts-refactor/lib")

  local node = vim.treesitter.get_node()

  if node == nil then
    -- vim.print("Cursor is not on a node.")
    return
  end

  local if_statement = lib.get_first_matching_ancestor(node, "if_statement")

  if if_statement == nil then
    -- vim.print("Not on an if statement")
    return
  end

  local condition = lib.get_named_child(if_statement, "condition")

  if condition == nil then
    -- vim.print("If statement has no condition (how?)")
    return
  end

  local alternative = lib.get_named_child(if_statement, "alternative")

  if alternative == nil then
    -- vim.print("Not on an if/else else statement")
    return
  end

  local alternative_block = lib.deeply_find_child_of_type(alternative, "statement_block")
  local alternative_return = lib.deeply_find_child_of_type(alternative, "return_statement")

  if alternative_block == nil then
    -- vim.print("No block found in else statement")
    return
  end

  local consequence = lib.force_get_named_child(if_statement, "consequence")
  local consequence_block = lib.deeply_find_child_of_type(consequence, "statement_block")

  if consequence_block == nil then
    -- vim.print("No block found in if statement")
    return
  end

  return {
    if_statement = if_statement,
    condition = condition,
    alternative = alternative,
    alternative_block = alternative_block,
    alternative_return = alternative_return,
    consequence = consequence,
    consequence_block = consequence_block,
  }
end

M.make_edits = function()
  local lib = require("ts-refactor/lib")

  local nodes = M.parse_nodes()

  if nodes == nil then
    return
  end

  lib.invert_boolean_statement(nodes.condition)
  nodes = lib.reparse(M.parse_nodes)

  if nodes.alternative_return == nil then
    local return_indentation = lib.node_indentation(nodes.if_statement)
    local new_return_statement = return_indentation .. "return;"

    lib.add_lines_to_block(nodes.alternative_block, { "", new_return_statement })
    nodes = lib.reparse(M.parse_nodes)
  end

  local consequence_contents = lib.get_block_contents(nodes.consequence_block)

  local alternative_replacement = "\n\n" .. lib.node_indentation(nodes.if_statement) .. consequence_contents

  lib.replace_node_with_node(nodes.alternative_block, nodes.consequence_block)
  nodes = lib.reparse(M.parse_nodes)
  lib.replace_node_with_text(nodes.alternative, alternative_replacement)
end

return M
