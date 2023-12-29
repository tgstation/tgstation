/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @author Warlockd
 * @license MIT
 */

import { KEY } from 'common/keys';
import { classes } from 'common/react';
import {
  forwardRef,
  RefObject,
  useEffect,
  useImperativeHandle,
  useRef,
  useState,
} from 'react';
import { KeyboardEvent, SyntheticEvent } from 'react';

import { Box, BoxProps } from './Box';
import { toInputValue } from './Input';

type Props = Partial<{
  autoFocus: boolean;
  autoSelect: boolean;
  displayedValue: string;
  dontUseTabForIndent: boolean;
  fluid: boolean;
  maxLength: number;
  noborder: boolean;
  /** Fires when user is 'done typing': Clicked out, blur, enter key (but not shift+enter) */
  onChange: (event: SyntheticEvent<HTMLTextAreaElement>, value: string) => void;
  /** Fires once the enter key is pressed */
  onEnter: (event: SyntheticEvent<HTMLTextAreaElement>, value: string) => void;
  /** Fires once the escape key is pressed */
  onEscape: (event: SyntheticEvent<HTMLTextAreaElement>) => void;
  /** Fires on each key press / value change. Used for searching */
  onInput: (event: SyntheticEvent<HTMLTextAreaElement>, value: string) => void;
  placeholder: string;
  scrollbar: boolean;
  selfClear: boolean;
  value: string;
}> &
  BoxProps;

export const TextArea = forwardRef(
  (props: Props, forwardedRef: RefObject<HTMLTextAreaElement>) => {
    const {
      autoFocus,
      autoSelect,
      displayedValue,
      dontUseTabForIndent,
      maxLength,
      noborder,
      onChange,
      onEnter,
      onEscape,
      onInput,
      placeholder,
      scrollbar,
      selfClear,
      value,
      ...boxProps
    } = props;
    const { className, fluid, nowrap, ...rest } = boxProps;

    const textareaRef = useRef<HTMLTextAreaElement>(null);
    const [scrolledAmount, setScrolledAmount] = useState(0);

    const handleKeyDown = (event: KeyboardEvent<HTMLTextAreaElement>) => {
      if (event.key === KEY.Enter) {
        if (event.shiftKey) {
          event.currentTarget.focus();
          return;
        }

        onEnter?.(event, event.currentTarget.value);
        if (selfClear) {
          event.currentTarget.value = '';
        }
        event.currentTarget.blur();
        return;
      }

      if (event.key === KEY.Escape) {
        onEscape?.(event);
        if (selfClear) {
          event.currentTarget.value = '';
        } else {
          event.currentTarget.value = toInputValue(value);
          event.currentTarget.blur();
        }

        return;
      }

      if (!dontUseTabForIndent && event.key === KEY.Tab) {
        event.preventDefault();
        const { value, selectionStart, selectionEnd } = event.currentTarget;
        event.currentTarget.value =
          value.substring(0, selectionStart) +
          '\t' +
          value.substring(selectionEnd);
        event.currentTarget.selectionEnd = selectionStart + 1;
      }
    };

    useImperativeHandle(
      forwardedRef,
      () => textareaRef.current as HTMLTextAreaElement,
    );

    /** Focuses the input on mount */
    useEffect(() => {
      if (!autoFocus && !autoSelect) return;

      const input = textareaRef.current;
      if (!input) return;

      input.value = toInputValue(value);

      if (autoFocus || autoSelect) {
        setTimeout(() => {
          input.focus();

          if (autoSelect) {
            input.select();
          }
        }, 1);
      }
    }, []);

    /** Updates the initial value on props change */
    useEffect(() => {
      const input = textareaRef.current;
      if (!input) return;

      const newValue = toInputValue(value);
      if (input.value === newValue) return;

      input.value = newValue;
    }, [value]);

    return (
      <Box
        className={classes([
          'TextArea',
          fluid && 'TextArea--fluid',
          noborder && 'TextArea--noborder',
          className,
        ])}
        {...rest}
      >
        {!!displayedValue && (
          <div
            style={{
              height: '100%',
              overflow: 'hidden',
              position: 'absolute',
              width: '100%',
            }}
          >
            <div
              className={classes([
                'TextArea__textarea',
                'TextArea__textarea_custom',
              ])}
              style={{
                transform: `translateY(-${scrolledAmount}px)`,
              }}
            >
              {displayedValue}
            </div>
          </div>
        )}
        <textarea
          className={classes([
            'TextArea__textarea',
            scrollbar && 'TextArea__textarea--scrollable',
            nowrap && 'TextArea__nowrap',
          ])}
          maxLength={maxLength}
          onBlur={(event) => onChange?.(event, event.target.value)}
          onChange={(event) => onInput?.(event, event.target.value)}
          onKeyDown={handleKeyDown}
          onScroll={() => {
            if (displayedValue && textareaRef.current) {
              setScrolledAmount(textareaRef.current.scrollTop);
            }
          }}
          placeholder={placeholder}
          ref={textareaRef}
          style={{
            color: displayedValue ? 'rgba(0, 0, 0, 0)' : 'inherit',
          }}
        />
      </Box>
    );
  },
);
