import './styles/main.scss';
import { createRenderer } from 'tgui/renderer';
import { TguiModal } from './interfaces/TguiModal';

// Debug artifacts
const CHANNEL = 'say';
const MAXLENGTH = 1024;

const renderApp = createRenderer(() => {
  return <TguiModal channel={CHANNEL} maxLength={MAXLENGTH} />;
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
