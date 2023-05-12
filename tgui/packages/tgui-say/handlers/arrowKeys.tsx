import { KEY_DOWN, KEY_UP } from 'common/keycodes';
import { getHistoryLength } from '../helpers';
import { Modal } from '../types';

/** Increments the chat history counter, looping through entries */
export const handleArrowKeys = function (this: Modal, direction: number) {
  const { historyCounter, currentValue } = this.fields;
  const historyLength = getHistoryLength();

  if (!historyLength) return;

  if (direction === KEY_UP && historyCounter < historyLength) {
    if (historyCounter === 0) {
      this.fields.tempHistory = currentValue;
    }
    this.fields.historyCounter++;
  } else if (direction === KEY_DOWN && historyCounter > 0) {
    this.fields.historyCounter--;
  }

  this.events.onViewHistory();
};
