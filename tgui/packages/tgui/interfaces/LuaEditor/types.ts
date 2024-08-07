export type LuaEditorModal = 'states' | 'viewChunk' | 'call' | undefined;

export type ListElement = { key: any; value: any };
export type ListPath = { index: number; type: 'key' | 'value' | 'entry' }[];

export type VariantList = ({
  key: Variant | null;
  value?: Variant | null;
} | null)[];
type ParameterizedVariant =
  | ['list', VariantList]
  | ['cycle', [number, 'key' | 'value'][]]
  | ['ref', string];

export type Variant =
  | 'error'
  | 'function'
  | 'thread'
  | 'userdata'
  | 'error_as_value'
  | ParameterizedVariant
  | null;

type LuaGlobals = {
  values: ListElement[];
  variants: VariantList;
};

type Task = { index: number; name: string };

type LuaTasks = {
  sleeps: Task[];
  yields: Task[];
};

export type CallInfo = {
  type: 'callFunction' | 'resumeTask';
  params: Partial<{ index: number; indices: number[] }>;
};

type HasName = { name: string };
type HasReturnValues = {
  return_values: ListElement[];
  variants: VariantList;
};
type HasMessage = { message: string };
type FinishedLog = HasName & {
  status: 'finished';
} & HasReturnValues;
type SleepLog = HasName & {
  status: 'sleep';
};
type YieldLog = HasName & {
  status: 'yield';
} & HasReturnValues;
type PrintLog = {
  status: 'print';
} & HasMessage;
type ErrorLog = HasName & {
  status: 'error';
} & HasMessage;
type PanicLog = HasName & {
  status: 'panic';
} & HasMessage;
type RuntimeLog = {
  status: 'runtime';
  line: number;
  file: string;
  stack: string[];
} & HasMessage;

export type LogEntry = (
  | FinishedLog
  | SleepLog
  | YieldLog
  | PrintLog
  | ErrorLog
  | PanicLog
  | RuntimeLog
) & { chunk?: string; repeats: number };

export type LuaEditorData = {
  forceModal: LuaEditorModal;
  forceViewChunk?: string;
  forceInput?: string;
  noStateYet: boolean;
  states: string[];
  page: number;
  pageCount: number;
  lastError?: string;
  showGlobalTable: boolean;
  supressRuntimes: boolean;
  globals: LuaGlobals;
  tasks: LuaTasks;
  stateLog: LogEntry[];
  callArguments: ListElement[];
};
