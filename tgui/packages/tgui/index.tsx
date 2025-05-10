/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// Themes
import './styles/main.scss';
import './styles/themes/abductor.scss';
import './styles/themes/cardtable.scss';
import './styles/themes/spookyconsole.scss';
import './styles/themes/hackerman.scss';
import './styles/themes/malfunction.scss';
import './styles/themes/neutral.scss';
import './styles/themes/ntos.scss';
import './styles/themes/ntos_cat.scss';
import './styles/themes/ntos_darkmode.scss';
import './styles/themes/ntos_lightmode.scss';
import './styles/themes/ntOS95.scss';
import './styles/themes/ntos_synth.scss';
import './styles/themes/ntos_terminal.scss';
import './styles/themes/ntos_spooky.scss';
import './styles/themes/paper.scss';
import './styles/themes/retro.scss';
import './styles/themes/syndicate.scss';
import './styles/themes/wizard.scss';
import './styles/themes/admin.scss';

import { perf } from 'common/perf';
import { setupGlobalEvents } from 'tgui-core/events';
import { setupHotKeys } from 'tgui-core/hotkeys';
import { setupHotReloading } from 'tgui-dev-server/link/client.mjs';

import { App } from './App';
import { setGlobalStore } from './backend';
import { captureExternalLinks } from './links';
import { render } from './renderer';
import { configureStore } from './store';

perf.mark('inception', window.performance?.timeOrigin);
perf.mark('init');

const store = configureStore();

function setupApp() {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }

  setGlobalStore(store);

  setupGlobalEvents();
  setupHotKeys();
  captureExternalLinks();

  store.subscribe(() => render(<App />));

  // Dispatch incoming messages as store actions
  Byond.subscribe((type, payload) => store.dispatch({ type, payload }));

  // Enable hot module reloading
  if (import.meta.webpackHot) {
    setupHotReloading();
    import.meta.webpackHot.accept(
      ['./debug', './layouts', './routes', './App'],
      () => {
        render(<App />);
      },
    );
  }
}

setupApp();
