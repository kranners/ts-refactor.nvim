local M = {}

M.name = "Simplify if/else"

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

  local alternative = lib.get_named_child(if_statement, "alternative")

  if alternative == nil then
    -- vim.print("Not on an if/else else statement")
    return
  end

  local alternative_block = lib.deeply_find_child_of_type(alternative, "statement_block")

  if alternative_block == nil then
    -- vim.print("No block found in else statement")
    return
  end

  local consequence = lib.force_get_named_child(if_statement, "consequence")
  local consequence_block = lib.deeply_find_child_of_type(consequence, "statement_block")
  local consequence_return = lib.deeply_find_child_of_type(consequence, "return_statement")

  if consequence_block == nil then
    -- vim.print("No block found in if statement")
    return
  end

  return {
    if_statement = if_statement,
    alternative = alternative,
    alternative_block = alternative_block,
    consequence = consequence,
    consequence_block = consequence_block,
    consequence_return = consequence_return,
  }
end

M.make_edits = function()
  local lib = require("ts-refactor/lib")
  local nodes = M.parse_nodes()

  if nodes == nil then
    return
  end

  if nodes.consequence_return == nil then
    local block_text = lib.node_text(nodes.consequence_block)

    local second_line = block_text:match("\n([^\n]*)")

    local indentation = second_line:match("^(%s*)")

    lib.add_lines_to_block(nodes.consequence_block, { "", indentation .. "return;" })
    nodes = lib.reparse(M.parse_nodes)
  end

  local alternative_contents = lib.get_block_contents(nodes.alternative_block)
  lib.replace_node_with_text(nodes.alternative, "\n\n" .. alternative_contents)
end

return M
