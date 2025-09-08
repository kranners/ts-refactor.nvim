local M = {}

M.name = "Convert case switch into if statements"

M.parse_nodes = function()
  local lib = require("ts-refactor/lib")

  local node = vim.treesitter.get_node()

  if node == nil then
    -- vim.print("Cursor is not on a node.")
    return
  end

  local switch_statement = lib.get_first_matching_ancestor(node, "switch_statement")

  if switch_statement == nil then
    -- vim.print("Not on a switch statement")
    return
  end

  local parenthesized_expression = lib.get_named_child(switch_statement, "value")

  if parenthesized_expression == nil then
    return
  end

  if parenthesized_expression:type() ~= "parenthesized_expression" then
    return
  end

  local switch_body = lib.get_named_child(switch_statement, "body")

  return {
    switch_statement = switch_statement,
    parenthesized_expression = parenthesized_expression,
    switch_body = switch_body,
  }
end

M.make_edits = function()
  local lib = require("ts-refactor/lib")

  local nodes = M.parse_nodes()

  if nodes == nil then
    return
  end

  local switch_comparison_text = lib.unwrapped_parenthesized_expression(nodes.parenthesized_expression)
  local switch_indentation = lib.node_indentation(nodes.switch_statement)

  --- @type boolean
  local is_first_if_statement = true

  local get_if_statement_indentation = function()
    if is_first_if_statement then
      is_first_if_statement = false
      return ""
    end

    return switch_indentation
  end

  --- @type string[]
  local conditions_for_statement = {}

  --- @param switch_statement TSNode
  local function construct_if_from_switch_statement(switch_statement)
    local body_statement_indentation = switch_indentation .. lib.get_indentation_unit()

    if switch_statement:type() == "switch_default" then
      local statement_body = lib.force_get_named_child(switch_statement, "body")

      return switch_indentation .. lib.node_text(statement_body)
    end

    local case_value = lib.force_get_named_child(switch_statement, "value")

    local if_statement_condition = string.format("%s === %s", switch_comparison_text, lib.node_text(case_value))

    local statement_body = lib.get_named_child(switch_statement, "body")

    if statement_body == nil then
      table.insert(conditions_for_statement, if_statement_condition)
      return
    end

    table.insert(conditions_for_statement, if_statement_condition)
    local joined_if_statement_condition = table.concat(conditions_for_statement, " || ")
    conditions_for_statement = {}

    local statement_body_without_breaks = lib.node_text(statement_body):gsub("break", "return")

    return string.format(
      "%sif (%s) {\n%s%s\n%s}\n",
      get_if_statement_indentation(),
      joined_if_statement_condition,
      body_statement_indentation,
      statement_body_without_breaks,
      switch_indentation
    )
  end

  local switch_statements = lib.node_children_without_first_or_last(nodes.switch_body)

  --- @type string[]
  local if_statements = {}

  for _, switch_statement in ipairs(switch_statements) do
    local if_statement_or_nil = construct_if_from_switch_statement(switch_statement)

    if if_statement_or_nil ~= nil then
      table.insert(if_statements, if_statement_or_nil)
    end
  end

  lib.replace_node_with_text(nodes.switch_statement, table.concat(if_statements, "\n"))
end

return M
