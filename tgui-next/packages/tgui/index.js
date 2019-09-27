import { act } from 'byond';
import { loadCSS } from 'fg-loadcss';
import { render } from 'inferno';
import { Layout } from './layout';
import { createLogger } from './logging';

const logger = createLogger();

const reactRoot = document.getElementById('react-root');

const renderLayout = state => {
  logger.log('Rendering with state', state);
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

// Subscribe to updates
window.update = window.initialize = stateJson => {
  const state = JSON.parse(stateJson);
  renderLayout(state);
};

// Find data in the page, load inlined state.
const holder = document.getElementById('data');
const ref = holder.getAttribute('data-ref');
const stateJson = holder.textContent;
holder.remove();
const state = JSON.parse(stateJson);

// Render the app
if (stateJson !== '{}') {
  logger.log('Found inlined state')
  renderLayout(state);
}

act(ref, 'tgui:initialize');

// Dynamically load font-awesome from browser's cache
loadCSS('v4shim.css');
loadCSS('font-awesome.css');

// Handle global errors
window.onerror = (msg, url, line, col, error) => {
  logger.error('Error:', msg, { url, line, col });
};
