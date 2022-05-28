import './styles/main.scss';
import { createRenderer } from 'tgui/renderer';
import { TguiModal } from './interfaces/TguiModal';

// Debug artifacts
const CHANNEL = 'say';
const MAX_LENGTH = 1024;

const renderApp = createRenderer(() => {
  return <TguiModal channel={CHANNEL} max_length={MAX_LENGTH} />;
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
