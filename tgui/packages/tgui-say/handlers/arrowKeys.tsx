import { KEY_DOWN, KEY_UP } from 'common/keycodes';
import { getHistoryLength } from '../helpers';
import { TguiModal } from '../types';

/** Increments the chat history counter, looping through entries */
export const handleArrowKeys = function (this: TguiModal, direction: number) {
  const { historyCounter } = this;
  if (direction === KEY_UP && historyCounter < getHistoryLength()) {
    this.historyCounter++;
    this.onViewHistory();
  } else if (direction === KEY_DOWN && historyCounter > 0) {
    this.historyCounter--;
    this.onViewHistory();
  }
};
