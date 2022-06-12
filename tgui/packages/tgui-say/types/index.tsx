import { RefObject } from 'inferno';

export type TguiModal = {
  events: ModalEvents;
  fields: ModalFields;
  setState: (state: {}) => void;
  state: ModalState;
  timers: ModalTimers;
};

type ModalEvents = {
  onArrowKeys: (direction: number) => void;
  onBackspaceDelete: () => void;
  onClick: () => void;
  onEscape: () => void;
  onEnter: (event: KeyboardEvent, value: string) => void;
  onForce: () => void;
  onKeyDown: () => void;
  onIncrementChannel: () => void;
  onInput: (event: InputEvent, value: string) => void;
  onComponentMount: () => void;
  onComponentUpdate: () => void;
  onRadioPrefix: () => void;
  onReset: (channel?: number) => void;
  onSetSize: (size: number) => void;
  onViewHistory: () => void;
};

type ModalFields = {
  historyCounter: number;
  innerRef: RefObject<HTMLInputElement>;
  maxLength: number;
  radioPrefix: string;
  value: string;
};

type ModalTimers = {
  channelDebounce: ({ mode: boolean }) => void;
  forceDebounce: ({ channel: number, entry: string }) => void;
  typingThrottle: () => void;
};

export type ModalState = {
  buttonContent: string | number;
  channel: number;
  edited: boolean;
  size: number;
};
