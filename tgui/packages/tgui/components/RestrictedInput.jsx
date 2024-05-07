import { KEY_ENTER, KEY_ESCAPE } from 'common/keycodes';
import { clamp } from 'common/math';
import { classes } from 'common/react';
import { Component, createRef } from 'react';

import { Box } from './Box';

const DEFAULT_MIN = 0;
const DEFAULT_MAX = 10000;

/**
 * Sanitize a number without interfering with writing negative or floating point numbers.
 * Handling dots and minuses in a user friendly way
 * @param value {String}
 * @param minValue {Number}
 * @param maxValue {Number}
 * @param allowFloats {Boolean}
 * @returns {String}
 */
const softSanitizeNumber = (value, minValue, maxValue, allowFloats) => {
  const minimum = minValue || DEFAULT_MIN;
  const maximum = maxValue || maxValue === 0 ? maxValue : DEFAULT_MAX;

  let sanitizedString = allowFloats
    ? value.replace(/[^\-\d.]/g, '')
    : value.replace(/[^\-\d]/g, '');

  if (allowFloats) {
    sanitizedString = maybeLeadWithMin(sanitizedString, minimum);
    sanitizedString = keepOnlyFirstOccurrence('.', sanitizedString);
  }
  if (minValue < 0) {
    sanitizedString = maybeMoveMinusSign(sanitizedString);
    sanitizedString = keepOnlyFirstOccurrence('-', sanitizedString);
  } else {
    sanitizedString = sanitizedString.replaceAll('-', '');
  }
  if (minimum <= 1 && maximum >= 0) {
    return clampGuessedNumber(sanitizedString, minimum, maximum, allowFloats);
  }
  return sanitizedString;
};

/**
 * Clamping the input to the restricted range, making the Input smart for min <= 1 and max >= 0
 * @param softSanitizedNumber {String}
 * @param allowFloats {Boolean}
 * @returns {string}
 */
const clampGuessedNumber = (
  softSanitizedNumber,
  minValue,
  maxValue,
  allowFloats,
) => {
  let parsed = allowFloats
    ? parseFloat(softSanitizedNumber)
    : parseInt(softSanitizedNumber, 10);
  if (
    !isNaN(parsed) &&
    (softSanitizedNumber.slice(-1) !== '.' || parsed < Math.floor(minValue))
  ) {
    let clamped = clamp(parsed, minValue, maxValue);
    if (parsed !== clamped) {
      return String(clamped);
    }
  }
  return softSanitizedNumber;
};

/**
 * Translate x- to -x and -x- to x
 * @param string {String}
 * @returns {string}
 */
const maybeMoveMinusSign = (string) => {
  let retString = string;
  // if minus sign is present but not first
  let minusIdx = string.indexOf('-');
  if (minusIdx > 0) {
    string = string.replace('-', '');
    retString = '-'.concat(string);
  } else if (minusIdx === 0) {
    if (string.indexOf('-', minusIdx + 1) > 0) {
      retString = string.replaceAll('-', '');
    }
  }
  return retString;
};

/**
 * Translate . to min. or .x to mim.x or -. to -min.
 * @param string {String}
 */
const maybeLeadWithMin = (string, min) => {
  let retString = string;
  let cuttedVal = Math.sign(min) * Math.floor(Math.abs(min));
  if (string.indexOf('.') === 0) {
    retString = String(cuttedVal).concat(string);
  } else if (string.indexOf('-') === 0 && string.indexOf('.') === 1) {
    retString = cuttedVal + '.'.concat(string.slice(2));
  }
  return retString;
};

/**
 * Keep only the first occurrence of a string in another string.
 * @param needle {String}
 * @param haystack {String}
 * @returns {string}
 */
const keepOnlyFirstOccurrence = (needle, haystack) => {
  const idx = haystack.indexOf(needle);
  const len = haystack.length;
  let newHaystack = haystack;
  if (idx !== -1 && idx < len - 1) {
    let trailingString = haystack.slice(idx + 1, len);
    trailingString = trailingString.replaceAll(needle, '');
    newHaystack = haystack.slice(0, idx + 1).concat(trailingString);
  }
  return newHaystack;
};

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
  constructor(props) {
    super(props);
    this.inputRef = createRef();
    this.state = {
      editing: false,
    };
    this.handleBlur = (e) => {
      const { maxValue, minValue, onBlur, allowFloats } = this.props;
      const { editing } = this.state;
      if (editing) {
        this.setEditing(false);
      }
      const safeNum = getClampedNumber(
        e.target.value,
        minValue,
        maxValue,
        allowFloats,
      );
      if (onBlur) {
        onBlur(e, +safeNum);
      }
    };
    this.handleChange = (e) => {
      const { maxValue, minValue, onChange, allowFloats } = this.props;
      e.target.value = softSanitizeNumber(
        e.target.value,
        minValue,
        maxValue,
        allowFloats,
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
          allowFloats,
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
        allowFloats,
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
          allowFloats,
        );
      }
    }
  }

  setEditing(editing) {
    this.setState({ editing });
  }

  render() {
    const { props } = this;
    const { onChange, onEnter, onInput, onBlur, value, ...boxProps } = props;
    const { className, fluid, monospace, ...rest } = boxProps;
    return (
      <Box
        className={classes([
          'Input',
          fluid && 'Input--fluid',
          monospace && 'Input--monospace',
          className,
        ])}
        {...rest}
      >
        <div className="Input__baseline">.</div>
        <input
          className="Input__input"
          onChange={this.handleChange}
          onInput={this.handleInput}
          onFocus={this.handleFocus}
          onBlur={this.handleBlur}
          onKeyDown={this.handleKeyDown}
          ref={this.inputRef}
          type="number | string"
        />
      </Box>
    );
  }
}
