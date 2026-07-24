import './styles/main.scss';

import { loadMappings, loadStyleSheet } from 'common/assets';
import { createRoot, type Root } from 'react-dom/client';
import { assetMap } from './assets';
import { EscapeMenu, isResizeFrozen } from './EscapeMenu';

const ICON_SCALE_BASE_WIDTH = 800;
const REM_BASE_DIVISOR = 100;

let reactRoot: Root | null = null;

document.onreadystatechange = () => {
  if (document.readyState !== 'complete') return;

  function updateScaling() {
    const width = window.innerWidth;
    document.documentElement.style.fontSize = `${width / REM_BASE_DIVISOR}px`;
    document.documentElement.style.setProperty(
      '--icon-scale',
      `${width / ICON_SCALE_BASE_WIDTH}`,
    );
  }
  updateScaling();

  window.addEventListener('resize', () => {
    if (isResizeFrozen()) return;
    updateScaling();
  });

  if (!reactRoot) {
    const root = document.getElementById('react-root');
    reactRoot = createRoot(root!);
  }

  reactRoot.render(<EscapeMenu />);

  Byond.subscribeTo('asset/stylesheet', loadStyleSheet);
  Byond.subscribeTo('asset/mappings', (payload: Record<string, string>) => {
    loadMappings(payload, assetMap);
  });
};
