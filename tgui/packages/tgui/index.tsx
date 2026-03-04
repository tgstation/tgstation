/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// Themes
import './styles/main.scss';

import { setupGlobalEvents } from 'tgui-core/events';
import { setupHotKeys } from 'tgui-core/hotkeys';
import { captureExternalLinks } from 'tgui-core/links';
import { setupHotReloading } from 'tgui-dev-server/link/client';
import { App } from './App';
import { setDebugHotKeys } from './debug/use-debug';
import { bus } from './events/listeners';
import { render } from './renderer';
import { createStackAugmentor } from './stack';

function setupApp() {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }
  window.__augmentStack__ = createStackAugmentor();

  setupGlobalEvents();
  setupHotKeys({
    keyUpVerb: 'KeyUp',
    keyDownVerb: 'KeyDown',
    // In the future you could send a winget here to get mousepos/size from the map here if it's necessary
    verbParamsFn: (verb, key) => `${verb} "${key}" 0 0 0 0`,
  });
  captureExternalLinks();

  Byond.subscribe((type, payload) => bus.dispatch({ type, payload }));

  render(<App />);

  // Enable hot module reloading
  if (import.meta.webpackHot) {
    setDebugHotKeys();
    setupHotReloading();
    import.meta.webpackHot.accept(['./layouts', './routes', './App'], () =>
      render(<App />),
    );
  }
}

setupApp();
