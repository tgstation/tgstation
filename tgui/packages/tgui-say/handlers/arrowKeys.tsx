import { getHistoryLength } from '../helpers';
import { Modal } from '../types';

/** Increments the chat history counter, looping through entries */
export const handleArrowKeys = function (
	this: Modal,
	direction: string,
	value: string
) {
	const { historyCounter } = this.fields;
	if (direction === 'Up' && historyCounter < getHistoryLength()) {
		if (!historyCounter) {
			this.fields.tempHistory = value;
		}
		this.fields.historyCounter++;
		this.events.onViewHistory();
	} else if (direction === 'Down' && historyCounter > 0) {
		this.fields.historyCounter--;
		this.events.onViewHistory();
	}
};
