local M = {}

M.name = "Extract IIFE to arrow function and call expression"

M.parse_nodes = function()
  local lib = require("ts-refactor/lib")

  local node = vim.treesitter.get_node()

  if node == nil then
    -- vim.print("Cursor is not on a node.")
    return
  end

  local variable_declarator = lib.get_first_matching_ancestor(node, "variable_declarator")

  if variable_declarator == nil then
    -- vim.print("Not on a variable declaration")
    return
  end

  local identifer = lib.get_named_child(variable_declarator, "name")

  if identifer == nil then
    -- vim.print("No name in variable declaration")
    return
  end

  local call_expression = lib.get_named_child(variable_declarator, "value")

  if call_expression == nil then
    -- vim.print("No value in variable declaration")
    return
  end

  local parenthesized_expression = lib.get_named_child(call_expression, "function")

  if parenthesized_expression == nil then
    -- vim.print("No parenthesized_expression in call_expression")
    return
  end

  if parenthesized_expression:type() ~= "parenthesized_expression" then
    return
  end

  if identifer:type() ~= "identifier" then
    return
  end

  if call_expression:type() ~= "call_expression" then
    -- vim.print("Value of variable declaration is not a call expression")
    return
  end

  return {
    variable_declarator = variable_declarator,
    identifer = identifer,
    call_expression = call_expression,
    parenthesized_expression = parenthesized_expression,
  }
end

--- @param to_be_capitalized string
local function capitalize_first_letter(to_be_capitalized)
  return (to_be_capitalized:gsub("^%l", string.upper))
end

M.make_edits = function()
  local lib = require("ts-refactor/lib")

  local nodes = M.parse_nodes()

  if nodes == nil then
    return
  end

  -- get the parenthesized expression
  -- make the variable name
  -- which is `get` plus the identifier capitalized
  local identifier_text = lib.node_text(nodes.identifer)
  local function_name = "get" .. capitalize_first_letter(identifier_text)

  -- maybe replace the variable with the function
  -- and then the function call
  local replacement = string.format(
    "%s = %s;\n\n%sconst %s = %s",
    function_name,
    lib.unwrapped_parenthesized_expression(nodes.parenthesized_expression),
    lib.node_indentation(nodes.variable_declarator),
    lib.node_text(nodes.identifer),
    string.format("%s()", function_name)
  )

  lib.replace_node_with_text(nodes.variable_declarator, replacement)
end

return M
