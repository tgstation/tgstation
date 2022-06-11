import { Component, createRef, RefObject } from 'inferno';
import { TextArea } from 'tgui/components';
import { CHANNELS, RADIO_PREFIXES, SIZE } from '../constants/constants';
import { Dragzone } from '../components/dragzone';
import { KEY_BACKSPACE, KEY_DELETE, KEY_DOWN, KEY_TAB, KEY_UP } from 'common/keycodes';
import { getCss, getHistoryAt, getHistoryLength, isAlphanumeric, storeChat, valueExists, windowClose, windowLoad, windowOpen, windowSet } from '../helpers/helpers';
import { debounce, throttle } from 'common/timer';

type State = {
  buttonContent: string | number;
  channel: number;
  edited: boolean;
  size: number;
};

/** Primary class for the TGUI modal. */
export class TguiModal extends Component<{}, State> {
  channelDebounce = debounce(
    (mode) => Byond.sendMessage('thinking', mode),
    400
  );
  forceDebounce = debounce(
    (entry) => Byond.sendMessage('force', entry),
    1000,
    true
  );
  historyCounter: number;
  innerRef: RefObject<HTMLInputElement> = createRef();
  maxLength: number;
  radioPrefix: string;
  typingThrottle = throttle(() => Byond.sendMessage('typing'), 4000);
  value: string;
  state: State = {
    buttonContent: '',
    channel: -1,
    edited: false,
    size: SIZE.small,
  };

  /** Increments the chat history counter, looping through entries */
  handleArrowKeys = (direction: number) => {
    const { historyCounter } = this;
    if (direction === KEY_UP && historyCounter < getHistoryLength()) {
      this.historyCounter++;
      this.viewHistory();
    } else if (direction === KEY_DOWN && historyCounter > 0) {
      this.historyCounter--;
      this.viewHistory();
    }
  };

  /**
   * 1. Ensures backspace and delete reset size
   * 2. Resets history if editing a message
   * 3. Backspacing while empty resets any radio subchannels
   */
  handleBackspaceDelete = () => {
    const { buttonContent, channel } = this.state;
    const { radioPrefix, value } = this;
    // User is on a chat history message
    if (typeof buttonContent === 'number') {
      this.historyCounter = 0;
      this.setState({ buttonContent: CHANNELS[channel] });
    }
    if (!value.length && radioPrefix) {
      this.radioPrefix = '';
      this.setState({ buttonContent: CHANNELS[channel] });
    }
    this.setSize(value.length);
  };

  /**
   * User clicks the channel button.
   * Simulates the tab key.
   */
  handleClick = () => {
    this.incrementChannel();
  };

  /** User presses enter. Closes if no value. */
  handleEnter = (event: KeyboardEvent, value: string) => {
    const { channel } = this.state;
    const { maxLength, radioPrefix } = this;
    event.preventDefault();
    if (value && value.length < maxLength) {
      storeChat(value);
      Byond.sendMessage('entry', {
        channel: CHANNELS[channel],
        entry: channel === 0 ? radioPrefix + value : value,
      });
    }
    this.reset();
    windowClose();
  };

  /** User presses escape, closes the window */
  handleEscape = () => {
    this.reset();
    windowClose();
  };

  /** Sends the current input to byond and purges it */
  handleForce = () => {
    const { channel, size } = this.state;
    const { radioPrefix, value } = this;
    if (value && channel < 2) {
      this.forceDebounce({
        channel: CHANNELS[channel],
        entry: channel === 0 ? radioPrefix + value : value,
      });
      this.reset(channel);
      if (size !== SIZE.small) {
        windowSet();
      }
    }
  };

  /**
   * Grabs input and sets size, force values etc.
   * Input value only triggers a rerender on setEdited.
   */
  handleInput = (_, value: string) => {
    this.value = value;
    this.radioHandler();
    this.setSize(value.length);
  };

  /**
   * Handles other key events.
   * TAB - Changes channels.
   * UP/DOWN - Sets history counter and input value.
   * BKSP/DEL - Resets history counter and checks window size.
   * TYPING - When users key, it tells byond that it's typing.
   *
   */
  handleKeyDown = (event: KeyboardEvent) => {
    const { channel } = this.state;
    const { radioPrefix } = this;
    if (!event.keyCode) {
      return; // Really doubt it, but...
    }
    if (isAlphanumeric(event.keyCode)) {
      if (channel < 2 && radioPrefix !== ':b ') {
        this.typingThrottle();
      }
    }
    if (event.keyCode === KEY_UP || event.keyCode === KEY_DOWN) {
      if (getHistoryLength()) {
        this.handleArrowKeys(event.keyCode);
      }
    }
    if (event.keyCode === KEY_DELETE || event.keyCode === KEY_BACKSPACE) {
      this.handleBackspaceDelete();
    }
    if (event.keyCode === KEY_TAB) {
      this.incrementChannel();
      event.preventDefault();
    }
  };

  /**
   * Increments the channel or resets to the beginning of the list.
   * If the user switches between IC/OOC, messages Byond to toggle thinking
   * indicators.
   */
  incrementChannel = () => {
    const { channel } = this.state;
    const { radioPrefix } = this;
    if (radioPrefix === ':b ') {
      this.channelDebounce({ mode: true });
    }
    this.radioPrefix = '';
    if (channel === CHANNELS.length - 1) {
      this.channelDebounce({ mode: true });
      this.setState({
        buttonContent: CHANNELS[0],
        channel: 0,
      });
    } else {
      if (channel === 1) {
        this.channelDebounce({ mode: false });
      }
      this.setState({
        buttonContent: CHANNELS[channel + 1],
        channel: channel + 1,
      });
    }
  };

  /**
   * Gets any channel prefixes from the chat bar
   * and changes to the corresponding radio subchannel.
   *
   * Exemptions: Channel is OOC, value is too short,
   * Not a valid radio pref, or value is already the radio pref.
   */
  radioHandler = () => {
    const { channel } = this.state;
    const { radioPrefix, value } = this;
    if (channel > 1 || value.length < 3) {
      return;
    }
    const currentPrefix = value.slice(0, 3)?.toLowerCase();
    if (!RADIO_PREFIXES[currentPrefix] || radioPrefix === currentPrefix) {
      return;
    }
    this.value = value.slice(3);
    this.radioPrefix = currentPrefix;
    // Binary is a "secret" channel
    if (currentPrefix === ':b ') {
      Byond.sendMessage('thinking', { mode: false });
    } else {
      Byond.sendMessage('thinking', { mode: true });
    }
    this.setState({
      buttonContent: RADIO_PREFIXES[currentPrefix]?.label,
      channel: 0,
      edited: true,
    });
  };

  /**
   * Resets window to default parameters.
   *
   * Parameters:
   * channel - Optional. Sets the channel and thus the color scheme.
   */
  reset = (channel?: number) => {
    this.historyCounter = 0;
    this.radioPrefix = '';
    this.value = '';
    this.setState({
      buttonContent: valueExists(channel) ? CHANNELS[channel!] : '',
      channel: valueExists(channel) ? channel! : -1,
      edited: true,
      size: SIZE.small,
    });
  };

  /**  Adjusts window sized based on event.target.value */
  setSize = (value: number) => {
    const { size } = this.state;
    if (value > 51 && size !== SIZE.large) {
      this.setState({ size: SIZE.large });
      windowSet(SIZE.large);
    } else if (value <= 51 && value > 22 && size !== SIZE.medium) {
      this.setState({ size: SIZE.medium });
      windowSet(SIZE.medium);
    } else if (value <= 22 && size !== SIZE.small) {
      this.setState({ size: SIZE.small });
      windowSet(SIZE.small);
    }
  };

  /** Triggers a refresh in the event something changes input (by force) */
  unsetEdited = () => {
    this.setState({ edited: false });
  };

  /**  Sets the input value to chat history at index historyCounter. */
  viewHistory = () => {
    const { channel } = this.state;
    const { historyCounter } = this;
    if (historyCounter > 0 && getHistoryLength()) {
      this.value = getHistoryAt(historyCounter);
      if (channel < 2) {
        this.typingThrottle();
      }
      this.setState({ buttonContent: historyCounter, edited: true });
      this.setSize(0);
    } else {
      this.value = '';
      this.setState({
        buttonContent: CHANNELS[channel],
        edited: true,
      });
      this.setSize(0);
    }
  };

  /** Attach listeners, sets window size just in case */
  componentDidMount() {
    Byond.subscribeTo('maxLength', (data) => {
      this.maxLength = data.maxLength;
    });
    Byond.subscribeTo('force', () => {
      this.handleForce();
    });
    Byond.subscribeTo('open', (data) => {
      const channel = CHANNELS.indexOf(data.channel) || 0;
      this.reset(channel);
      setTimeout(() => {
        this.innerRef?.current?.focus();
      }, 1);
      windowOpen(CHANNELS[channel]);
    });
    windowLoad();
  }

  /** After updating the input value, sets back to false */
  componentDidUpdate() {
    if (this.state.edited) {
      this.unsetEdited();
    }
  }

  render() {
    const {
      handleClick,
      handleEnter,
      handleEscape,
      handleInput,
      handleKeyDown,
      innerRef,
      maxLength,
      radioPrefix,
      value,
    } = this;
    const { buttonContent, channel, edited, size } = this.state;
    const prefixOrChannel
      = RADIO_PREFIXES[radioPrefix]?.id || CHANNELS[channel]?.toLowerCase();

    return (
      <div
        className={getCss('window', prefixOrChannel, size)}
        $HasKeyedChildren>
        <Dragzone horizontal />
        <div className="window__content" $HasKeyedChildren>
          <Dragzone vertical />
          {size < SIZE.medium && (
            <button
              className={getCss('button', prefixOrChannel)}
              onclick={handleClick}
              type="submit">
              {buttonContent}
            </button>
          )}
          <TextArea
            className={getCss('input', prefixOrChannel)}
            dontUseTabForIndent
            innerRef={innerRef}
            maxLength={maxLength}
            onEnter={handleEnter}
            onEscape={handleEscape}
            onInput={handleInput}
            onKeyDown={handleKeyDown}
            selfClear
            value={edited && value}
          />
          <Dragzone vertical />
        </div>
        <Dragzone horizontal />
      </div>
    );
  }
}
