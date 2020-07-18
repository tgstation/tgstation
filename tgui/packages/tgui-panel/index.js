/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// Polyfills
import 'core-js/es';
import 'core-js/web/immediate';
import 'core-js/web/queue-microtask';
import 'core-js/web/timers';
import 'regenerator-runtime/runtime';
import 'tgui/polyfills/html5shiv';
import 'tgui/polyfills/ie8';
import 'tgui/polyfills/dom4';
import 'tgui/polyfills/css-om';
import 'tgui/polyfills/inferno';

// Themes
import 'tgui/styles/main.scss';
import './chat.scss';

import { perf } from 'common/perf';
import { setupHotReloading } from 'tgui-dev-server/link/client';
import { createRenderer } from 'tgui/renderer';
import { configureStore, StoreProvider } from 'tgui/store';
import { chatMiddleware } from 'tgchat';

perf.mark('inception', window.__inception__);
perf.mark('init');

const store = configureStore({
  middleware: {
    pre: [
      chatMiddleware,
    ],
  },
});

const renderApp = createRenderer(() => {
  const { PanelRoot } = require('./PanelRoot');
  return (
    <StoreProvider store={store}>
      <PanelRoot />
    </StoreProvider>
  );
});

const setupApp = () => {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }

  // Subscribe for Redux state updates
  store.subscribe(renderApp);

  // Subscribe for bankend updates
  window.update = msg => store.dispatch(Byond.parseJson(msg));

  // Process the early update queue
  while (true) {
    let stateJson = window.__updateQueue__.shift();
    if (!stateJson) {
      break;
    }
    window.update(stateJson);
  }

  // Enable hot module reloading
  if (module.hot) {
    setupHotReloading();
    module.hot.accept([
      './PanelRoot',
    ], () => {
      renderApp();
    });
  }
};

setupApp();
