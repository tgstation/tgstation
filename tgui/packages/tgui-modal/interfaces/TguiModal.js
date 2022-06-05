import { Component } from 'inferno';
import { TextArea } from 'tgui/components';
import { CHANNELS, SIZE } from '../constants/constants';
import {
  KEY_BACKSPACE,
  KEY_DELETE,
  KEY_DOWN,
  KEY_TAB,
  KEY_UP,
} from 'common/keycodes';
import {
  CooldownWrapper,
  getCss,
  getHistoryAt,
  getHistoryLength,
  isAlphanumeric,
  storeChat,
  windowClose,
  windowLoad,
  windowOpen,
  windowSet,
} from '../helpers/helpers';

/** Primary class for the TGUI modal. */
export class TguiModal extends Component {
  constructor() {
    super();
    this.historyCounter = 0;
    this.innerRef = null;
    this.maxLength = 1024;
    this.typingCooldown = null;
    this.value = '';
    this.state = {
      buttonContent: null,
      channel: -1,
      edited: false,
      size: SIZE.small,
    };
  }
  /** Increments the chat history counter, looping through entries */
  handleArrowKeys = (direction) => {
    const { historyCounter } = this;
    if (direction === KEY_UP && historyCounter < getHistoryLength()) {
      this.historyCounter++;
      this.viewHistory();
    } else if (direction === KEY_DOWN && historyCounter > 0) {
      this.historyCounter--;
      this.viewHistory();
    }
  };
  /** Ensures backspace and delete reset size and history */
  handleBkspDelete = (value) => {
    const { buttonContent, channel } = this.state;
    this.historyCounter = 0;
    // User is on a chat history message
    if (typeof buttonContent === 'number') {
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
  handleEnter = (event, value) => {
    const { channel } = this.state;
    const { maxLength } = this;
    event.preventDefault();
    if (value && value.length < maxLength) {
      storeChat(value);
      Byond.sendMessage('entry', {
        channel: CHANNELS[channel],
        entry: value,
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
    const { value } = this;
    if (value && channel < 2) {
      Byond.sendMessage('force', {
        channel: CHANNELS[channel],
        entry: value,
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
  handleInput = (_, value) => {
    this.value = value;
    this.setSize(value.length);
  };
  /**
   * Handles other key events.
   * TAB - Changes channels.
   * UP/DOWN - Sets history counter and input value.
   * BKSP/DEL - Resets history counter and checks window size.
   * TYPING - When users key, it tells byond that it's typing.
   */
  handleKeyDown = (event, value) => {
    const { channel } = this.state;
    if (!event.keyCode) {
      return; // Really doubt it, but...
    }
    // This gives only some degree of deniability to emotes and ooc.
    // I don't want to add server side channel switching support to
    // turn off chat bubbles because that is entire gameable:
    // type whole message in ooc -> switch channels -> enter
    if (isAlphanumeric(event.keyCode) && channel < 2) {
      this.typingCooldown?.sendMessage();
    }
    if (event.keyCode === KEY_UP || event.keyCode === KEY_DOWN) {
      if (getHistoryLength()) {
        this.handleArrowKeys(event.keyCode);
      }
    }
    if (event.keyCode === KEY_DELETE || event.keyCode === KEY_BACKSPACE) {
      this.handleBkspDelete(value);
    }
    if (event.keyCode === KEY_TAB) {
      this.incrementChannel();
      event.preventDefault();
    }
  };

  /**
   * Increments the channel or resets to the beginning of the list.
   */
  incrementChannel = () => {
    const { channel } = this.state;
    if (channel === CHANNELS.length - 1) {
      this.setState({
        buttonContent: CHANNELS[0],
        channel: 0,
      });
    } else {
      this.setState({
        buttonContent: CHANNELS[channel + 1],
        channel: channel + 1,
      });
    }
  };
  /**
   * Resets window to default parameters.
   *
   * Parameters:
   * channel - Optional. Sets the channel and thus the color scheme.
   */
  reset = (channel) => {
    const chan = typeof channel === 'number';
    this.historyCounter = 0;
    this.value = '';
    this.setState({
      buttonContent: chan ? CHANNELS[channel] : null,
      channel: chan ? channel : -1,
      edited: true,
      size: SIZE.small,
    });
  };
  setInnerRef = (ref) => {
    this.innerRef = ref;
  };
  /**  Adjusts window sized based on event.target.value */
  setSize = (value) => {
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
    const { historyCounter } = this;
    if (historyCounter > 0 && getHistoryLength()) {
      this.value = getHistoryAt(historyCounter);
      Byond.sendMessage('typing');
      this.setState({ buttonContent: historyCounter, edited: true });
    } else {
      this.value = '';
      this.setState({
        buttonContent: CHANNELS[channel],
        edited: true,
      });
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
      this.reset(data.channel && CHANNELS.indexOf(data.channel));
      setTimeout(() => {
        this.innerRef?.current?.focus();
      }, 1);
      windowOpen();
    });
    windowLoad();
    this.typingCooldown = new CooldownWrapper('typing', 6000);
  }
  /** After updating the input value, sets back to false */
  componentDidUpdate() {
    if (this.state.edited) {
      this.unsetEdited();
    }
  }

  render() {
    const {
      handleBlur,
      handleClick,
      handleEnter,
      handleEscape,
      handleFocus,
      handleInput,
      handleKeyDown,
      maxLength,
      setInnerRef,
      value,
    } = this;
    const { buttonContent, channel, edited, size } = this.state;
    return (
      <div className={getCss('window', channel, size)}>
        {size < SIZE.medium && (
          <button
            className={getCss('button', channel)}
            onclick={handleClick}
            onmouseenter={handleFocus}
            onmouseleave={handleBlur}
            type="submit">
            {buttonContent}
          </button>
        )}
        <TextArea
          className={getCss('input', channel, size)}
          dontUseTabForIndent
          maxLength={maxLength}
          onEnter={handleEnter}
          onEscape={handleEscape}
          onInput={handleInput}
          onKeyDown={handleKeyDown}
          selfClear
          setInnerRef={setInnerRef}
          value={edited && value}
        />
      </div>
    );
  }
}
