function getCardContent(cardType) {
  switch (cardType) {
    case "banana":
    case "menu":
      console.log("No content");
      break;
    case "apple":
      return "Apples are red and crunchy. Usually. Maybe.";
    default:
      return "Click here to buy fantastic products:";
  }
}

const numbers = [2, 3, 5, 21];

const doubled = map(numbers, (number) => {
  return number * 2;
});

const doubled = _.map(numbers, (number) => number * 2);

_.forEach(numbers, (number) => push_to_cloud(number));

const greaterThanTwo = _.filter(numbers, (number) => number > 2);

const formattedTime = !start.isSame(end, "day")
  ? !start.isSame(end, "month")
    ? !start.isSame(end, "year")
      ? start.format("ddd D MMM 'YY") + " - " + end.format("ddd D MMM 'YY")
      : start.format("ddd D MMM") + " - " + end.format("ddd D MMM 'YY")
    : start.format("ddd D") + " - " + end.format("ddd D MMM 'YY")
  : start.format("ddd D MMM 'YY");

const menu = (() => {
  const info = doSomeLogic();

  return constructMenu(info);
})();
