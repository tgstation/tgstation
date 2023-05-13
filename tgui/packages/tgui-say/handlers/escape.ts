import { Handlers } from '.';
import { windowClose } from '../helpers';
import { TguiSay } from '../TguiSay';

/** User presses escape, closes the window */
export const handleEscape: Handlers['escape'] = function (this: TguiSay) {
  const { reset } = this.handlers;

  reset();
  windowClose();
};
