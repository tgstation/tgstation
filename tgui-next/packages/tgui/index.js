import 'core-js/stable';
import 'regenerator-runtime/runtime';
import './polyfills';

import { act } from 'byond';
import { loadCSS } from 'fg-loadcss';
import { render } from 'inferno';
import { backendUpdate } from './backend';
import { setupDrag } from './drag';
import { getRoute, Layout } from './layout';
import { createLogger } from './logging';
import { createStore } from './store';
import { setupHotReloading } from 'tgui-dev-server/client';

const logger = createLogger();
const store = createStore();
const reactRoot = document.getElementById('react-root');

let initialRender = true;

const renderLayout = () => {
  const state = store.getState();
  // Initial render setup
  if (initialRender) {
    logger.log('initial render', state);
    initialRender = false;
    // Setup dragging
    setupDrag(state);
  }
  // Start rendering
  try {
    const element = <Layout state={state} />;
    render(element, reactRoot);
  }
  catch (err) {
    logger.error('rendering error', err.stack || String(err));
  }
};

const setupApp = () => {
  // Find data in the page, load inlined state.
  const holder = document.getElementById('data');
  const ref = holder.getAttribute('data-ref');
  const stateJson = holder.textContent;
  const state = JSON.parse(stateJson);

  // Determine if we can handle this route
  const route = getRoute(state.config && state.config.interface);
  if (!route) {
    // Load old TGUI
    loadCSS('tgui.css');
    const head = document.getElementsByTagName('head')[0];
    const script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = 'tgui.js';
    head.appendChild(script);
    // This thing was a part of an old index.html
    window.update = dataString => {
      const data = JSON.parse(dataString);
      if (window.tgui) {
        window.tgui.set('config', data.config);
        if (typeof data.data !== 'undefined') {
          window.tgui.set('data', data.data);
          window.tgui.animate('adata', data.data);
        }
      }
    };
    // Bail
    return;
  }

  // Subscribe for state updates
  store.subscribe(() => {
    renderLayout();
  });

  // Subscribe for bankend updates
  window.update = window.initialize = stateJson => {
    const state = JSON.parse(stateJson);
    // Backend update dispatches a store action
    store.dispatch(backendUpdate(state));
  };

  // Render the app
  if (stateJson !== '{}') {
    logger.log('Found inlined state');
    store.dispatch(backendUpdate(state));
  }

  // Enable hot module reloading
  if (module.hot) {
    setupHotReloading();
    module.hot.accept(['./layout'], () => {
      renderLayout();
    });
  }

  // Initialize
  act(ref, 'tgui:initialize');

  // Dynamically load font-awesome from browser's cache
  loadCSS('v4shim.css');
  loadCSS('font-awesome.css');
};

// In case the document is already loaded
if (document.readyState !== 'loading') {
  setupApp();
}
// Wait for content to load on modern browsers
// NOTE: This call is polyfilled on IE8.
else {
  document.addEventListener('DOMContentLoaded', setupApp);
}
