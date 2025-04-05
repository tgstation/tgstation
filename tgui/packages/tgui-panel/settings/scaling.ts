// This is the elements from the skin.dmf that we need to adjust the fontsize of
const ELEMENTS_TO_ADJUST = [
  'infobuttons.changelog',
  'infobuttons.rules',
  'infobuttons.wiki',
  'infobuttons.forum',
  'infobuttons.github',
  'infobuttons.report-issue',
  'infobuttons.fullscreen-toggle',
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

  const newSizes: { [element: string]: number } = {};

  for (const element of ELEMENTS_TO_ADJUST) {
    newSizes[`${element}.font-size`] =
      DEFAULT_BUTTON_FONT_SIZE * window.devicePixelRatio;
  }

  Byond.winset(null, newSizes);
}

const PANE_SPLITTERS = [
  'info_button_child',
  'input_buttons_child',
  'output_input_child',
];

export function setEditPaneSplitters(editing: boolean) {
  const toSet: { [element: string]: any } = {};

  for (const pane of PANE_SPLITTERS) {
    toSet[`${pane}.show-splitter`] = editing;
  }

  Byond.winset(null, toSet);
}
