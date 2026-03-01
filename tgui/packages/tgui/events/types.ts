import type { ExtractAtomValue } from 'jotai';
import type { sendAct } from './act';
import type { backendStateAtom } from './store';

type BinaryIO = 0 | 1;

type Client = {
  address: string;
  ckey: string;
  computer_id: string;
};

type IFace = {
  layout: string;
  name: string;
};

type TguiWindow = {
  fancy: BinaryIO;
  key: string;
  locked: BinaryIO;
  scale: BinaryIO;
  size: [number, number];
};

type User = {
  name: string;
  observer: number;
};

export type Config = {
  client: Client;
  interface: IFace;
  refreshing: BinaryIO;
  status: number;
  title: string;
  user: User;
  window: TguiWindow;
};

export type DebugState = {
  debugLayout: boolean;
  kitchenSink: boolean;
};

export type BackendState<TData> = ExtractAtomValue<typeof backendStateAtom> & {
  act: typeof sendAct;
  data: TData;
};
