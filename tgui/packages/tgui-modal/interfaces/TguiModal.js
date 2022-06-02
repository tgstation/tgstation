import { Component } from 'inferno';
import { classes } from 'common/react';
import { KEY_DOWN, KEY_TAB, KEY_UP } from 'common/keycodes';
import { TextArea } from 'tgui/components';

const CHANNELS = ['say', 'radio', 'me', 'ooc'];

/** Window sizes in pixels */
const SIZE = {
  small: 58,
  medium: 85,
  large: 110,
};

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
      channel: 0,
      size: SIZE.small,
    };
  }
  /** Resets the state of the window and hides it from user view */
  closeWindow = () => {
    this.setState({ channel: 0 });
    this.value = '';
    this.setSize(0);
    Byond.winset('tgui_modal', { 'is-visible': false });
    Byond.sendMessage('close');
  };
  /** Mouse leaves the button */
  handleBlur = () => {
    this.hovering = false;
    this.setState({ buttonContent: `>` });
  };
  /** User clicks the channel button. */
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
    this.closeWindow();
  };
  /** User presses escape, closes the window */
  handleEscape = () => {
    this.closeWindow();
  };
  /** Mouse over button. Changes button to channel name. */
  handleFocus = () => {
    const { channel } = this.state;
    this.hovering = true;
    this.setState({
      buttonContent: CHANNELS[channel].slice(0, 1).toUpperCase(),
    });
  };
  /** Send the current input to byond and purge it */
  handleForce = () => {
    const { channel } = this.state;
    const { value } = this;
    if (value) {
      Byond.sendMessage('purge', {
        channel: CHANNELS[channel],
        entry: value,
      });
      this.value = '';
    }
  };
  /** Grabs input and sets size, force values etc.
   * Input value is not set to trigger rerenders, just forced output.
   */
  handleInput = (_, value) => {
    this.value = value;
    this.setSize(value.length);
  };
  /** Grabs the TAB key to change channels. */
  handleKeyDown = (event) => {
    if (event.keyCode === KEY_TAB) {
      this.incrementChannel();
      event.preventDefault();
    }
    if (event.keyCode === KEY_UP || event.keyCode === KEY_DOWN) {
      if (savedMessages.length) {
        this.incrementCounter(event.keyCode);
        this.viewHistory();
      }
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
  /** Increments the chat history counter, looping through entries */
  incrementCounter = (direction) => {
    const { historyCounter } = this;
    if (direction === KEY_UP) {
      if (historyCounter < savedMessages.length) {
        this.historyCounter++;
      }
    } else if (direction === KEY_DOWN) {
      if (historyCounter > 0) {
        this.historyCounter--;
      }
    }
  };
  /**  Adjusts window sized based on target value */
  setSize = (value) => {
    if (value > 56) {
      this.setState({ size: SIZE.large });
    } else if (value > 24) {
      this.setState({ size: SIZE.medium });
    } else {
      this.setState({ size: SIZE.small });
    }
    this.setWindow();
  };
  /**
   * Modifies the window size.
   * This would be included in setSize but state is async
   */
  setWindow = () => {
    const { size } = this.state;
    Byond.winset(Byond.windowId, { size: `333x${size}` });
    Byond.winset('tgui_modal_browser', { size: `333x${size}` });
  };
  /** Sets the value to be displayed from chat history. */
  viewHistory = () => {
    const { historyCounter } = this.historyCounter;
    Byond.sendMessage('hist', { history: this.historyCounter.toString() });
    this.value = savedMessages[historyCounter - 1];
    Byond.sendMessage('saved', {
      saved: savedMessages[this.historyCounter - 1],
    });
  };
  componentDidMount() {
    Byond.subscribeTo('modal_props', (data) => {
      this.setState({ channel: CHANNELS.indexOf(data.channel) });
      this.maxLength = data.maxLength;
    });
    Byond.subscribeTo('modal_force', () => {
      this.handleForce();
    });
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
    } = this;
    const { buttonContent, channel, size, value } = this.state;
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
          value={value}
        />
      </div>
    );
  }
}

/** Returns modular css classes */
const getCss = (element, channel, size) =>
  classes([element, `${element}-${CHANNELS[channel]}`, `${element}-${size}`]);

/**
 * Stores entries in the chat history.
 * Deletes old entries if the list is too long.
 */
const storeChat = (message) => {
  if (savedMessages.length === 4) {
    savedMessages.shift();
  }
  savedMessages.push(message);
};
