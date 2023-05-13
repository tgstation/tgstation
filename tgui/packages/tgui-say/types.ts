import { RefObject } from 'inferno';
import { RADIO_PREFIXES } from './constants';
import { ChannelIterator } from './handlers/incrementChannel';
import { ChatHistory } from './handlers/arrowKeys';

export type Modal = {
  handlers: Handlers;
  fields: Fields;
  setState: (state: {}) => void;
  state: State;
  timers: Timers;
};

type Fields = {
  channelIterator: ChannelIterator;
  chatHistory: ChatHistory;
  innerRef: RefObject<HTMLInputElement>;
  lightMode: boolean;
  maxLength: number;
  currentPrefix: keyof typeof RADIO_PREFIXES | null;
  currentValue: string;
};

type Handlers = {
  arrowKeys: (direction: 'ArrowUp' | 'ArrowDown') => void;
  backspaceDelete: () => void;
  click: () => void;
  componentMount: () => void;
  componentUpdate: () => void;
  enter: (event: KeyboardEvent, value: string) => void;
  escape: () => void;
  forcesay: () => void;
  incrementChannel: () => void;
  input: (event: InputEvent, value: string) => void;
  keyDown: (event: KeyboardEvent, value: string) => void;
  radioPrefix: () => void;
  reset: () => void;
  setSize: (size: number) => void;
};

export type State = {
  buttonContent: string | number;
  edited: boolean;
  size: number;
};

type Timers = {
  channelDebounce: (cb: ModeCallback) => void;
  forceDebounce: (cb: ForceCallback) => void;
  typingThrottle: () => void;
};

// The message sent to byond
type ModeCallback = {
  visible: boolean;
};

// The message sent to byond
type ForceCallback = {
  channel: string;
  entry: string;
};
