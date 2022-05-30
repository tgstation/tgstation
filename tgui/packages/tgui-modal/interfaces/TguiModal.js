import { Component } from 'inferno';
import { Input } from 'tgui/components';
import { classes } from 'common/react';
import { KEY_TAB } from '../../common/keycodes';

const CHANNELS = ['say', 'radio', 'me', 'ooc'];

/** Returns a modular classname */
const getCss = (element, channel) =>
  classes([element, `${element}-${CHANNELS[channel]}`]);

/**
 * Primary class for the TGUI modal.
 *
 * Props:
 *  - channel: The channel (thereby, color) to display the modal for.
 *  - max_length: The maximum length of the message.
 */
export class TguiModal extends Component {
  constructor(props) {
    super(props);
    this.max_length = props.max_length || 1024;
    this.hovering = false;
    this.state = {
      buttonContent: '>',
      channel:
        CHANNELS.indexOf(props.channel) < 0
          ? 0
          : CHANNELS.indexOf(props.channel),
      input: '',
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
    const { max_length } = this.max_length;
    this.setInput('');
    if (!value || value.length > max_length) {
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
    this.setInput('');
    Byond.sendMessage('close');
  };
  /** Mouse over button. Changes button to channel name. */
  handleFocus = () => {
    const { channel } = this.state;
    this.hovering = true;
    this.setState({
      buttonContent: CHANNELS[channel].slice(0, 1).toUpperCase(),
    });
  };
  /** Grabs the TAB key to change channels. */
  handleKeyDown = (event) => {
    if (event.keyCode === KEY_TAB) {
      this.incrementChannel();
      event.preventDefault();
    }
  };
  /** Increments the channel or resets to the beginning of the list. */
  incrementChannel() {
    const { channel } = this.state;
    if (channel === CHANNELS.length - 1) {
      this.setChannel(0);
    } else {
      this.setChannel(channel + 1);
    }
  }
  /** Sets the current channel. */
  setChannel(channel) {
    const { hovering } = this.hovering;
    this.setState({ channel });
    if (hovering) {
      this.setState({
        buttonContent: CHANNELS[channel].slice(0, 1).toUpperCase(),
      });
    }
  }
  /** Sets the current input value. */
  setInput = (input) => {
    if (!input) {
      input = '';
    }
    this.setState({ input });
  };
  componentShouldUpdate(_, nextState) {
    return nextState.channel !== this.state.channel;
  }

  render() {
    const props = this;
    const {
      handleBlur,
      handleClick,
      handleEnter,
      handleEscape,
      handleFocus,
      handleKeyDown,
      max_length,
    } = props;
    const { buttonContent, channel, input } = this.state;
    return (
      <div className={getCss('window', channel)}>
        <button
          className={getCss('button', channel)}
          onclick={handleClick}
          onmouseenter={handleFocus}
          onmouseleave={handleBlur}
          type="submit">
          {buttonContent}
        </button>
        <Input
          autoFocus
          className={getCss('input', channel)}
          fluid
          maxLength={max_length}
          onEscape={handleEscape}
          onEnter={handleEnter}
          onKeyDown={handleKeyDown}
          selfClear
        />
      </div>
    );
  }
}
