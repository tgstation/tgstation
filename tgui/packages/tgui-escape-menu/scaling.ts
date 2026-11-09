const ICON_SCALE_BASE_WIDTH = 800;
const REM_BASE_DIVISOR = 100;

export function updateScaling() {
  const width = window.innerWidth;
  document.documentElement.style.fontSize = `${width / REM_BASE_DIVISOR}px`;
  document.documentElement.style.setProperty(
    '--icon-scale',
    `${width / ICON_SCALE_BASE_WIDTH}`,
  );
}
