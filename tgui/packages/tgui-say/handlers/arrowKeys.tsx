import { KEY_DOWN, KEY_UP } from 'common/keycodes';
import { getHistoryLength } from '../helpers';
import { Modal } from '../types';

/** Increments the chat history counter, looping through entries */
export const handleArrowKeys = function (this: Modal, direction: number) {
  const { historyCounter } = this.fields;
  if (direction === KEY_UP && historyCounter < getHistoryLength()) {
    this.fields.historyCounter++;
    this.events.onViewHistory();
  } else if (direction === KEY_DOWN && historyCounter > 0) {
    this.fields.historyCounter--;
    this.events.onViewHistory();
  }
};
