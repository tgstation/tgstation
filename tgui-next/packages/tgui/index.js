import { act, winset } from 'byond';
import { loadCSS } from 'fg-loadcss';
import { render } from 'inferno';
import { Layout, getRoutedComponent } from './layout';
import { createLogger } from './logging';
import { setupDrag } from './drag';

const logger = createLogger();

const reactRoot = document.getElementById('react-root');

let initialRender = true;

const renderLayout = state => {
  logger.log('rendering');
  // Initial render setup
  if (initialRender) {
    logger.log('initial state', state);
    // Setup dragging
    setupDrag(state);
  }
  initialRender = false;
  // Start rendering
  try {
    const element = <Layout state={state} />;
    render(element, reactRoot);
  }
  catch (err) {
    logger.error(err.stack);
  }
};

// Initialize React app
// --------------------------------------------------------

const setupApp = () => {
  // Find data in the page, load inlined state.
  const holder = document.getElementById('data');
  const ref = holder.getAttribute('data-ref');
  const stateJson = holder.textContent;
  const state = JSON.parse(stateJson);

  // Determine if we can handle this route
  const route = getRoutedComponent(state.config.interface);
  if (!route) {
    // Load old TGUI
    loadCSS('tgui.css');
    const element = document.createElement('script');
    element.type = 'text/javascript';
    element.src = 'tgui.js';
    document.body.appendChild(element);
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

  // Subscribe to updates
  window.update = window.initialize = stateJson => {
    const state = JSON.parse(stateJson);
    renderLayout(state);
  };

  // Render the app
  if (stateJson !== '{}') {
    logger.log('Found inlined state')
    renderLayout(state);
  }

  // Initialize
  act(ref, 'tgui:initialize');

  // Dynamically load font-awesome from browser's cache
  loadCSS('v4shim.css');
  loadCSS('font-awesome.css');
};

// Handle global errors
window.onerror = (msg, url, line, col, error) => {
  logger.error('Error:', msg, { url, line, col });
};

setupApp();
