import './styles/main.scss';
import { TguiSay } from './TguiSay';
import { setupGlobalEvents } from 'tgui/events';
import { createRenderer } from 'tgui/renderer';

const renderApp = createRenderer(() => {
  return (
    <TguiSay />
  );
});

const setupApp = () => {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }
  setupGlobalEvents({
    ignoreWindowFocus: true,
  });
  // Unhide the panel
  Byond.winset('output', {
    'is-visible': false,
  });
  Byond.winset('browseroutput', {
    'is-visible': true,
    'is-disabled': false,
    'pos': '0x0',
    'size': '0x0',
  });
  // Resize the panel to match the non-browser output
  Byond.winget('output').then(output => {
    Byond.winset('browseroutput', {
      'size': output.size,
    });
  });
  renderApp();
};

setupApp();
