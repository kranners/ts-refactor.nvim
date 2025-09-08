--- @class Action
--- @field name string
--- @field parse_nodes fun(): table|nil
--- @field make_edits fun(): nil

--- @type Action[]
return {
  require("ts-refactor.actions.simplify-if-else"),
  require("ts-refactor.actions.invert-and-simplify-if-else"),
  require("ts-refactor.actions.convert-ternary-to-if"),
  require("ts-refactor.actions.extract-iife"),
  require("ts-refactor.actions.replace-lodash-mapping-function"),
  require("ts-refactor.actions.convert-case-switch-to-if"),
}
