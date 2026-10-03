const REFERENCE_WIDTH = 608;
const REFERENCE_HEIGHT = 480;

export function updateScaling() {
  const scaleX = window.innerWidth / REFERENCE_WIDTH;
  const scaleY = window.innerHeight / REFERENCE_HEIGHT;
  const scale = Math.min(scaleX, scaleY);

  document.documentElement.style.setProperty(
    '--lobby-scale',
    `${scale}`,
  );
}
