# `TODO`

## Project setup

- [ ] Init repository
- [ ] Write the beginnings of a README
- [ ] Write the TODO
- [ ] Do an initial commit

## To investigate

- [ ] How do Neovim plugins work (the plugin folder?)
- [ ] How to read in and parse a treesitter AST
- [ ] How to expose a command which runs a function
- [ ] How to use `vim.ui.select` or `vim.ui` in general

## Plugin setup

- [ ] Write a dummy plugin which can be `setup()`
- [ ] Write a dummy command which prints hello world
- [ ] Write a dummy command which gets the current node using treesitter
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

