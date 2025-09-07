local M = {}

M.name = "Convert ternary to if/else statements"

M.parse_nodes = function()
  local lib = require("ts-refactor/lib")

  local node = vim.treesitter.get_node()

  if node == nil then
    -- vim.print("Cursor is not on a node.")
    return
  end

  local ternary_expression = lib.get_first_matching_ancestor(node, "ternary_expression")

  if ternary_expression == nil then
    -- vim.print("Not on a ternary expression")
    return
  end

  return {
    ternary_expression = ternary_expression,
  }
end

--- @param ternary_expression TSNode
--- @param previous_indentation string
--- @param is_first_expression boolean
local function construct_if_else_statement(ternary_expression, previous_indentation, is_first_expression)
  local lib = require("ts-refactor/lib")

  local indentation = previous_indentation .. lib.get_indentation_unit()

  local condition = lib.force_get_named_child(ternary_expression, "condition")
  local consequence = lib.force_get_named_child(ternary_expression, "consequence")
  local alternative = lib.force_get_named_child(ternary_expression, "alternative")

  --- @param node TSNode
  local make_expression_statement = function(node)
    if node:type() == "ternary_expression" then
      return construct_if_else_statement(node, indentation, false)
    end

    return string.format("return %s;", lib.node_text(node))
  end

  -- 1u
  -- 4u + 3
  -- 6u + 4
  -- wtf??
  --

  local get_first_if_indentation = function()
    if is_first_expression then
      return lib.get_indentation_unit()
    end

    return ""
  end

  return string.format(
    "%sif (%s) {\n%s%s\n%s} else {\n%s%s\n%s}",
    get_first_if_indentation(),
    lib.node_text(condition),
    indentation .. lib.get_indentation_unit(),
    make_expression_statement(consequence),
    indentation,
    indentation .. lib.get_indentation_unit(),
    make_expression_statement(alternative),
    indentation
  )
end

M.make_edits = function()
  local lib = require("ts-refactor/lib")

  local nodes = M.parse_nodes()

  if nodes == nil then
    return
  end

  local ternary_expression_indentation = lib.node_indentation(nodes.ternary_expression)

  vim.print("'" .. ternary_expression_indentation .. "'")

  local ternary_as_if_else = construct_if_else_statement(nodes.ternary_expression, ternary_expression_indentation, true)

  -- need to wrap the resulting statement in an iife to make the returns make sense
  local iife = string.format(
    "(() => {\n%s%s\n%s})()",
    ternary_expression_indentation,
    ternary_as_if_else,
    ternary_expression_indentation
  )

  lib.replace_node_with_text(nodes.ternary_expression, iife)
end

return M
