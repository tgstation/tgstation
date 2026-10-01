const SCALE_FUDGE = 1.2;

export function updateScaling() {
  document.documentElement.style.setProperty(
    '--lobby-scale',
    `${window.devicePixelRatio * SCALE_FUDGE}`,
  );
}
