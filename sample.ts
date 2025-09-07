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
