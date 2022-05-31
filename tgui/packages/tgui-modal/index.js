import './styles/main.scss';
import { createRenderer } from 'tgui/renderer';
import { TguiModal } from './interfaces/TguiModal';

// Debug artifacts
let channel, maxLength, force;

const renderApp = createRenderer(() => {
  return <TguiModal channel={channel} force={force} maxLength={maxLength} />;
});

const setupApp = () => {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }
  Byond.subscribe((type, payload) => {
    Byond.sendMessage('modal_data', { type, payload });
  });
  Byond.subscribeTo('modal_data', (data) => {
    channel = data.channel;
    maxLength = data.maxLength;
  });
  Byond.subscribeTo('modal_force', () => {
    force = true;
  });

  renderApp();
};

setupApp();
