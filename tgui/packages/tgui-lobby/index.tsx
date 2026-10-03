import './styles/main.scss';

import { loadMappings, loadStyleSheet } from 'common/assets';
import { createRoot, type Root } from 'react-dom/client';
import { assetMap } from './assets';
import { LobbyMenu } from './LobbyMenu';
import { updateScaling } from './scaling';

let reactRoot: Root | null = null;

document.onreadystatechange = () => {
  if (document.readyState !== 'complete') return;

  updateScaling();

  window.addEventListener('resize', () => {
    updateScaling();
  });

  const KEY_CODE_TO_BYOND: Record<string, string> = {
    DEL: 'Delete',
    DELETE: 'Delete',
    DOWN: 'South',
    ARROWDOWN: 'South',
    END: 'Southwest',
    HOME: 'Northwest',
    INSERT: 'Insert',
    LEFT: 'West',
    ARROWLEFT: 'West',
    PAGEDOWN: 'Southeast',
    PAGEUP: 'Northeast',
    RIGHT: 'East',
    ARROWRIGHT: 'East',
    ' ': 'Space',
    UP: 'North',
    ARROWUP: 'North',
    ESCAPE: 'Escape',
    TAB: 'Tab',
    ENTER: 'Enter',
    BACKSPACE: 'Back',
    SHIFT: 'Shift',
    CONTROL: 'Ctrl',
    ALT: 'Alt',
  };

  function toBYONDKey(e: KeyboardEvent): string {
    const upper = e.key.toUpperCase();
    let text = '';
    if (e.altKey && upper !== 'ALT') text += 'Alt';
    if (e.ctrlKey && upper !== 'CONTROL') text += 'Ctrl';
    if (e.shiftKey && upper !== 'SHIFT') text += 'Shift';
    text += KEY_CODE_TO_BYOND[upper] || upper;
    return text;
  }

  const heldKeys = new Set<string>();

  window.addEventListener('keydown', (e) => {
    const key = toBYONDKey(e);
    if (!key || heldKeys.has(key)) return;
    heldKeys.add(key);
    Byond.command(`KeyDown "${key}" 0 0 0 0`);
  });

  window.addEventListener('keyup', (e) => {
    const key = toBYONDKey(e);
    if (!key || !heldKeys.has(key)) return;
    heldKeys.delete(key);
    Byond.command(`KeyUp "${key}" 0 0 0 0`);
  });

  Byond.winget('mapwindow.map_lobby_selector').then(
    (info: { size: string }) => {
      Byond.winset('lobby_menu', { size: info.size });
    },
  );

  if (!reactRoot) {
    const root = document.getElementById('react-root');
    reactRoot = createRoot(root!);
  }

  reactRoot.render(<LobbyMenu />);

  Byond.subscribeTo('asset/stylesheet', loadStyleSheet);
  Byond.subscribeTo('asset/mappings', (payload: Record<string, string>) => {
    loadMappings(payload, assetMap);
  });
};
