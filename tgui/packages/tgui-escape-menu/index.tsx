import './styles/main.scss';

import { loadMappings, loadStyleSheet } from 'common/assets';
import { createRoot, type Root } from 'react-dom/client';
import { assetMap } from './assets';
import { EscapeMenu } from './EscapeMenu';

const ICON_SCALE_BASE_WIDTH = 800;

let reactRoot: Root | null = null;

document.onreadystatechange = () => {
  if (document.readyState !== 'complete') return;

  function updateIconScale() {
    const scale = window.innerWidth / ICON_SCALE_BASE_WIDTH;
    document.documentElement.style.setProperty('--icon-scale', `${scale}`);
  }
  updateIconScale();
  window.addEventListener('resize', updateIconScale);

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
