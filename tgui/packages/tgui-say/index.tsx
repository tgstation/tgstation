import './styles/main.scss';
import { createRenderer } from 'tgui/renderer';
import { TguiSay } from './interfaces/TguiSay';

const renderApp = createRenderer(() => {
  return <TguiSay />;
});

const setupApp = () => {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }

  renderApp();
};

setupApp();
