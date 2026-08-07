// The lobby UI is authored at 640px native width.
// Instead of two scaling systems (rem + --icon-scale), we set a
// single zoom factor on the lobby container. Everything inside
// uses raw pixel values matching the original BYOND coordinates.
const BASE_WIDTH = 640;

export function updateScaling() {
  const width = window.innerWidth;
  document.documentElement.style.setProperty(
    '--lobby-zoom',
    `${width / BASE_WIDTH}`,
  );
}
