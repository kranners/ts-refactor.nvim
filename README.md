<h1>
<p align="center">
    🤓
  <br>ts-refactor.nvim
</h1>
  <p align="center">
    A Neovim plugin for quickly refactoring TypeScript and JavaScript.
  </p>
</p>

Functionality based on [Nodash](https://github.com/kranners/nodash) and
[eslint-plugin-nodash](https://github.com/kranners/eslint-plugin-nodash).

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim#-plugin-spec)

Install using a plugin spec like:
```lua
return {
  "kranners/ts-refactor.nvim",
  keys = {
    {
      "<Leader><Leader>",
      function()
        require("ts-refactor").open_action_menu()
      end,
      mode = "n",
      desc = "Open action menu",
    },
  },
}
```

If having issues with the TypeScript grammar not loading automatically, disable
lazy-loading for this plugin:
```lua
return {
  "kranners/ts-refactor.nvim",
  lazy = false,
}
```

## Usage

Show all available actions with either:
```lua
require("ts-refactor").show_action_menu()
```

Or by running `:TsRefactor`.

### Available actions

#### Replace if/else with early return

Takes in an if statement like:
```typescript
if (condition) {
  something;
} else {
  return else;
}
```

And converts it to:
```typescript
if (condition) {
  something;

  return;
} 

return else;
```

If there is no return statement, one will be added, otherwise the
existing one won't be touched.

## Similar

A very lazy search turned up:
- [ThePrimeagen/refactoring.nvim: The Refactoring library based off the Refactoring book by Martin Fowler](https://github.com/ThePrimeagen/refactoring.nvim)
- [nvim-treesitter/nvim-treesitter-refactor: Refactor module for nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter-refactor)
- [pmizio/typescript-tools.nvim: ⚡ TypeScript integration NeoVim deserves ⚡](https://github.com/pmizio/typescript-tools.nvim)
- [tiyashbasu/refactor.nvim: A simple neovim plugin for refactoring code](https://github.com/tiyashbasu/refactor.nvim)
- [synic/refactorex.nvim: Neovim plugin for RefactorEx](https://github.com/synic/refactorex.nvim)

