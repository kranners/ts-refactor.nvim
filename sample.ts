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

