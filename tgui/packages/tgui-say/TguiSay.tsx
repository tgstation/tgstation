import { TextArea } from 'tgui/components';
import { RADIO_PREFIXES, WINDOW_SIZES } from './constants';
import { Dragzone } from './dragzone';
import { eventHandlerMap } from './handlers';
import { getCss } from './helpers';
import { Component, createRef } from 'inferno';
import { Modal, State } from './types';
import { ChannelIterator } from './handlers/incrementChannel';
import { ChatHistory } from './handlers/arrowKeys';
import { timers } from './timers';

/** Primary class for the TGUI say modal. */
export class TguiSay extends Component<{}, State> {
  // Fields that do not cause a re-render
  fields: Modal['fields'] = {
    channelIterator: new ChannelIterator(),
    chatHistory: new ChatHistory(),
    innerRef: createRef(),
    lightMode: false,
    maxLength: 1024,
    currentPrefix: null,
    currentValue: '',
  };
  // All the event handlers
  handlers: Modal['handlers'] = eventHandlerMap(this);
  // Fields that cause a re-render
  state: Modal['state'] = {
    buttonContent: '',
    edited: false,
    size: WINDOW_SIZES.small,
  };
  timers: Modal['timers'] = timers;

  componentDidMount() {
    this.handlers.componentMount();
  }

  componentDidUpdate() {
    if (this.state.edited) {
      this.handlers.componentUpdate();
    }
  }

  render() {
    const {
      click: onClick,
      enter: onEnter,
      escape: onEscape,
      keyDown: onKeyDown,
      input: onInput,
    } = this.handlers;
    const { innerRef, lightMode, maxLength, currentPrefix, currentValue } =
      this.fields;
    const { buttonContent, edited, size } = this.state;
    const theme =
      (lightMode && 'lightMode') ||
      (currentPrefix && RADIO_PREFIXES[currentPrefix]?.id) ||
      this.fields.channelIterator.current().toLowerCase();

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
            value={edited && currentValue}
          />
          <Dragzone theme={theme} right />
        </div>
        <Dragzone theme={theme} bottom />
      </div>
    );
  }
}
