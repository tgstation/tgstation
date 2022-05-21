import './styles/main.scss';
import { createRenderer } from 'tgui/renderer';
import { Modal } from './components/Modal';

const renderApp = createRenderer(() => {
  return (
    <Modal><Modal.Content>ok</Modal.Content></Modal>
  );
});

const setupApp = () => {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }
  // Enable hot module reloading
  if (module.hot) {
    setupHotReloading();
    module.hot.accept([
      './components',
    ], renderApp);
  }
};

setupApp();
