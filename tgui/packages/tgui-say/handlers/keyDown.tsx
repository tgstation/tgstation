import { isAlphanumeric, getHistoryLength } from '../helpers';
import { Modal } from '../types';

/**
 * Handles other key events.
 * TAB - Changes channels.
 * UP/DOWN - Sets history counter and input value.
 * BKSP/DEL - Resets history counter and checks window size.
 * TYPING - When users key, it tells byond that it's typing.
 */
export const handleKeyDown = function (this: Modal, event: KeyboardEvent) {
	const { channel } = this.state;
	const { radioPrefix } = this.fields;
	if (isAlphanumeric(event.code)) {
		if (channel !== 3 && radioPrefix !== ':b ') {
			this.timers.typingThrottle();
		}
	}
	if (event.key === 'ArrowUp' || event.key === 'ArrowDown') {
		if (getHistoryLength()) {
			this.events.onArrowKeys(event.key);
		}
	}
	if (event.key === 'Delete' || event.key === 'Backspace') {
		this.events.onBackspaceDelete();
	}
	if (event.key === 'Tab') {
		event.preventDefault();
		this.events.onIncrementChannel();
	}
};
