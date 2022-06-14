import { TextArea } from 'tgui/components';
import { CHANNELS, RADIO_PREFIXES, WINDOW_SIZES } from '../constants';
import { Dragzone } from '../components/dragzone';
import { eventHandlerMap } from '../handlers';
import { getCss, timers } from '../helpers';
import { Component, createRef } from 'inferno';
import { Modal, State } from '../types';

/** Primary class for the TGUI say modal. */
export class TguiSay extends Component<{}, State> {
  events: Modal['events'] = eventHandlerMap(this);
  fields: Modal['fields'] = {
    historyCounter: 0,
    innerRef: createRef(),
    maxLength: 1024,
    radioPrefix: '',
    value: '',
  };
  state: Modal['state'] = {
    buttonContent: '',
    channel: -1,
    edited: false,
    size: WINDOW_SIZES.small,
  };
  timers: Modal['timers'] = timers;

  componentDidMount() {
    this.events.onComponentMount();
  }

  componentDidUpdate() {
    if (this.state.edited) {
      this.events.onComponentUpdate();
    }
  }

  render() {
    const { onClick, onEnter, onEscape, onKeyDown, onInput } = this.events;
    const { innerRef, maxLength, radioPrefix, value } = this.fields;
    const { buttonContent, channel, edited, size } = this.state;
    const prefixOrChannel: string
      = RADIO_PREFIXES[radioPrefix]?.id || CHANNELS[channel]?.toLowerCase();

    return (
      <div
        className={getCss('window', prefixOrChannel, size)}
        $HasKeyedChildren>
        <Dragzone channel={prefixOrChannel} top />
        <div className="window__content" $HasKeyedChildren>
          <Dragzone channel={prefixOrChannel} left />
          {!!prefixOrChannel && (
            <button
              className={getCss('button', prefixOrChannel)}
              onclick={onClick}
              type="submit">
              {buttonContent}
            </button>
          )}
          <TextArea
            className={getCss('textarea', prefixOrChannel)}
            dontUseTabForIndent
            innerRef={innerRef}
            maxLength={maxLength}
            onEnter={onEnter}
            onEscape={onEscape}
            onInput={onInput}
            onKeyDown={onKeyDown}
            selfClear
            value={edited && value}
          />
          <Dragzone channel={prefixOrChannel} right />
        </div>
        <Dragzone channel={prefixOrChannel} bottom />
      </div>
    );
  }
}
