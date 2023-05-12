import { TextArea } from 'tgui/components';
import { CHANNELS, RADIO_PREFIXES, WINDOW_SIZES } from './constants';
import { Dragzone } from './dragzone';
import { eventHandlerMap } from './handlers';
import { getCss, timers } from './helpers';
import { Component, createRef } from 'inferno';
import { Modal } from './types';

type State = {
  buttonContent: string | number;
  channel: number;
  edited: boolean;
  size: number;
};

/** Primary class for the TGUI say modal. */
export class TguiSay extends Component<{}, State> {
  events: Modal['events'] = eventHandlerMap(this);
  fields: Modal['fields'] = {
    historyCounter: 0,
    innerRef: createRef(),
    lightMode: false,
    maxLength: 1024,
    currentPrefix: null,
    tempHistory: '',
    currentValue: '',
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
    const {
      innerRef,
      lightMode,
      maxLength,
      currentPrefix,
      currentValue: value,
    } = this.fields;
    const { buttonContent, channel, edited, size } = this.state;
    const theme =
      (lightMode && 'lightMode') ||
      (currentPrefix && RADIO_PREFIXES[currentPrefix]?.id) ||
      CHANNELS[channel]?.toLowerCase();

    return (
      <div className={getCss('modal', theme, size)} $HasKeyedChildren>
        <Dragzone theme={theme} top />
        <div className="modal__content" $HasKeyedChildren>
          <Dragzone theme={theme} left />
          {!!theme && (
            <button
              className={getCss('button', theme)}
              onclick={onClick}
              type="submit">
              {buttonContent}
            </button>
          )}
          <TextArea
            className={getCss('textarea', theme)}
            dontUseTabForIndent
            innerRef={innerRef}
            maxLength={maxLength}
            onEnter={onEnter}
            onEscape={onEscape}
            onInput={onInput}
            onKey={onKeyDown}
            selfClear
            value={edited && value}
          />
          <Dragzone theme={theme} right />
        </div>
        <Dragzone theme={theme} bottom />
      </div>
    );
  }
}
