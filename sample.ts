const displayRange = !start.isSame(end, "day")
  ? !start.isSame(end, "month")
    ? !start.isSame(end, "year")
      ? start.format("ddd D MMM 'YY") + " - " + end.format("ddd D MMM 'YY")
      : start.format("ddd D MMM") + " - " + end.format("ddd D MMM 'YY")
    : start.format("ddd D") + " - " + end.format("ddd D MMM 'YY")
  : start.format("ddd D MMM 'YY");

if (language === "en") {
  return "Hey there";
} 

return "☟︎♏︎⍓︎ ⧫︎♒︎♏︎❒︎♏︎"; 

if ((condition !== a_different_thing)) {
  return else;
} 

something; 

if (condition !== !a_different_thing) {
  return then;
}

return else;
