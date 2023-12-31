/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { KEY } from 'common/keys';
import { classes } from 'common/react';
import { KeyboardEvent, SyntheticEvent, useEffect, useRef } from 'react';

import { Box, BoxProps } from './Box';

type Props = Partial<{
  autoFocus: boolean;
  autoSelect: boolean;
  className: string;
  disabled: boolean;
  fluid: boolean;
  maxLength: number;
  monospace: boolean;
  /** Fires when user is 'done typing': Clicked out, blur, enter key */
  onChange: (event: SyntheticEvent<HTMLInputElement>, value: string) => void;
  /** Fires once the enter key is pressed */
  onEnter: (event: SyntheticEvent<HTMLInputElement>, value: string) => void;
  /** Fires once the escape key is pressed */
  onEscape: (event: SyntheticEvent<HTMLInputElement>) => void;
  /** Fires on each key press / value change. Used for searching */
  onInput: (event: SyntheticEvent<HTMLInputElement>, value: string) => void;
  placeholder: string;
  selfClear: boolean;
  value: string | number;
}> &
  BoxProps;

export const toInputValue = (value: string | number | undefined) =>
  typeof value !== 'number' && typeof value !== 'string' ? '' : String(value);

export const Input = (props: Props) => {
  const {
    autoFocus,
    autoSelect,
    className,
    disabled,
    fluid,
    maxLength,
    monospace,
    onChange,
    onEnter,
    onEscape,
    onInput,
    placeholder,
    selfClear,
    value,
    ...rest
  } = props;

  const inputRef = useRef<HTMLInputElement>(null);

  const handleKeyDown = (event: KeyboardEvent<HTMLInputElement>) => {
    if (event.key === KEY.Enter) {
      onEnter?.(event, event.currentTarget.value);
      if (selfClear) {
        event.currentTarget.value = '';
      } else {
        event.currentTarget.blur();
        onChange?.(event, event.currentTarget.value);
      }

      return;
    }

    if (event.key === KEY.Escape) {
      onEscape?.(event);

      event.currentTarget.value = toInputValue(value);
      event.currentTarget.blur();
    }
  };

  /** Focuses the input on mount */
  useEffect(() => {
    if (!autoFocus && !autoSelect) return;

    const input = inputRef.current;
    if (!input) return;

    setTimeout(() => {
      input.focus();

      if (autoSelect) {
        input.select();
      }
    }, 1);
  }, []);

  /** Updates the initial value on props change */
  useEffect(() => {
    const input = inputRef.current;
    if (!input) return;

    const newValue = toInputValue(value);
    if (input.value === newValue) return;

    input.value = newValue;
  }, [value]);

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
        disabled={disabled}
        maxLength={maxLength}
        onBlur={(event) => onChange?.(event, event.target.value)}
        onChange={(event) => onInput?.(event, event.target.value)}
        onKeyDown={handleKeyDown}
        placeholder={placeholder}
        ref={inputRef}
      />
    </Box>
  );
};
