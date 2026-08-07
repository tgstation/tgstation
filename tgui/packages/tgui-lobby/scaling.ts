// At this base width, sprites render at 1:1 pixel scale.
// Wider viewports scale up proportionally.
const ICON_SCALE_BASE_WIDTH = 640;

// 1rem = viewport_width / REM_BASE_DIVISOR.
// Ratio of 640/80 = 8, so BYOND pixel offsets ÷ 8 = rem.
const REM_BASE_DIVISOR = 80;

export function updateScaling() {
  const width = window.innerWidth;
  document.documentElement.style.fontSize = `${width / REM_BASE_DIVISOR}px`;
  document.documentElement.style.setProperty(
    '--icon-scale',
    `${width / ICON_SCALE_BASE_WIDTH}`,
  );
}
