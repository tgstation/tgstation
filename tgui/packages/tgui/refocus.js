import { tridentVersion } from './byond';

export const refocusLayout = () => {
  // IE8: Focus method is seemingly fucked.
  if (tridentVersion <= 4) {
    return;
  }
  const element = document.getElementById('Layout__content');
  if (element) {
    element.focus();
  }
};
