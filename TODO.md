# `TODO`

## Project setup

- [x] Init repository
- [x] Write the beginnings of a README
- [x] Write the TODO
- [x] Do an initial commit

## To investigate

- [x] How do Neovim plugins work (the plugin folder?)
- [ ] How to read in and parse a treesitter AST
- [ ] How to expose a command which runs a function
- [ ] How to use `vim.ui.select` or `vim.ui` in general

## Plugin setup

- [ ] Write a dummy plugin which can be `setup()`
- [x] Write a dummy command which prints hello world
- [x] Write a dummy command which gets the current node using treesitter
- [ ] Write a dummy command which makes a trivial AST edit and writes it back
- [ ] Write a dummy command which displays a select menu and then does the trivial AST

## Refactors

Each refactor should be comprised of a few things:
1. Display information (what is displayed in the select menu, what the command is called)
2. A function which says if that is valid or not
3. A function which performs the AST edit

### Features to write

- [ ] Convert ternary statement to if/else IIFE
- [ ] Simplify if/else statement into early return
- [ ] Invert and simplify if/else statement into early return
- [ ] Split IIFE into declaration and call expression
- [ ] Case switch to if

