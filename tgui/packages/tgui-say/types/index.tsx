import { RefObject } from 'inferno';

export type TguiModal = {
  channelDebounce: ({ mode: boolean }) => void;
  forceDebounce: ({ channel: number, entry: string }) => void;
  historyCounter: number;
  innerRef: RefObject<HTMLInputElement>;
  maxLength: number;
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
  radioPrefix: string;
  setState: (state: {}) => void;
  typingThrottle: () => void;
  value: string;
  state: ModalState;
};

export type ModalState = {
  buttonContent: string | number;
  channel: number;
  edited: boolean;
  size: number;
};
