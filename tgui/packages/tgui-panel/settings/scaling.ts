// This is the elements from the skin.dmf that we need to compensate for DPI
const ELEMENTS_TO_ADJUST = [
  //  'outputwindow.input',
  'infowindow.changelog',
  'infowindow.rules',
  'infowindow.wiki',
  'infowindow.forum',
  'infowindow.github',
  'infowindow.report-issue',
  'infowindow.fullscreen-toggle',
];

export async function setDisplayScaling() {
  if (window.devicePixelRatio === 1) {
    return;
  }

  const sizes = await Byond.winget(
    null,
    ELEMENTS_TO_ADJUST.map((i) => i + '.*'),
  );

  const newSizes: string[] = [];

  for (const element of ELEMENTS_TO_ADJUST) {
    const size: [number, number] = sizes[element + '.size'].split('x');

    newSizes[`${element}.size`] =
      `${size[0]}x${size[1] * window.devicePixelRatio}`;
  }

  Byond.winset(null, newSizes);
}
