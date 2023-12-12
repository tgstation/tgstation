/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @author Warlockd
 * @license MIT
 */

import { classes } from 'common/react';
import {
  forwardRef,
  useEffect,
  useState,
  RefObject,
  useRef,
  useImperativeHandle,
} from 'react';
import { toInputValue } from './Input';
import { KEY } from 'common/keys';
import { Box, BoxProps } from './Box';
import { ChangeEvent, KeyboardEvent, FocusEvent } from 'react';

type Props = Partial<{
  autoFocus: boolean;
  autoSelect: boolean;
  displayedValue: string;
  dontUseTabForIndent: boolean;
  maxLength: number;
  noborder: boolean;
  // This fires when: clicked out, entered, escaped.
  onBlur: (event: FocusEvent<HTMLTextAreaElement>, value: string) => void;
  // This fires when: value changes
  onChange: (event: ChangeEvent<HTMLTextAreaElement>, value: string) => void;
  // This fires when: enter is pressed
  onEnter: (event: KeyboardEvent<HTMLTextAreaElement>, value: string) => void;
  // This fires when: escape is pressed
  onEscape: (event: KeyboardEvent<HTMLTextAreaElement>) => void;
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
      onBlur,
      onChange,
      onEnter,
      onEscape,
      placeholder,
      scrollbar,
      selfClear,
      value,
      ...boxProps
    } = props;
    const { className, fluid, nowrap, ...rest } = boxProps;
    const textareaRef = useRef<HTMLTextAreaElement>(null);

    const [scrolledAmount, setScrolledAmount] = useState(0);

    const handleKeyDown = (event) => {
      if (event.key === KEY.Enter) {
        onEnter?.(event, event.target.value);

        if (selfClear) {
          event.target.value = '';
        }
        event.target.blur();

        return;
      }

      if (event.key === KEY.Escape) {
        onEscape?.(event);

        if (selfClear) {
          event.target.value = '';
        } else {
          event.target.value = toInputValue(value);
          event.target.blur();
        }

        return;
      }

      if (!dontUseTabForIndent && event.key === KEY.Tab) {
        event.preventDefault();
        const { value, selectionStart, selectionEnd } = event.target;
        event.target.value =
          value.substring(0, selectionStart) +
          '\t' +
          value.substring(selectionEnd);
        event.target.selectionEnd = selectionStart + 1;
        onChange?.(event, event.target.value);
      }
    };

    useImperativeHandle(
      forwardedRef,
      () => textareaRef.current as HTMLTextAreaElement,
    );

    useEffect(() => {
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
          onBlur={(event) => onBlur?.(event, event.target.value)}
          onChange={(event) => onChange?.(event, event.target.value)}
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
