import { createRoot, Root } from 'react-dom/client';

// TODO: remove this once we're on 516
import { TguiSay } from './515/TguiSay';
import { TguiSay as NewSay } from './516/TguiSay';

let reactRoot: Root | null = null;

document.onreadystatechange = function () {
  if (document.readyState !== 'complete') return;

  if (!reactRoot) {
    const root = document.getElementById('react-root');
    reactRoot = createRoot(root!);
  }

  if (Byond.BLINK) {
    reactRoot.render(<NewSay />);
  } else {
    reactRoot.render(<TguiSay />);
  }
};
