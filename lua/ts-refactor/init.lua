local M = {}

M.open_action_menu = function()
  local actions = require("ts-refactor/actions")

  local available_actions = vim.tbl_filter(
    --- @param action Action
    function(action)
      return action.parse_nodes() ~= nil
    end,
    actions
  )

  local available_action_names = vim.tbl_map(
    --- @param action Action
    function(action)
      return action.name
    end,
    available_actions
  )

  --- @param action_name string|nil
  local select_action = function(action_name)
    if action_name == nil then
      return
    end

    local actions_with_name = vim.tbl_filter(
      --- @param action Action
      function(action)
        return action.name == action_name
      end,
      actions
    )

    if #actions_with_name ~= 1 then
      error("Found multiple actions with name " .. action_name)
    end

    local action = actions_with_name[1]
    action.make_edits()
  end

  local select_options = {
    prompt = "Available actions",
  }

  vim.ui.select(available_action_names, select_options, select_action)
end

return M
