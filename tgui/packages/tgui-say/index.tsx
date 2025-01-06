import { createRoot, Root } from 'react-dom/client';

import { TguiSay } from './515/TguiSay';
// TODO: remove this once we're on 516
import { TguiSay as NewSay } from './516/TguiSay';

let reactRoot: Root | null = null;

document.onreadystatechange = function () {
  if (document.readyState !== 'complete') return;

  if (!reactRoot) {
    const root = document.getElementById('react-root');
    reactRoot = createRoot(root!);
  }

  if (Byond.BLINK) {
    Byond.sendMessage('entry', { channel: 'OOC', entry: 'NewSay Rendered!' });
    reactRoot.render(<NewSay />);
  } else {
    reactRoot.render(<TguiSay />);
  }
};
