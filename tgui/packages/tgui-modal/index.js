import './styles/main.scss';
import { TguiModal } from './TguiModal';
import { setupGlobalEvents } from 'tgui/events';
import { createRenderer } from 'tgui/renderer';

const renderApp = createRenderer(() => {
  return (
    <TguiModal />
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
  renderApp();
};

setupApp();
