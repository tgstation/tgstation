/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { Component, createRef } from 'inferno';
import { Box } from './Box';
import { KEY_ESCAPE, KEY_ENTER, KEY_TAB } from 'common/keycodes';

export const toInputValue = value => (
  typeof value !== 'number' && typeof value !== 'string'
    ? ''
    : String(value)
);

export class Input extends Component {
  constructor(props) {
    super(props);
    this.inputRef = createRef();
    this.state = {
      editing: false,
    };
    const {
      dontUseTabForIndent = false,
    } = props;
    this.handleInput = e => {
      const { editing } = this.state;
      const { onInput } = props;
      if (!editing) {
        this.setEditing(true);
      }
      if (onInput) {
        onInput(e, e.target.value);
      }
    };
    this.handleFocus = e => {
      const { editing } = this.state;
      if (!editing) {
        this.setEditing(true);
      }
    };
    this.handleBlur = e => {
      const { editing } = this.state;
      const { onChange } = props;
      if (editing) {
        this.setEditing(false);
        if (onChange) {
          onChange(e, e.target.value);
        }
      }
    };
    this.handleKeyDown = e => {
      const {
        onInput,
        onChange,
        onEscape,
        onEnter,
        onKeyDown,
        selfClear,
      } = props;
      if (onKeyDown) {
        onKeyDown(e);
      }
      if (e.keyCode === KEY_ENTER) {
        this.setEditing(false);
        if (onChange) {
          onChange(e, e.target.value);
        }
        if (onInput) {
          onInput(e, e.target.value);
        }
        if (onEnter) {
          onEnter(e, e.target.value);
        }
        if (selfClear) {
          e.target.value = '';
        } else {
          e.target.blur();
        }
        return;
      }
      if (e.keyCode === KEY_ESCAPE) {
        this.setEditing(false);
        if (onEscape) {
          onEscape(e);
        }
        if (selfClear) {
          e.target.value = '';
        } else {
          e.target.value = toInputValue(props.value);
          e.target.blur();
        }
        return;
      }
      if (dontUseTabForIndent) {
        const keyCode = e.keyCode || e.which;
        if (keyCode === KEY_TAB) {
          e.preventDefault();
          const { value, selectionStart, selectionEnd } = e.target;
          e.target.value = (
            value.substring(0, selectionStart) + "\t"
              + value.substring(selectionEnd)
          );
          e.target.selectionEnd = selectionStart + 1;
        }
      }
    };
  }

  componentDidMount() {
    const nextValue = this.props.value;
    const input = this.inputRef.current;
    if (input) {
      input.value = toInputValue(nextValue);
    }

    if (this.props.autoFocus || this.props.autoSelect) {
      setTimeout(() => {
        input.focus();

        if (this.props.autoSelect) {
          input.select();
        }
      }, 1);
    }
  }

  componentDidUpdate(prevProps, prevState) {
    const { editing } = this.state;
    const prevValue = prevProps.value;
    const nextValue = this.props.value;
    const input = this.inputRef.current;
    if (input && !editing && prevValue !== nextValue) {
      input.value = toInputValue(nextValue);
    }
  }

  setEditing(editing) {
    this.setState({ editing });
  }

  render() {
    const {
      handleInput,
      handleFocus,
      handleBlur,
      handleKeyDown,
      handleChange,
      inputRef,
      props,
    } = this;
    // Input only props
    const {
      value,
      maxLength,
      placeholder,
      scrollable,
      ...boxProps
    } = props;
    // Box props
    const {
      className,
      fluid,
      monospace,
      ...rest
    } = boxProps;
    return (
      <Box
        className={classes([
          'Input',
          fluid && 'Input--fluid',
          monospace && 'Input--monospace',
          className,
        ])}
        {...rest}>
        <div className="Input__baseline">
          .
        </div>
        {!scrollable ? (
          <input
            ref={inputRef}
            className="Input__input"
            placeholder={placeholder}
            onInput={handleInput}
            onFocus={handleFocus}
            onBlur={handleBlur}
            onKeyDown={handleKeyDown}
            maxLength={maxLength} />
        ) : (
          <textarea
            ref={inputRef}
            className="TextArea__textarea"
            placeholder={placeholder}
            onChange={handleChange}
            onKeyDown={handleKeyDown}
            onInput={handleInput}
            onFocus={handleFocus}
            onBlur={handleBlur}
            maxLength={maxLength} />
        )}
      </Box>
    );
  }
}
