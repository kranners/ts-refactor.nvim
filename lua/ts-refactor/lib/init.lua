local M = {}

--- @param node TSNode
M.node_text = function(node)
  local buf = vim.api.nvim_get_current_buf()
  return vim.treesitter.get_node_text(node, buf)
end

--- @param node TSNode
M.node_indentation = function(node)
  local start_row = node:start() -- or use tsnode:range() for more info
  local line = vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)[1]
  if not line then
    return ""
  end
  -- Match and return the leading whitespace characters only
  local leading_ws = line:match("^(%s*)")
  return leading_ws or ""
end

--- @param parse_nodes fun(): table|nil
M.reparse = function(parse_nodes)
  local nodes = parse_nodes()

  if nodes == nil then
    error("State of nodes changed!")
  end

  return nodes
end

--- @param node TSNode
--- @param type string
--- @return TSNode?
M.get_first_matching_ancestor = function(node, type)
  while node do
    if node:type() == type then
      return node
    end

    local parent = node:parent()

    if parent == nil then
      return nil
    end

    node = parent
  end

  return nil
end

--- @param node TSNode
--- @param field_name string
--- @return TSNode?
M.get_named_child = function(node, field_name)
  local field_children = node:field(field_name)
  local next_index = next(field_children)

  if next_index == nil then
    return nil
  end

  return field_children[next_index]
end

--- @param node TSNode
--- @param field_name string
--- @return TSNode
M.force_get_named_child = function(node, field_name)
  local field_children = node:field(field_name)
  local next_index = next(field_children)

  if next_index == nil then
    error("vim.ui.Child with field name " .. field_name .. " not found")
  end

  return field_children[next_index]
end

--- @param node TSNode
--- @param type string
--- @return TSNode?
M.get_child_of_type = function(node, type)
  for child in node:iter_children() do
    if child:type() == type then
      return child
    end
  end

  return nil
end

--- @param node TSNode
--- @param type string
--- @return TSNode?
M.deeply_find_child_of_type = function(node, type)
  if node:type() == type then
    return node
  end

  for child in node:iter_children() do
    if M.deeply_find_child_of_type(child, type) ~= nil then
      return child
    end
  end

  return nil
end

--- @param node TSNode
M.dedented_node_text = function(node)
  local indent_unit = M.get_indentation_unit()

  local lines = {}
  for line in M.node_text(node):gmatch("([^\n]*)\n?") do
    table.insert(lines, line)
  end

  for i, line in ipairs(lines) do
    if line:sub(1, #indent_unit) == indent_unit then
      lines[i] = line:sub(#indent_unit + 1)
    end
  end

  return table.concat(lines, "\n")
end

--- @param block TSNode
--- @return string
M.get_block_contents = function(block)
  if block:type() ~= "statement_block" then
    error("Expected a statement_block, got a " .. block:type())
  end

  local block_text = M.dedented_node_text(block)
  local inner_content = block_text:gsub("^%s*{", ""):gsub("}%s*$", "")
  return vim.trim(inner_content)
end

--- @param expression TSNode
--- @return string
M.unwrapped_parenthesized_expression = function(expression)
  if expression:type() ~= "parenthesized_expression" then
    error("Expected a parenthesized_expression, got a " .. expression:type())
  end

  local expression_text = M.node_text(expression)
  local inner_content = expression_text:gsub("^%s*%(", ""):gsub("%)%s*$", "")
  return vim.trim(inner_content)
end

--- @param old TSNode
--- @param lines string[]
M.replace_node_with_lines = function(old, lines)
  local buf = vim.api.nvim_get_current_buf()

  local start_row, start_col, end_row, end_col = old:range()

  vim.api.nvim_buf_set_text(buf, start_row, start_col, end_row, end_col, lines)
end

--- @param old TSNode
--- @param text string
M.replace_node_with_text = function(old, text)
  local lines = vim.split(text, "\n", { plain = true })
  return M.replace_node_with_lines(old, lines)
end

--- @param source TSNode
--- @param destination TSNode
M.replace_node_with_node = function(source, destination)
  local source_node_text = M.node_text(source)
  local source_node_lines = vim.split(source_node_text, "\n", { plain = true })

  M.replace_node_with_lines(destination, source_node_lines)
end

--- @param block TSNode
--- @param lines string[]
M.add_lines_to_block = function(block, lines)
  if block:type() ~= "statement_block" then
    error("Expected a statement_block, got a " .. block:type())
  end

  local block_text = M.node_text(block)

  local new_block_text = block_text:gsub("}%s*$", table.concat(lines, "\n") .. "\n}")
  local new_block_lines = vim.split(new_block_text, "\n", { plain = true })
  M.replace_node_with_lines(block, new_block_lines)
end

--- @param statement TSNode
M.is_inverted_expression = function(statement)
  -- An inverted statement has 3 children
  -- { "(", unary_expression, ")" }

  if statement:child_count() ~= 3 then
    vim.print("statement has " .. statement:child_count() .. " children")
    return false
  end

  local unary_expression = M.get_child_of_type(statement, "unary_expression")

  if unary_expression == nil then
    vim.print("there is no unary expression")
    return false
  end

  local operator = M.get_named_child(unary_expression, "operator")

  if operator == nil then
    vim.print("there is no operator (somehow)")
    return false
  end

  return operator:type() == "!"
end

--- @param statement TSNode
M.invert_boolean_statement = function(statement)
  local statement_text = M.node_text(statement)

  if M.is_inverted_expression(statement) then
    vim.print("this IS ACTUALLY inverted")

    local uninverted_statement_text = statement_text:gsub("!", "", 1)
    local uninverted_statement_lines = vim.split(uninverted_statement_text, "\n", { plain = true })
    M.replace_node_with_lines(statement, uninverted_statement_lines)
    return
  end

  vim.print("this isnt inverted")

  local inverted_statement_text = "(!" .. statement_text .. ")"
  local inverted_statement_lines = vim.split(inverted_statement_text, "\n", { plain = true })
  return M.replace_node_with_lines(statement, inverted_statement_lines)
end

M.get_indentation_unit = function()
  local shiftwidth = vim.api.nvim_get_option_value("shiftwidth", {})
  local use_spaces = vim.api.nvim_get_option_value("expandtab", {})

  if use_spaces then
    return string.rep(" ", shiftwidth)
  end

  return "\t"
end

return M
