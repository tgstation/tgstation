import { ChannelIterator } from './classes/ChannelIterator';
import { ChatHistory } from './classes/ChatHistory';
import { Component, createRef, RefObject } from 'inferno';
import { getCss } from './helpers';
import { Handlers, mapEventHandlers } from './handlers';
import { RADIO_PREFIXES, WINDOW_SIZES } from './constants';
import { TextArea } from 'tgui/components';
import { timers } from './timers';
import { dragStartHandler } from 'tgui/drag';

type State = {
  buttonContent: string | number;
  size: WINDOW_SIZES;
  value: string;
};

type Fields = {
  channelIterator: ChannelIterator;
  chatHistory: ChatHistory;
  innerRef: RefObject<HTMLTextAreaElement>;
  lightMode: boolean;
  maxLength: number;
  currentPrefix: keyof typeof RADIO_PREFIXES | null;
};

/** Primary class for the TGUI say modal. */
export class TguiSay extends Component<{}, State> {
  // Fields that do not cause a re-render
  fields: Fields = {
    channelIterator: new ChannelIterator(),
    chatHistory: new ChatHistory(),
    innerRef: createRef(),
    lightMode: false,
    maxLength: 1024,
    currentPrefix: null,
  };
  // All the event handlers
  handlers: Handlers = mapEventHandlers(this);
  // Fields that cause a re-render
  state: State = {
    buttonContent: '',
    size: WINDOW_SIZES.small,
    value: '',
  };
  timers = timers;

  componentDidMount() {
    this.handlers.componentMount();
  }

  render() {
    const { channelIterator, lightMode, innerRef, maxLength, currentPrefix } =
      this.fields;
    const { enter, escape, keyDown, input, incrementChannel } = this.handlers;
    const { buttonContent, size, value } = this.state;

    const theme =
      (lightMode && 'lightMode') ||
      (currentPrefix && RADIO_PREFIXES[currentPrefix]) ||
      channelIterator.current();

    return (
      <div className={getCss('window', theme, size)} $HasKeyedChildren>
        <div
          className={`dragzone-top-${theme}`}
          onmousedown={dragStartHandler}
        />
        <div className="window__center" $HasKeyedChildren>
          <div
            className={`dragzone-left-${theme}`}
            onmousedown={dragStartHandler}
          />
          <div className="content">
            <button
              className={getCss('button', theme)}
              onclick={incrementChannel}
              type="submit">
              {buttonContent}
            </button>

            <TextArea
              className={getCss('textarea', theme)}
              dontUseTabForIndent
              innerRef={innerRef}
              maxLength={maxLength}
              onEnter={enter}
              onEscape={escape}
              onInput={input}
              onKey={keyDown}
              selfClear
              value={value}
            />
          </div>
          <div
            className={`dragzone-right-${theme}`}
            onmousedown={dragStartHandler}
          />
        </div>
        <div
          className={`dragzone-bottom-${theme}`}
          onmousedown={dragStartHandler}
        />
      </div>
    );
  }
}
