import { TextArea } from 'tgui/components';
import { CHANNELS, RADIO_PREFIXES, WINDOW_SIZES } from '../constants';
import { Dragzone } from '../components/dragzone';
import { handlers } from '../handlers';
import { getCss, timers } from '../helpers';
import { Component, createRef } from 'inferno';
import { Modal, State } from '../types';

/** Primary class for the TGUI say modal. */
export class TguiSay extends Component<{}, State> {
  protected events: Modal['events'] = {
    onArrowKeys: handlers.handleArrowKeys.bind(this),
    onBackspaceDelete: handlers.handleBackspaceDelete.bind(this),
    onClick: handlers.handleClick.bind(this),
    onComponentMount: handlers.handleComponentMount.bind(this),
    onComponentUpdate: handlers.handleComponentUpdate.bind(this),
    onEnter: handlers.handleEnter.bind(this),
    onEscape: handlers.handleEscape.bind(this),
    onForce: handlers.handleForce.bind(this),
    onIncrementChannel: handlers.handleIncrementChannel.bind(this),
    onInput: handlers.handleInput.bind(this),
    onKeyDown: handlers.handleKeyDown.bind(this),
    onRadioPrefix: handlers.handleRadioPrefix.bind(this),
    onReset: handlers.handleReset.bind(this),
    onSetSize: handlers.handleSetSize.bind(this),
    onViewHistory: handlers.handleViewHistory.bind(this),
  };
  protected fields: Modal['fields'] = {
    historyCounter: 0,
    innerRef: createRef(),
    maxLength: 1024,
    radioPrefix: '',
    value: '',
  };
  public state: Modal['state'] = {
    buttonContent: '',
    channel: -1,
    edited: false,
    size: WINDOW_SIZES.SMALL,
  };
  protected timers: Modal['timers'] = timers;


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
        <Dragzone horizontal />
        <div className="window__content" $HasKeyedChildren>
          <Dragzone vertical />
          {size < WINDOW_SIZES.medium && (
            <button
              className={getCss('button', prefixOrChannel)}
              onclick={onClick}
              type="submit">
              {buttonContent}
            </button>
          )}
          <TextArea
            className={getCss('input', prefixOrChannel)}
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
          <Dragzone vertical />
        </div>
        <Dragzone horizontal />
      </div>
    );
  }
}
