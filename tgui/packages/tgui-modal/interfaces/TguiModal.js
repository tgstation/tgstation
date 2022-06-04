import { Component } from 'inferno';
import {
  KEY_BACKSPACE,
  KEY_DELETE,
  KEY_DOWN,
  KEY_TAB,
  KEY_UP,
} from 'common/keycodes';
import { windowOpen, windowClose, windowSet } from '../helpers/helpers';
import { CHANNELS, SIZE } from '../constants/constants';
import { TextArea } from 'tgui/components';

/** Stores a list of chat messages entered as values */
let savedMessages = [];

/** Primary class for the TGUI modal. */
export class TguiModal extends Component {
  constructor() {
    super();
    this.historyCounter = 0;
    this.hovering = false;
    this.maxLength = 1024;
    this.value = '';
    this.state = {
      buttonContent: '>',
      channel: null,
      edited: false,
      size: SIZE.small,
    };
  }
  /** Increments the chat history counter, looping through entries */
  handleArrowKeys = (direction) => {
    const { historyCounter } = this;
    if (direction === KEY_UP && historyCounter < savedMessages.length) {
      this.historyCounter++;
      this.viewHistory();
    } else if (direction === KEY_DOWN && historyCounter > 0) {
      this.historyCounter--;
      this.viewHistory();
    }
  };
  /** Mouse leaves the button */
  handleBlur = () => {
    this.hovering = false;
    this.setState({ buttonContent: `>` });
  };
  /**
   * User clicks the channel button.
   * Simulates the tab key.
   */
  handleClick = () => {
    this.incrementChannel();
  };
  /** Ensures backspace and delete reset size and history */
  handleBkspDelete = (value) => {
    this.historyCounter = 0;
    this.setSize(value.length);
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
  /** Mouse over button. Changes button to channel name. */
  handleFocus = () => {
    const { channel } = this.state;
    this.hovering = true;
    this.setState({
      buttonContent: CHANNELS[channel].slice(0, 1).toUpperCase(),
    });
  };
  /** Sends the current input to byond and purges it */
  handleForce = () => {
    const { channel } = this.state;
    const { value } = this;
    if (value) {
      Byond.sendMessage('purge', {
        channel: CHANNELS[channel],
        entry: value,
      });
      this.reset(channel);
      windowSet();
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
  Grabs the TAB key to change channels. */
  handleKeyDown = (event, value) => {
    if (!event.keyCode) {
      return; // Really doubt it, but...
    }
    if (isAlphanumeric(event.keyCode)) {
      Byond.sendMessage('typing');
    }
    if (event.keyCode === KEY_TAB) {
      this.incrementChannel();
      event.preventDefault();
    }
    if (event.keyCode === KEY_UP || event.keyCode === KEY_DOWN) {
      if (savedMessages.length) {
        this.handleArrowKeys(event.keyCode);
      }
    }
    if (event.keyCode === KEY_DELETE || event.keyCode === KEY_BACKSPACE) {
      this.handleBkspDelete(value);
    }
  };
  /**
   * Increments the channel or resets to the beginning of the list.
   * If a user is hovering over the button, the channel is changed.
   */
  incrementChannel = () => {
    const { channel } = this.state;
    const { hovering } = this;
    if (channel === CHANNELS.length - 1) {
      this.setState({
        buttonContent: !hovering ? '>' : CHANNELS[0].slice(0, 1).toUpperCase(),
        channel: 0,
      });
    } else {
      this.setState({
        buttonContent: !hovering
          ? '>'
          : CHANNELS[channel + 1].slice(0, 1).toUpperCase(),
        channel: channel + 1,
      });
    }
  };
  /**
   * Resets window to default parameters.
   *
   * Parameters:
   * channel - Sets the channel (optional)
   */
  reset = (channel) => {
    this.historyCounter = 0;
    this.value = '';
    this.setState({
      buttonContent: '>',
      channel,
      edited: true,
      size: SIZE.small,
    });
  };

  /**  Adjusts window sized based on target value */
  setSize = (value) => {
    const { size } = this.state;
    if (value > 56 && size !== SIZE.large) {
      this.setState({ size: SIZE.large });
      windowSet(SIZE.large);
    } else if (value <= 56 && value > 24 && size !== SIZE.medium) {
      this.setState({ size: SIZE.medium });
      windowSet(SIZE.medium);
    } else if (value <= 24 && size !== SIZE.small) {
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
    if (historyCounter > 0 && savedMessages.length) {
      this.value = savedMessages[savedMessages.length - historyCounter];
      this.setState({ buttonContent: historyCounter, edited: true });
    } else {
      this.value = '';
      this.setState({ buttonContent: '>', edited: true });
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
      windowOpen();
      this.reset(data.channel);
    });
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
          autoFocus
          className={getCss('input', channel, size)}
          dontUseTabForIndent
          maxLength={maxLength}
          onEnter={handleEnter}
          onEscape={handleEscape}
          onInput={handleInput}
          onKeyDown={handleKeyDown}
          selfClear
          value={edited && value}
        />
      </div>
    );
  }
}

/**
 * Stores entries in the chat history.
 * Deletes old entries if the list is too long.
 */
const storeChat = (message) => {
  if (savedMessages.length === 5) {
    savedMessages.shift();
  }
  savedMessages.push(message);
};
