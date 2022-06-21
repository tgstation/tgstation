import { getHistoryLength } from '../helpers';
import { Modal } from '../types';

/** Increments the chat history counter, looping through entries */
export const handleArrowKeys = function (this: Modal, direction: string) {
	const { historyCounter } = this.fields;
	if (direction === 'ArrowUp' && historyCounter < getHistoryLength()) {
		this.fields.historyCounter++;
		this.events.onViewHistory();
	} else if (direction === 'ArrowDown' && historyCounter > 0) {
		this.fields.historyCounter--;
		this.events.onViewHistory();
	}
};
