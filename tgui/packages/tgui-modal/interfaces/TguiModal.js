import { Component, createRef } from 'inferno';
import { Input } from 'tgui/components';
import { classes } from 'common/react';

const CHANNELS = ['say', 'radio', 'me', 'ooc'];

export class TguiModal extends Component {
  constructor(props) {
    super(props);
    this.inputRef = createRef();
    this.state = {
      channel: CHANNELS.indexOf(props.channel),
    };
    this.onClick = () => {
      const { channel } = this.state;
      if (channel === CHANNELS.length - 1) {
        this.setChannel(0);
      } else {
        this.setChannel(channel + 1);
      }
    };
    this.onEnter = (value) => {
      const { max_length } = this.props;
      if (!value || value.length > max_length) {
        Byond.sendMessage('close');
      } else {
        Byond.sendMessage('entry', value);
      }
    };
  }
  setChannel(channel) {
    this.setState({ channel });
  }
  componentShouldUpdate(_, nextState) {
    return nextState.channel !== this.state.channel;
  }

  render() {
    const { channel } = this.state;
    const { max_length } = this.props;
    const props = this;
    const { inputRef, onClick, onEnter } = props;
    return (
      <div className={classes(['window', `gradient-${CHANNELS[channel]}`])}>
        <button
          className={classes(['button', `button-${CHANNELS[channel]}`])}
          onclick={onClick}
          ref={inputRef}
          type="submit">
          {`>`}
        </button>
        <Input
          autoFocus
          className="input"
          maxLength={max_length}
          onEscape={() => Byond.sendMessage('close')}
          onEnter={(_, value) => onEnter(value)}
          width="100%"
        />
      </div>
    );
  }
}
