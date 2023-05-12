import { RefObject } from 'inferno';
import { RADIO_PREFIXES } from './constants';

export type Modal = {
  events: ModalEvents;
  fields: Fields;
  setState: (state: {}) => void;
  state: State;
  timers: Timers;
};

type ModalEvents = {
  onArrowKeys: (direction: number) => void;
  onBackspaceDelete: () => void;
  onClick: () => void;
  onEscape: () => void;
  onEnter: (event: KeyboardEvent, value: string) => void;
  onForce: () => void;
  onKeyDown: (event: KeyboardEvent, value: string) => void;
  onIncrementChannel: () => void;
  onInput: (event: InputEvent, value: string) => void;
  onComponentMount: () => void;
  onComponentUpdate: () => void;
  onRadioPrefix: () => void;
  onReset: (channel?: number) => void;
  onSetSize: (size: number) => void;
  onViewHistory: () => void;
};

type Fields = {
  historyCounter: number;
  innerRef: RefObject<HTMLInputElement>;
  lightMode: boolean;
  maxLength: number;
  currentPrefix: keyof typeof RADIO_PREFIXES | null;
  tempHistory: string;
  currentValue: string;
};

export type State = {
  buttonContent: string | number;
  channel: number;
  edited: boolean;
  size: number;
};

type Timers = {
  channelDebounce: (cb: ModeDebounce) => void;
  forceDebounce: (cb: ForceDebounce) => void;
  typingThrottle: () => void;
};

type ModeDebounce = {
  mode: boolean;
};

type ForceDebounce = {
  channel: string;
  entry: string;
};

export type DragzoneProps = {
  theme: string;
  top: boolean;
  right: boolean;
  bottom: boolean;
  left: boolean;
};
