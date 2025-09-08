local M = {}

M.name = "Replace lodash mapping function with ES equivalent"

--- @param name string
local is_mapping_function_name = function(name)
  return name == "map" or name == "filter" or name == "reduce" or name == "forEach"
end

--- @param expression TSNode
local get_call_expression_function_name = function(expression)
  local lib = require("ts-refactor/lib")

  local call_expression_function = lib.force_get_named_child(expression, "function")

  if call_expression_function:type() == "identifier" then
    return lib.node_text(call_expression_function)
  end

  if call_expression_function:type() == "member_expression" then
    local property = lib.force_get_named_child(call_expression_function, "property")

    return lib.node_text(property)
  end

  return nil
end

M.parse_nodes = function()
  local lib = require("ts-refactor/lib")

  local node = vim.treesitter.get_node()

  if node == nil then
    return
  end

  local call_expression = lib.get_first_matching_ancestor(node, "call_expression")

  if call_expression == nil then
    return
  end

  local function_name = get_call_expression_function_name(call_expression)

  if function_name == nil then
    return
  end

  if not is_mapping_function_name(function_name) then
    return
  end

  local arguments = lib.force_get_named_child(call_expression, "arguments")
  local variable_identifer = arguments:child(1)
  local callback_function = arguments:child(3)

  if variable_identifer == nil or callback_function == nil then
    return
  end

  return {
    call_expression = call_expression,
    variable_identifer = variable_identifer,
    callback_function = callback_function,
    function_name = function_name,
  }
end

M.make_edits = function()
  local lib = require("ts-refactor/lib")

  local nodes = M.parse_nodes()

  if nodes == nil then
    return
  end

  local replacement_call_expression = string.format(
    "%s.%s(%s)",
    lib.node_text(nodes.variable_identifer),
    nodes.function_name,
    lib.node_text(nodes.callback_function)
  )

  lib.replace_node_with_text(nodes.call_expression, replacement_call_expression)
end

return M
