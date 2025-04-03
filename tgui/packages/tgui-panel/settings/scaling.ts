// This is the elements from the skin.dmf that we need to adjust the fontsize of
const ELEMENTS_TO_ADJUST = [
  'infowindow.changelog',
  'infowindow.rules',
  'infowindow.wiki',
  'infowindow.forum',
  'infowindow.github',
  'infowindow.report-issue',
  'infowindow.fullscreen-toggle',
  'inputwindow.input',
  'inputbuttons.saybutton',
  'inputbuttons.mebutton',
  'inputbuttons.oocbutton',
];

const DEFAULT_BUTTON_FONT_SIZE = 4;

export async function setDisplayScaling() {
  if (window.devicePixelRatio === 1) {
    return;
  }

  const newSizes: string[] = [];

  for (const element of ELEMENTS_TO_ADJUST) {
    newSizes[`${element}.font-size`] =
      DEFAULT_BUTTON_FONT_SIZE * window.devicePixelRatio;
  }

  console.log(newSizes);

  Byond.winset(null, newSizes);
}
