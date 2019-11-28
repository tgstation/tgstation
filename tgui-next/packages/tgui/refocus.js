import { tridentVersion } from './byond';

export const refocusLayout = () => {
  if (tridentVersion <= 4) {
    return;
  }
  const element = document.getElementById('Layout__content');
  if (element) {
    element.focus();
  }
};
