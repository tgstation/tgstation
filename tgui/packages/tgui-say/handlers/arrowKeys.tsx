import { KEY_DOWN, KEY_UP } from 'common/keycodes';
import { getHistoryLength } from '../helpers';
import { Modal } from '../types';

/** Increments the chat history counter, looping through entries */
export const handleArrowKeys = function (
  this: Modal,
  direction: number,
  value: string
) {
  const { historyCounter } = this.fields;
  if (direction === KEY_UP && historyCounter < getHistoryLength()) {
    if (!historyCounter) {
      this.fields.tempHistory = value;
    }
    this.fields.historyCounter++;
    this.events.onViewHistory();
  } else if (direction === KEY_DOWN && historyCounter > 0) {
    this.fields.historyCounter--;
    this.events.onViewHistory();
  }
};
