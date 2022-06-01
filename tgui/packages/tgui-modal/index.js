import './styles/main.scss';
import { createRenderer } from 'tgui/renderer';
import { TguiModal } from './interfaces/TguiModal';

const renderApp = createRenderer(() => {
  return <TguiModal />;
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
