local M = {}

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
    error("Child with field name " .. field_name .. " not found")
  end

  return field_children[next_index]
end

--- @param node TSNode
--- @param type string
--- @return TSNode?
M.find_child_of_type = function(node, type)
  if node:type() == type then
    return node
  end

  for child in node:iter_children() do
    if M.find_child_of_type(child, type) ~= nil then
      return child
    end
  end

  return nil
end

--- @param block TSNode
--- @return string
M.get_block_contents = function(block)
  if block:type() ~= "statement_block" then
    error("Expected a statement_block, got a " .. block:type())
  end

  local buf = vim.api.nvim_get_current_buf()
  local block_text = vim.treesitter.get_node_text(block, buf)

  local inner_content = block_text:gsub("^%s*{", ""):gsub("}%s*$", "")
  return vim.trim(inner_content)
end

--- @param old TSNode
--- @param lines string[]
M.replace_node_with_lines = function(old, lines)
  local buf = vim.api.nvim_get_current_buf()

  local start_row, start_col, end_row, end_col = old:range()

  vim.api.nvim_buf_set_text(buf, start_row, start_col, end_row, end_col, lines)
end

return M
