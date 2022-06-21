/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @author Warlockd
 * @license MIT
 */

import { classes } from 'common/react';
import { Component, createRef, RefObject } from 'inferno';
import { Box, BoxProps } from './Box';
import { toInputValue } from './Input';
import { KEY_ENTER, KEY_ESCAPE, KEY_TAB } from 'common/keycodes';

interface Props extends BoxProps {
	autoFocus?: boolean;
	autoSelect?: boolean;
	dontUseTabForIndent?: boolean;
	innerRef?: RefObject<HTMLTextAreaElement>;
	maxLength?: number;
	onChange?: (event: InputEvent, value: string) => void;
	onKey?: (event: KeyboardEvent, value: string) => void;
	onInput?: (event: InputEvent, value: string) => void;
	onEnter?: (event: KeyboardEvent, value: string) => void;
	onEscape?: (event: KeyboardEvent) => void;
	placeholder?: string;
	selfClear?: boolean;
}

type State = {
	editing: boolean;
};

export class TextArea extends Component<Props, State> {
	textareaRef: RefObject<HTMLTextAreaElement>;
	props: Props;
	state = {
		editing: false,
	};
	constructor(props, context) {
		super(props, context);
		this.props = props;
		if (props.innerRef) {
			this.textareaRef = props.innerRef;
		} else {
			this.textareaRef = createRef();
		}
	}

	handleInput = (event) => {
		const { editing } = this.state;
		const { onInput } = this.props;
		if (!editing) {
			this.setEditing(true);
		}
		if (onInput) {
			onInput(event, event.target.value);
		}
	};

	handleChange = (event) => {
		const { editing } = this.state;
		const { onChange } = this.props;
		if (editing) {
			this.setEditing(false);
		}
		if (onChange) {
			onChange(event, event.target.value);
		}
	};

	handleKeyDown = (event) => {
		const { editing } = this.state;
		/** Handles enter */
		if (event.keyCode === KEY_ENTER) {
			this.setEditing(false);
			if (this.props.onChange) {
				this.props.onChange(event, event.target.value);
			}
			if (this.props.onInput) {
				this.props.onInput(event, event.target.value);
			}
			if (this.props.onEnter) {
				this.props.onEnter(event, event.target.value);
			}
			if (this.props.selfClear) {
				event.target.value = '';
				event.target.blur();
			}
			return;
		}
		/** Handles escape */
		if (event.keyCode === KEY_ESCAPE) {
			if (this.props.onEscape) {
				this.props.onEscape(event);
			}
			this.setEditing(false);
			if (this.props.selfClear) {
				event.target.value = '';
			} else {
				event.target.value = toInputValue(this.props.value);
				event.target.blur();
			}
			return;
		}

		if (!editing) {
			this.setEditing(true);
		}
		/** Handles and keydown events */
		if (this.props.onKey) {
			this.props.onKey(event, event.target.value);
		}
		/**
		 * Creates an indentation if user hasn't used the
		 * "dontUseTabsForIndent" prop
		 */
		if (event.keyCode === KEY_TAB && !this.props.dontUseTabForIndent) {
			event.preventDefault();
			const { value, selectionStart, selectionEnd } = event.target;
			event.target.value =
				value.substring(0, selectionStart) +
				'\t' +
				value.substring(selectionEnd);
			event.target.selectionEnd = selectionStart + 1;
		}
	};

	handleFocus = () => {
		const { editing } = this.state;
		if (!editing) {
			this.setEditing(true);
		}
	};

	handleBlur = (event) => {
		const { editing } = this.state;
		const { onChange } = this.props;
		if (editing) {
			this.setEditing(false);
			if (onChange) {
				onChange(event, event.target.value);
			}
		}
	};

	componentDidMount() {
		const nextValue = this.props.value;
		const input = this.textareaRef.current;
		if (input) {
			input.value = toInputValue(nextValue);
		}
		if (this.props.autoFocus || this.props.autoSelect) {
			setTimeout(() => {
				input!.focus();

				if (this.props.autoSelect) {
					input!.select();
				}
			}, 1);
		}
	}

	componentDidUpdate(prevProps) {
		const prevValue = prevProps.value;
		const nextValue = this.props.value;
		const input = this.textareaRef.current;
		if (input && typeof nextValue === 'string' && prevValue !== nextValue) {
			input.value = toInputValue(nextValue);
		}
	}

	setEditing(editing) {
		this.setState({ editing });
	}

	getValue() {
		return this.textareaRef.current && this.textareaRef.current.value;
	}

	render() {
		const {
			handleChange,
			handleKeyDown,
			handleFocus,
			handleBlur,
			handleInput,
			textareaRef,
		} = this;
		// Input only props
		const { maxLength, placeholder, ...boxProps } = this.props;
		// Box props
		const { className, fluid, ...rest } = boxProps;
		return (
			<Box
				className={classes(['TextArea', fluid && 'TextArea--fluid', className])}
				{...rest}>
				<textarea
					ref={textareaRef}
					className="TextArea__textarea"
					placeholder={placeholder}
					onChange={handleChange}
					onKeyDown={handleKeyDown}
					onInput={handleInput}
					onFocus={handleFocus}
					onBlur={handleBlur}
					maxLength={maxLength}
				/>
			</Box>
		);
	}
}
