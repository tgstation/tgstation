import { isAlphanumeric, getHistoryLength } from '../helpers';
import { Modal } from '../types';

/**
 * Handles other key events.
 * TAB - Changes channels.
 * UP/DOWN - Sets history counter and input value.
 * BKSP/DEL - Resets history counter and checks window size.
 * TYPING - When users key, it tells byond that it's typing.
 */
export const handleKeyDown = function (
	this: Modal,
	event: KeyboardEvent,
	value: string
) {
	const { channel } = this.state;
	const { radioPrefix } = this.fields;
	if (event.key === 'Up' || event.key === 'Down') {
		event.preventDefault();
		if (getHistoryLength()) {
			this.events.onArrowKeys(event.key, value);
		}
		return;
	}
	if (event.key === 'Tab') {
		event.preventDefault();
		this.events.onIncrementChannel();
		return;
	}
	if (event.key === 'Delete' || event.key === 'Backspace') {
		this.events.onBackspaceDelete();
		return;
	}
	if (isAlphanumeric(event.keyCode)) {
		if (channel !== 3 && radioPrefix !== ':b ') {
			this.timers.typingThrottle();
		}
	}
};
