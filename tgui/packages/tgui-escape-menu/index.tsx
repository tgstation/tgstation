import './styles/main.scss';

import { loadMappings, loadStyleSheet } from 'common/assets';
import { createRoot, type Root } from 'react-dom/client';

import { EscapeMenu } from './EscapeMenu';
import { assetMap } from './assets';

let reactRoot: Root | null = null;

document.onreadystatechange = () => {
  if (document.readyState !== 'complete') return;

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
