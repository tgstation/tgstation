import { Component, createRef } from 'inferno';
import { Input } from 'tgui/components';

const CHANNELS = ['say', 'radio', 'me', 'ooc'];

export class TguiModal extends Component {
  constructor(props) {
    super(props);
    this.inputRef = createRef();
    this.state = {
      channel: 0,
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
      if (!value || value.length > 1024) {
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
    return (
      <div className={'tguimodal-window'}>
        <button
          className={'tguimodal-button'}
          onclick={this.onClick}
          ref={this.inputRef}
          type="submit">
          {this.state.channel}
        </button>
        <Input
          autoFocus
          className="tguimodal-input"
          maxLength={1024}
          onEscape={() => Byond.sendMessage('close')}
          onEnter={(_, value) => this.onEnter(value)}
          width="100%"
        />
      </div>
    );
  }
}
