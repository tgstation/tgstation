// This is the elements from the skin.dmf that we need to adjust the fontsize of
const ELEMENTS_TO_ADJUST = [
  'infowindow.changelog',
  'infowindow.rules',
  'infowindow.wiki',
  'infowindow.forum',
  'infowindow.github',
  'infowindow.report-issue',
  'infowindow.fullscreen-toggle',
].map((i) => i + '.font-size');

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
    const size = parseInt(sizes[element], 10) ?? 4;

    newSizes[element] = size * window.devicePixelRatio;
  }

  Byond.winset(null, newSizes);
}
