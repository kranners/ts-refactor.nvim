<h1>
<p align="center">
    ☝️🤓
  <br>ts-refactor.nvim
</h1>
  <p align="center">
    A Neovim plugin for quickly refactoring TypeScript and JavaScript.
  </p>
</p>

<p align="center">
 <img src="./assets/demo.gif" alt="A demonstration converting a lengthy ternary with a nicer function" />
</p>

This is a few Treesitter-based code editing actions for TS and JS with a select
menu to wrap them together.

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

#### Simplify if/else

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

If the consequence of the if statement already has a return, then it will be
preserved, like:
```typescript
// Takes in
if (language === "en") {
  return "Hey there";
} else {
  return "☟︎♏︎⍓︎ ⧫︎♒︎♏︎❒︎♏︎";
}

// Outputs
if (language === "en") {
  return "Hey there";
} 

return "☟︎♏︎⍓︎ ⧫︎♒︎♏︎❒︎♏︎"; 
```

#### Invert and simplify if/else

Takes an if/else statement like:
```typescript
if (isAdmin) {
  doTheHappyPath();

  makeThingsHappen();

  lotsOfCodeInThisOneBlock();
} else {
  console.error("Not an admin!");
}
```

And converts it to:
```typescript
if (!(isAdmin)) {
  console.error("Not an admin!");

  return;
}

doTheHappyPath();

makeThingsHappen();

lotsOfCodeInThisOneBlock();
```

If the condition is already inverted, then the `!` will be removed instead.
```typescript
// Takes in
if (!(condition !== a_different_thing)) {
  something;
} else {
  return else;
}

// Outputs
if ((condition !== a_different_thing)) {
  return else;
}

something;
```

#### Convert ternary to if/else statements

Takes in an arbitrarily nested ternary expression, like:
```typescript
const formattedTime = !start.isSame(end, "day")
  ? !start.isSame(end, "month")
    ? !start.isSame(end, "year")
      ? start.format("ddd D MMM 'YY") + " - " + end.format("ddd D MMM 'YY")
      : start.format("ddd D MMM") + " - " + end.format("ddd D MMM 'YY")
    : start.format("ddd D") + " - " + end.format("ddd D MMM 'YY")
  : start.format("ddd D MMM 'YY");
```

And converts it into an IIFE with if/else statements that return like:
```typescript
const formattedTime = (() => {
  if (!start.isSame(end, "day")) {
    if (!start.isSame(end, "month")) {
      if (!start.isSame(end, "year")) {
        return start.format("ddd D MMM 'YY") + " - " + end.format("ddd D MMM 'YY");
      } else {
        return start.format("ddd D MMM") + " - " + end.format("ddd D MMM 'YY");
      }
    } else {
      return start.format("ddd D") + " - " + end.format("ddd D MMM 'YY");
    }
  } else {
    return start.format("ddd D MMM 'YY");
  }
})();
```

#### Extract IIFE to arrow function and call expression

Takes in any variable declared as the result of an IIFE, like:
```typescript
const menu = (() => {
  const info = doSomeLogic();

  return constructMenu(info);
})();
```

And converts it into a seperate function and a call expression:
```typescript
const getMenu = () => {
  const info = doSomeLogic();

  return constructMenu(info);
};

const menu = getMenu();
```

#### Replace lodash mapping function with ES equivalent

Takes in a lodash mapping function call expression, like:
```typescript
const numbers = [2, 3, 5, 21];

// Supports if the function was imported specifically
const doubled = map(numbers, (number) => {
  return number * 2;
});

// Or if the lodash module was imported as a whole
const doubled = _.map(numbers, (number) => number * 2);

_.forEach(numbers, (number) => push_to_cloud(number));

const greaterThanTwo = _.filter(numbers, (number) => number > 2);
```

And converts it into its' equivalent ES function:
```typescript
const numbers = [2, 3, 5, 21];

const doubled = numbers.map((number) => {
  return number * 2;
});

const doubled = numbers.map((number) => number * 2);

numbers.forEach((number) => push_to_cloud(number));

const greaterThanTwo = numbers.filter((number) => number > 2);
```


## Similar

[ts-node-action](https://github.com/CKolkey/ts-node-action) - Custom language-agnostic treesitter actions

