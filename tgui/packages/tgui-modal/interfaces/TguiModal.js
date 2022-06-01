import { Component } from 'inferno';
import { classes } from 'common/react';
import { KEY_TAB } from 'common/keycodes';
import { TextArea } from 'tgui/components';

const CHANNELS = ['say', 'radio', 'me', 'ooc'];

/** Window sizes in pixels */
const SIZE = {
  small: 58,
  medium: 85,
  large: 110,
};

/** Returns modular css classes */
const getCss = (element, channel, size) =>
  classes([element, `${element}-${CHANNELS[channel]}`, `${element}-${size}`]);

/** Primary class for the TGUI modal. */
export class TguiModal extends Component {
  constructor() {
    super();
    this.maxLength = 1024;
    this.state = {
      buttonContent: '>',
      channel: 0,
      hovering: false,
      size: SIZE.small,
    };
  }
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
  handleEnter = (_, value) => {
    const { channel } = this.state;
    const { maxLength } = this;
    this.resetWindow();
    if (!value || value.length > maxLength) {
      Byond.sendMessage('close');
    } else {
      Byond.sendMessage('entry', {
        channel: CHANNELS[channel],
        entry: value,
      });
    }
  };
  /** User presses escape, closes the window */
  handleEscape = () => {
    this.resetWindow();
    Byond.sendMessage('close');
  };
  /** Mouse over button. Changes button to channel name. */
  handleFocus = () => {
    const { channel } = this.state;
    this.setState({
      buttonContent: CHANNELS[channel].slice(0, 1).toUpperCase(),
      hovering: true,
    });
  };
  /** Purge the current input value */
  handleForce = () => {
    this.setSize(65);
    // Byond.sendMessage('force', { entry: textAreaRef.current.value });
  };
  /** Grabs the TAB key to change channels. */
  handleKeyDown = (event, value) => {
    if (event.keyCode === KEY_TAB) {
      this.incrementChannel();
      event.preventDefault();
    }
    this.setSize(value.length);
  };
  /**
   * Increments the channel or resets to the beginning of the list.
   * If a user is hovering over the button, the channel is changed.
   */
  incrementChannel = () => {
    const { channel, hovering } = this.state;
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
  /** Resets the channel and window size */
  resetWindow = () => {
    this.setState({ channel: 0 });
    this.setSize(0);
  };
  /**  Adjusts window sized based on target value */
  setSize = (value) => {
    Byond.winset(Byond.windowId, { size: '333x200' });
    if (value > 56) {
      this.setState({ size: SIZE.large });
    } else if (value > 22) {
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
  componentDidMount() {
    Byond.subscribeTo('modal_data', (data) => {
      this.setState({ channel: CHANNELS.indexOf(data.channel) });
      this.maxLength = data.maxLength;
      Byond.sendMessage('messaged', { test: 'Ok' });
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
    const { buttonContent, channel, size } = this.state;
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
        />
      </div>
    );
  }
}
