import { classes } from 'common/react';
import { clamp } from 'common/math';
import { Component, createRef } from 'inferno';
import { Box } from './Box';
import { KEY_ESCAPE, KEY_ENTER } from 'common/keycodes';

const DEFAULT_MIN = 0;
const DEFAULT_MAX = 10000;

/**
 * Takes a string input and parses integers or floats from it.
 * If none: Minimum is set.
 * Else: Clamps it to the given range.
 */
const getClampedNumber = (value, minValue, maxValue, allowFloats) => {
  const minimum = minValue || DEFAULT_MIN;
  const maximum = maxValue || maxValue === 0 ? maxValue : DEFAULT_MAX;
  if (!value || !value.length) {
    return String(minimum);
  }
  let parsedValue = allowFloats
    ? parseFloat(value.replace(/[^\-\d.]/g, ''))
    : parseInt(value.replace(/[^\-\d]/g, ''), 10);
  if (isNaN(parsedValue)) {
    return String(minimum);
  } else {
    return String(clamp(parsedValue, minimum, maximum));
  }
};

export class RestrictedInput extends Component {
  constructor() {
    super();
    this.inputRef = createRef();
    this.state = {
      editing: false,
    };
    this.handleBlur = (e) => {
      const { editing } = this.state;
      if (editing) {
        this.setEditing(false);
      }
    };
    this.handleChange = (e) => {
      const { maxValue, minValue, onChange, allowFloats } = this.props;
      e.target.value = getClampedNumber(
        e.target.value,
        minValue,
        maxValue,
        allowFloats
      );
      if (onChange) {
        onChange(e, +e.target.value);
      }
    };
    this.handleFocus = (e) => {
      const { editing } = this.state;
      if (!editing) {
        this.setEditing(true);
      }
    };
    this.handleInput = (e) => {
      const { editing } = this.state;
      const { onInput } = this.props;
      if (!editing) {
        this.setEditing(true);
      }
      if (onInput) {
        onInput(e, +e.target.value);
      }
    };
    this.handleKeyDown = (e) => {
      const { maxValue, minValue, onChange, onEnter, allowFloats } = this.props;
      if (e.keyCode === KEY_ENTER) {
        const safeNum = getClampedNumber(
          e.target.value,
          minValue,
          maxValue,
          allowFloats
        );
        this.setEditing(false);
        if (onChange) {
          onChange(e, +safeNum);
        }
        if (onEnter) {
          onEnter(e, +safeNum);
        }
        e.target.blur();
        return;
      }
      if (e.keyCode === KEY_ESCAPE) {
        if (this.props.onEscape) {
          this.props.onEscape(e);
          return;
        }
        this.setEditing(false);
        e.target.value = this.props.value;
        e.target.blur();
        return;
      }
    };
  }

  componentDidMount() {
    const { maxValue, minValue, allowFloats } = this.props;
    const nextValue = this.props.value?.toString();
    const input = this.inputRef.current;
    if (input) {
      input.value = getClampedNumber(
        nextValue,
        minValue,
        maxValue,
        allowFloats
      );
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

  componentDidUpdate(prevProps, _) {
    const { maxValue, minValue, allowFloats } = this.props;
    const { editing } = this.state;
    const prevValue = prevProps.value?.toString();
    const nextValue = this.props.value?.toString();
    const input = this.inputRef.current;
    if (input && !editing) {
      if (nextValue !== prevValue && nextValue !== input.value) {
        input.value = getClampedNumber(
          nextValue,
          minValue,
          maxValue,
          allowFloats
        );
      }
    }
  }

  setEditing(editing) {
    this.setState({ editing });
  }

  render() {
    const { props } = this;
    const { onChange, onEnter, onInput, value, ...boxProps } = props;
    const { className, fluid, monospace, ...rest } = boxProps;
    return (
      <Box
        className={classes([
          'Input',
          fluid && 'Input--fluid',
          monospace && 'Input--monospace',
          className,
        ])}
        {...rest}>
        <div className="Input__baseline">.</div>
        <input
          className="Input__input"
          onChange={this.handleChange}
          onInput={this.handleInput}
          onFocus={this.handleFocus}
          onBlur={this.handleBlur}
          onKeyDown={this.handleKeyDown}
          ref={this.inputRef}
          type="number"
        />
      </Box>
    );
  }
}
