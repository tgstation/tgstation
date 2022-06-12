import { TextArea } from 'tgui/components';
import { CHANNELS, RADIO_PREFIXES, WINDOW_SIZES } from '../constants';
import { Dragzone } from '../components/dragzone';
import {
  handleArrowKeys,
  handleBackspaceDelete,
  handleClick,
  handleComponentMount,
  handleComponentUpdate,
  handleEscape,
  handleEnter,
  handleForce,
  handleIncrementChannel,
  handleInput,
  handleKeyDown,
  handleRadioPrefix,
  handleReset,
  handleSetSize,
  handleViewHistory,
} from '../handlers';
import { getCss } from '../helpers';
import { Component, createRef, RefObject } from 'inferno';
import { debounce, throttle } from 'common/timer';
import { ModalState } from '../types';

/** Primary class for the TGUI say modal. */
export class TguiSay extends Component<{}, ModalState> {
  protected channelDebounce = debounce(
    (mode) => Byond.sendMessage('thinking', mode),
    400
  );
  protected forceDebounce = debounce(
    (entry) => Byond.sendMessage('force', entry),
    1000,
    true
  );
  protected historyCounter: number;
  protected innerRef: RefObject<HTMLInputElement> = createRef();
  protected maxLength: number;
  /** Event handlers. */
  protected onArrowKeys = handleArrowKeys.bind(this);
  protected onBackspaceDelete = handleBackspaceDelete.bind(this);
  protected onClick = handleClick.bind(this);
  protected onEnter = handleEnter.bind(this);
  protected onEscape = handleEscape.bind(this);
  protected onForce = handleForce.bind(this);
  protected onKeyDown = handleKeyDown.bind(this);
  protected onIncrementChannel = handleIncrementChannel.bind(this);
  protected onInput = handleInput.bind(this);
  protected onComponentMount = handleComponentMount.bind(this);
  protected onComponentUpdate = handleComponentUpdate.bind(this);
  protected onRadioPrefix = handleRadioPrefix.bind(this);
  protected onReset = handleReset.bind(this);
  protected onSetSize = handleSetSize.bind(this);
  protected onViewHistory = handleViewHistory.bind(this);
  protected radioPrefix: string;
  protected typingThrottle = throttle(() => Byond.sendMessage('typing'), 4000);
  protected value: string;
  state: ModalState = {
    buttonContent: '',
    channel: -1,
    edited: false,
    size: WINDOW_SIZES.small,
  };

  componentDidMount() {
    this.onComponentMount();
  }

  componentDidUpdate() {
    if (this.state.edited) {
      this.onComponentUpdate();
    }
  }

  render() {
    const {
      onClick,
      onEnter,
      onEscape,
      onInput,
      innerRef,
      maxLength,
      onKeyDown,
      radioPrefix,
      value,
    } = this;
    const { buttonContent, channel, edited, size } = this.state;
    const prefixOrChannel
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
