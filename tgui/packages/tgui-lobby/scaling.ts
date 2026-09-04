const BASE_WIDTH = 640;

export function updateScaling() {
  const width = window.innerWidth;
  document.documentElement.style.setProperty(
    '--lobby-scale',
    `${width / BASE_WIDTH}`,
  );
}
