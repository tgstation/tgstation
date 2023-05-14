import { Channel, ChannelIterator } from './ChannelIterator';
import { ChatHistory } from './ChatHistory';
import { Component, createRef, InfernoKeyboardEvent } from 'inferno';
import { LINE_LENGTHS, RADIO_PREFIXES, WINDOW_SIZES } from './constants';
import { byondMessages } from './timers';
import { dragStartHandler } from 'tgui/drag';
import { windowOpen, windowLoad, windowClose, windowSet } from './helpers';
import { BooleanLike } from 'common/react';
import { KEY } from 'common/keys';

type ByondProps = {
  maxLength: number;
  lightMode: BooleanLike;
};

type ByondOpen = {
  channel: Channel;
};

type State = {
  buttonContent: string | number;
  size: WINDOW_SIZES;
};

const channelRegex = /^:\w\s/;

export class TguiSay extends Component<{}, State> {
  private channelIterator: ChannelIterator;
  private chatHistory: ChatHistory;
  private currentPrefix: keyof typeof RADIO_PREFIXES | null;
  private innerRef: any;
  private lightMode: boolean;
  private maxLength: number;
  private messages: any;
  state: State;

  constructor(props: any) {
    super(props);

    this.channelIterator = new ChannelIterator();
    this.chatHistory = new ChatHistory();
    this.currentPrefix = null;
    this.innerRef = createRef<HTMLTextAreaElement>();
    this.lightMode = false;
    this.maxLength = 1024;
    this.messages = byondMessages;
    this.state = {
      buttonContent: '',
      size: WINDOW_SIZES.small,
    };

    this.handleArrowKeys = this.handleArrowKeys.bind(this);
    this.handleBackspaceDelete = this.handleBackspaceDelete.bind(this);
    this.handleEnter = this.handleEnter.bind(this);
    this.handleEscape = this.handleEscape.bind(this);
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
    this.subscribeToByondEvents();
    windowLoad();
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
        this.setState({
          buttonContent: this.chatHistory.getIndex(),
          size: prevMessage.length,
        });
        this.setSize(prevMessage.length);
        this.setValue(prevMessage);
      }
    } else {
      const nextMessage =
        this.chatHistory.getNewerMessage() || this.chatHistory.getTemp() || '';
      const index = this.chatHistory.getIndex() - 1;
      const content = index <= 0 ? this.channelIterator.current() : index;

      this.setState({
        buttonContent: content,
      });
      this.setSize(nextMessage.length);
      this.setValue(nextMessage);
    }
  }

  handleBackspaceDelete() {
    const current = this.innerRef.current;
    const { buttonContent } = this.state;

    // User is on a chat history message
    if (typeof buttonContent === 'number') {
      this.chatHistory.reset();
      this.setState({ buttonContent: this.channelIterator.current() });
    }

    if (!current?.value) {
      return;
    }

    if (this.currentPrefix) {
      this.currentPrefix = null;
      this.setState({ buttonContent: this.channelIterator.current() });
    }

    this.setSize(current?.value?.length);
  }

  handleEnter() {
    Byond.sendMessage('escaped');
    const prefix = this.currentPrefix ?? '';
    const value = this.innerRef.current?.value;

    if (value?.length && value.length < this.maxLength) {
      this.chatHistory.add(value);
      Byond.sendMessage('entry', {
        channel: this.channelIterator.current(),
        entry: this.channelIterator.isSay() ? prefix + value : value,
      });
    }

    this.reset();
    windowClose();
  }

  handleEscape() {
    const current = this.innerRef?.current;

    if (current) {
      current.blur();
    }

    this.reset();
    windowClose();
  }

  handleForceSay() {
    const currentValue = this.innerRef.current?.value;
    if (!currentValue || !this.channelIterator.isVisible()) return;

    const grunt = this.channelIterator.isSay()
      ? this.currentPrefix + currentValue
      : currentValue;

    this.messages.forceSayMsg(grunt);
    this.reset();
  }

  handleIncrementChannel() {
    if (this.channelIterator.isSay() && this.currentPrefix === ':b ') {
      this.messages.channelIncrementMsg(true);
    }

    this.currentPrefix = null;

    this.channelIterator.next();

    // If we've looped onto a quiet channel, tell byond to hide thinking indicators
    if (!this.channelIterator.isVisible()) {
      this.messages.channelIncrementMsg(false);
    }

    this.setState({
      buttonContent: this.channelIterator.current(),
    });
  }

  handleInput() {
    const currentValue = this.innerRef?.current?.value;
    if (!currentValue) return;

    // If we're typing, send the message
    if (this.channelIterator.isVisible() && this.currentPrefix !== ':b ') {
      this.messages.typingMsg();
    }

    this.setSize(currentValue.length ?? 0);

    // Is there a value? Is it long enough to be a prefix?
    if (!currentValue || currentValue.length < 3) {
      return;
    }

    // Are we talking?
    if (!this.channelIterator.isSay() || !channelRegex.test(currentValue)) {
      return;
    }

    // Is it a valid prefix?
    const prefix = currentValue.slice(0, 3) as keyof typeof RADIO_PREFIXES;
    if (!RADIO_PREFIXES[prefix] || prefix === this.currentPrefix) {
      return;
    }

    // If we're in binary, hide the thinking indicator
    if (prefix === ':b ') {
      Byond.sendMessage('thinking', { visible: false });
    }

    this.currentPrefix = prefix;
    this.setState({
      buttonContent: RADIO_PREFIXES[prefix],
    });
    this.setValue(currentValue.slice(3));
  }

  handleKeyDown(event: InfernoKeyboardEvent<HTMLTextAreaElement>) {
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

      case KEY.Escape:
        this.handleEscape();
        break;
    }
  }

  handleOpen = (data: ByondOpen) => {
    const { channel } = data;
    this.channelIterator.set(channel);
    this.setState({ buttonContent: this.channelIterator.current() });
    setTimeout(() => {
      this.innerRef?.current?.focus();
    }, 1);
    windowOpen(this.channelIterator.current());
  };

  handleProps = (data: ByondProps) => {
    const { maxLength, lightMode } = data;
    this.maxLength = maxLength;
    this.lightMode = !!lightMode;
  };

  reset() {
    this.currentPrefix = null;
    this.channelIterator.reset();
    this.chatHistory.reset();
    windowSet();
    this.setState({
      buttonContent: this.channelIterator.current(),
      size: WINDOW_SIZES.small,
    });
    this.setValue('');
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

  subscribeToByondEvents() {
    Byond.subscribeTo('props', this.handleProps);
    Byond.subscribeTo('force', this.handleForceSay);
    Byond.subscribeTo('open', this.handleOpen);
  }

  render() {
    const { buttonContent, size } = this.state;

    const theme =
      (this.lightMode && 'lightMode') ||
      (this.currentPrefix && RADIO_PREFIXES[this.currentPrefix]) ||
      this.channelIterator.current();

    return (
      <div
        className={`window window-${theme} window-${size}`}
        $HasKeyedChildren>
        <Dragzone position="top" theme={theme} />
        <div className="center" $HasKeyedChildren>
          <Dragzone position="left" theme={theme} />
          <div className="input" $HasKeyedChildren>
            <button
              className={`button button-${theme}`}
              onClick={this.handleIncrementChannel}
              type="submit">
              {buttonContent}
            </button>
            <textarea
              className={`textarea textarea-${theme}`}
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
  const location =
    position === 'top' || position === 'bottom' ? 'horizontal' : 'vertical';

  return (
    <div
      className={`dragzone-${position} dragzone-${location} dragzone-${theme}`}
      onmousedown={dragStartHandler}
    />
  );
};
