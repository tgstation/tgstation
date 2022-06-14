import { RefObject } from 'inferno';

export type Modal = {
  events: Events;
  fields: Fields;
  setState: (state: {}) => void;
  state: State;
  timers: Timers;
};

type Events = {
  onArrowKeys: (direction: number) => void;
  onBackspaceDelete: () => void;
  onClick: () => void;
  onEscape: () => void;
  onEnter: (event: KeyboardEvent, value: string) => void;
  onForce: () => void;
  onKeyDown: (event: KeyboardEvent) => void;
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
  maxLength: number;
  radioPrefix: string;
  value: string;
};

export type State = {
  buttonContent: string | number;
  channel: number;
  edited: boolean;
  size: number;
};

type Timers = {
  channelDebounce: ({ mode: boolean }) => void;
  forceDebounce: ({ channel: number, entry: string }) => void;
  typingThrottle: () => void;
};

export type DragzoneProps = {
  channel: string;
  top: boolean;
  right: boolean;
  bottom: boolean;
  left: boolean;
};

export type RadioPrefixes = Record<subChannel, channelData>;

type subChannel =
  | ':a '
  | ':b '
  | ':c '
  | ':e '
  | ':m '
  | ':n '
  | ':o '
  | ':s '
  | ':t '
  | ':u '
  | ':v '
  | ':y ';

type channelData = {
  id: string;
  label: string;
};

export type WindowSizes = {
  small: number;
  medium: number;
  large: number;
  width: number;
};
