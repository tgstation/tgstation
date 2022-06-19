import { Modal } from '../types';

/** After updating the input value, sets back to false */
// eslint-disable-next-line no-unused-vars
export const handleComponentUpdate = function (this: Modal) {
	this.setState({ edited: false });
};
