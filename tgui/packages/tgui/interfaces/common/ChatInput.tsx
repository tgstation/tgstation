import '../../styles/interfaces/ChatInput.scss';

import {
  type CSSProperties,
  type ReactNode,
  useEffect,
  useRef,
  useState,
} from 'react';
import { Stack } from 'tgui-core/components';
import { KEY } from 'tgui-core/keys';
import { classes } from 'tgui-core/react';

type ChatInputProps = {
  /** Custom css classes */
  className?: string;
  /** The placeholder text when everything is cleared */
  placeholder?: string;
  /** Text of the input */
  value: string;
  /** Disables the input. Outlined in gray */
  disabled?: boolean;
  /** Disables input until cooldown is over. Also prevents any actions */
  cooldown?: number | false;
  /** The maximum length of the input value */
  maxLength?: number;
  /** Buttons right of the input */
  buttons?: ReactNode;
  /** Fires each time the input has been changed */
  onChange: (value: string) => void;
  /** Fires once the enter key is pressed */
  onEnter: (value: string) => void;
};

export function ChatInput(props: ChatInputProps) {
  const {
    className,
    value,
    placeholder = 'Начинайте писать...',
    disabled,
    cooldown,
    buttons,
    maxLength,
    onChange,
    onEnter,
  } = props;

  const [editing, setEditing] = useState(false);
  const [cooldownLeft, setCooldownLeft] = useState<number | null>(null);
  const [cooldownFinished, setCooldownFinished] = useState(false);
  const textRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const text = textRef.current;
    if (text && text.innerText !== value) {
      text.innerText = value;
    }
  }, [value]);

  function startCooldown(deciseconds: number) {
    const duration = deciseconds * 100;
    const start = performance.now();

    function frame(now: number) {
      const elapsed = now - start;
      const progress = Math.min(elapsed / duration, 1);
      setCooldownLeft(progress * 100);

      if (progress === 1) {
        setCooldownLeft(null);
        setCooldownFinished(true);
        return;
      }

      requestAnimationFrame(frame);
    }

    requestAnimationFrame(frame);
  }

  function handleInput() {
    const text = textRef.current;
    if (!text) {
      return;
    }

    let newValue = text.innerText;
    if (text.innerHTML === '<br>') {
      text.innerHTML = '';
      newValue = '';
    }

    if (maxLength && newValue.length > maxLength) {
      newValue = newValue.slice(0, maxLength);
      text.innerText = newValue;

      const range = document.createRange();
      const sel = window.getSelection();
      range.selectNodeContents(text);
      range.collapse(false);
      sel?.removeAllRanges();
      sel?.addRange(range);
    }

    onChange(newValue);
  }

  function handlePaste(event: React.ClipboardEvent<HTMLDivElement>) {
    event.preventDefault();

    const text = event.clipboardData.getData('text/plain');
    const selection = window.getSelection();
    if (!selection || !selection.rangeCount) {
      return;
    }

    selection.deleteFromDocument();
    selection.getRangeAt(0).insertNode(document.createTextNode(text));
    selection.collapseToEnd();
    textRef.current?.scrollTo(0, textRef.current.scrollHeight);
    handleInput();
  }

  function handleKeyDown(event: React.KeyboardEvent<HTMLDivElement>): void {
    event.stopPropagation();
    const text = textRef.current;
    if (!text) {
      return;
    }

    if (event.key === KEY.Enter && !disabled) {
      event.preventDefault();
      if (cooldown && cooldownLeft) {
        return;
      }

      onEnter?.(text?.innerText || '');
      if (cooldown) {
        text.blur();
        setCooldownFinished(false);
        startCooldown(cooldown);
      }
    }
    return;
  }

  return (
    <Stack
      fill
      className={classes([
        'ChatInput',
        disabled && 'ChatInput--disabled',
        cooldownLeft && 'ChatInput--cooldown',
        cooldownFinished && 'ChatInput--flash',
        editing && 'editing',
      ])}
      style={
        cooldownLeft
          ? ({ '--cooldown': `${cooldownLeft}%` } as CSSProperties)
          : undefined
      }
    >
      <div
        ref={textRef}
        contentEditable={!disabled}
        data-placeholder={placeholder}
        className={classes([
          'ChatInput__Text',
          !value && 'ChatInput__Text--placeholder',
          className,
        ])}
        autoCorrect="off"
        spellCheck={false}
        onBlur={() => setEditing(false)}
        onFocus={() => setEditing(true)}
        onInput={handleInput}
        onKeyDown={handleKeyDown}
        onPaste={handlePaste}
      />
      <Stack.Item p={0.66}>
        <Stack fill vertical>
          <Stack.Item grow>{buttons || ''}</Stack.Item>
          {maxLength && maxLength - value.length <= 300 && (
            <Stack.Item className="ChatInput__LeftCharacters">
              {maxLength - value.length}
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
    </Stack>
  );
}
