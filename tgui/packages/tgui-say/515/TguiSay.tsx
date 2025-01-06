import './styles/main.scss';

import { Component, createRef, RefObject } from 'react';
import { dragStartHandler } from 'tgui/drag';
import { isEscape, KEY } from 'tgui-core/keys';
import { BooleanLike } from 'tgui-core/react';

import { Channel, ChannelIterator } from '../ChannelIterator';
import { ChatHistory } from '../ChatHistory';
import { byondMessages } from '../timers';
import { LINE_LENGTHS, RADIO_PREFIXES, WINDOW_SIZES } from './constants';
import { windowClose, windowOpen, windowSet } from './helpers';

type ByondOpen = {
  channel: Channel;
};

type ByondProps = {
  maxLength: number;
  lightMode: BooleanLike;
};

type State = {
  buttonContent: string | number;
  size: WINDOW_SIZES;
};

const CHANNEL_REGEX = /^[:.]\w\s/;

export class TguiSay extends Component<{}, State> {
  private channelIterator: ChannelIterator;
  private chatHistory: ChatHistory;
  private currentPrefix: keyof typeof RADIO_PREFIXES | null;
  private innerRef: RefObject<HTMLTextAreaElement>;
  private lightMode: boolean;
  private maxLength: number;
  private messages: typeof byondMessages;
  state: State;

  constructor(props: never) {
    super(props);

    this.channelIterator = new ChannelIterator();
    this.chatHistory = new ChatHistory();
    this.currentPrefix = null;
    this.innerRef = createRef();
    this.lightMode = false;
    this.maxLength = 1024;
    this.messages = byondMessages;
    this.state = {
      buttonContent: '',
      size: WINDOW_SIZES.small,
    };

    this.handleArrowKeys = this.handleArrowKeys.bind(this);
    this.handleBackspaceDelete = this.handleBackspaceDelete.bind(this);
    this.handleClose = this.handleClose.bind(this);
    this.handleEnter = this.handleEnter.bind(this);
    this.handleForceSay = this.handleForceSay.bind(this);
    this.handleIncrementChannel = this.handleIncrementChannel.bind(this);
    this.handleInput = this.handleInput.bind(this);
    this.handleKeyDown = this.handleKeyDown.bind(this);
    this.handleOpen = this.handleOpen.bind(this);
    this.handleProps = this.handleProps.bind(this);
    this.reset = this.reset.bind(this);
    this.setSize = this.setSize.bind(this);
    this.setValue = this.setValue.bind(this);
  }

  componentDidMount() {
    Byond.subscribeTo('props', this.handleProps);
    Byond.subscribeTo('force', this.handleForceSay);
    Byond.subscribeTo('open', this.handleOpen);
  }

  handleArrowKeys(direction: KEY.Up | KEY.Down) {
    const currentValue = this.innerRef.current?.value;

    if (direction === KEY.Up) {
      if (this.chatHistory.isAtLatest() && currentValue) {
        // Save current message to temp history if at the most recent message
        this.chatHistory.saveTemp(currentValue);
      }
      // Try to get the previous message, fall back to the current value if none
      const prevMessage = this.chatHistory.getOlderMessage();

      if (prevMessage) {
        this.setState({ buttonContent: this.chatHistory.getIndex() });
        this.setSize(prevMessage.length);
        this.setValue(prevMessage);
      }
    } else {
      const nextMessage =
        this.chatHistory.getNewerMessage() || this.chatHistory.getTemp() || '';

      const buttonContent = this.chatHistory.isAtLatest()
        ? this.channelIterator.current()
        : this.chatHistory.getIndex();

      this.setState({ buttonContent });
      this.setSize(nextMessage.length);
      this.setValue(nextMessage);
    }
  }

  handleBackspaceDelete() {
    const typed = this.innerRef.current?.value;

    // User is on a chat history message
    if (!this.chatHistory.isAtLatest()) {
      this.chatHistory.reset();
      this.setState({
        buttonContent: this.currentPrefix ?? this.channelIterator.current(),
      });
      // Empty input, resets the channel
    } else if (
      !!this.currentPrefix &&
      this.channelIterator.isSay() &&
      typed?.length === 0
    ) {
      this.currentPrefix = null;
      this.setState({ buttonContent: this.channelIterator.current() });
    }

    this.setSize(typed?.length);
  }

  handleClose() {
    const current = this.innerRef.current;

    if (current) {
      current.blur();
    }

    this.reset();
    this.chatHistory.reset();
    this.channelIterator.reset();
    this.currentPrefix = null;
    windowClose();
  }

  handleEnter() {
    const prefix = this.currentPrefix ?? '';
    const value = this.innerRef.current?.value;

    if (value?.length && value.length < this.maxLength) {
      this.chatHistory.add(value);
      Byond.sendMessage('entry', {
        channel: this.channelIterator.current(),
        entry: this.channelIterator.isSay() ? prefix + value : value,
      });
    }

    this.handleClose();
  }

  handleForceSay() {
    const currentValue = this.innerRef.current?.value;
    // Only force say if we're on a visible channel and have typed something
    if (!currentValue || !this.channelIterator.isVisible()) return;

    const prefix = this.currentPrefix ?? '';
    const grunt = this.channelIterator.isSay()
      ? prefix + currentValue
      : currentValue;

    this.messages.forceSayMsg(grunt, this.channelIterator.current());
    this.reset();
  }

  handleIncrementChannel() {
    // Binary talk is a special case, tell byond to show thinking indicators
    if (this.channelIterator.isSay() && this.currentPrefix === ':b ') {
      this.messages.channelIncrementMsg(true);
    }

    this.currentPrefix = null;

    this.channelIterator.next();

    // If we've looped onto a quiet channel, tell byond to hide thinking indicators
    if (!this.channelIterator.isVisible()) {
      this.messages.channelIncrementMsg(false);
    }

    this.setState({ buttonContent: this.channelIterator.current() });
  }

  handleInput() {
    const typed = this.innerRef.current?.value;

    // If we're typing, send the message
    if (this.channelIterator.isVisible() && this.currentPrefix !== ':b ') {
      this.messages.typingMsg();
    }

    this.setSize(typed?.length);

    // Is there a value? Is it long enough to be a prefix?
    if (!typed || typed.length < 3) {
      return;
    }

    if (!CHANNEL_REGEX.test(typed)) {
      return;
    }

    // Is it a valid prefix?
    const prefix = typed
      .slice(0, 3)
      ?.toLowerCase()
      ?.replace('.', ':') as keyof typeof RADIO_PREFIXES;
    if (!RADIO_PREFIXES[prefix] || prefix === this.currentPrefix) {
      return;
    }

    // If we're in binary, hide the thinking indicator
    if (prefix === ':b ') {
      Byond.sendMessage('thinking', { visible: false });
    }

    this.channelIterator.set('Say');
    this.currentPrefix = prefix;
    this.setState({ buttonContent: RADIO_PREFIXES[prefix] });
    this.setValue(typed.slice(3));
  }

  handleKeyDown(event) {
    switch (event.key) {
      case KEY.Up:
      case KEY.Down:
        event.preventDefault();
        this.handleArrowKeys(event.key);
        break;

      case KEY.Delete:
      case KEY.Backspace:
        this.handleBackspaceDelete();
        break;

      case KEY.Enter:
        event.preventDefault();
        this.handleEnter();
        break;

      case KEY.Tab:
        event.preventDefault();
        this.handleIncrementChannel();
        break;

      default:
        if (isEscape(event.key)) {
          this.handleClose();
        }
    }
  }

  handleOpen = (data: ByondOpen) => {
    setTimeout(() => {
      this.innerRef.current?.focus();
    }, 0);

    const { channel } = data;
    // Catches the case where the modal is already open
    if (this.channelIterator.isSay()) {
      this.channelIterator.set(channel);
    }
    this.setState({ buttonContent: this.channelIterator.current() });

    windowOpen(this.channelIterator.current());
  };

  handleProps = (data: ByondProps) => {
    const { maxLength, lightMode } = data;
    this.maxLength = maxLength;
    this.lightMode = !!lightMode;
  };

  reset() {
    this.currentPrefix = null;
    this.setValue('');
    this.setSize();
    this.setState({
      buttonContent: this.channelIterator.current(),
    });
  }

  setSize(length = 0) {
    let newSize: WINDOW_SIZES;

    if (length > LINE_LENGTHS.medium) {
      newSize = WINDOW_SIZES.large;
    } else if (length <= LINE_LENGTHS.medium && length > LINE_LENGTHS.small) {
      newSize = WINDOW_SIZES.medium;
    } else {
      newSize = WINDOW_SIZES.small;
    }

    if (this.state.size !== newSize) {
      this.setState({ size: newSize });
      windowSet(newSize);
    }
  }

  setValue(value: string) {
    const textArea = this.innerRef.current;
    if (textArea) {
      textArea.value = value;
    }
  }

  render() {
    const theme =
      (this.lightMode && 'lightMode') ||
      (this.currentPrefix && RADIO_PREFIXES[this.currentPrefix]) ||
      this.channelIterator.current();

    return (
      <div
        className={`old-window old-window-${theme} old-window-${this.state.size}`}
      >
        <Dragzone position="top" theme={theme} />
        <div className="old-center">
          <Dragzone position="left" theme={theme} />
          <div className="old-input">
            <button
              className={`old-button old-button-${theme}`}
              onClick={this.handleIncrementChannel}
              type="button"
            >
              {this.state.buttonContent}
            </button>
            <textarea
              className={`old-textarea old-textarea-${theme}`}
              maxLength={this.maxLength}
              onInput={this.handleInput}
              onKeyDown={this.handleKeyDown}
              ref={this.innerRef}
            />
          </div>
          <Dragzone position="right" theme={theme} />
        </div>
        <Dragzone position="bottom" theme={theme} />
      </div>
    );
  }
}

const Dragzone = ({ theme, position }: { theme: string; position: string }) => {
  // Horizontal or vertical?
  const location =
    position === 'left' || position === 'right' ? 'vertical' : 'horizontal';

  return (
    <div
      className={`old-dragzone-${location} old-dragzone-${position} old-dragzone-${theme}`}
      onMouseDown={dragStartHandler}
    />
  );
};
