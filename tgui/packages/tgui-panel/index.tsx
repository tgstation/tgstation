/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import './styles/main.scss';
import './styles/themes/light.scss';

import { createRoot } from 'react-dom/client';
import { setupGlobalEvents } from 'tgui-core/events';
import { captureExternalLinks } from 'tgui-core/links';
import { setupHotReloading } from 'tgui-dev-server/link/client';
import { App } from './app';
import { bus } from './events/listeners';
import { setupPanelFocusHacks } from './panelFocus';

const root = createRoot(document.getElementById('react-root')!);

function render(component: React.ReactElement) {
  root.render(component);
}

function setupApp() {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }

  setupGlobalEvents({
    ignoreWindowFocus: true,
  });

  setupPanelFocusHacks();
  captureExternalLinks();

  render(<App />);

  // Dispatch incoming messages as store actions
  Byond.subscribe((type, payload) => bus.dispatch({ type, payload }));

  // Unhide the panel
  Byond.winset('output_selector.legacy_output_selector', {
    left: 'output_browser',
  });

  // Resize the panel to match the non-browser output
  Byond.winget('output').then((output: { size: string }) => {
    Byond.winset('browseroutput', {
      size: output.size,
    });
  });

  // Enable hot module reloading
  if (import.meta.webpackHot) {
    setupHotReloading();

    import.meta.webpackHot.accept(['./app'], () => {
      render(<App />);
    });
  }
}

setupApp();
