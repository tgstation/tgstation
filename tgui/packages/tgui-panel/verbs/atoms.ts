import { atom } from 'jotai';

export type VerbArg = {
  name: string;
  arg_type: number;
  source: string | null;
  options?: string[];
};

export type Verb = {
  type: string;
  name: string;
  args: VerbArg[];
};

export type Target = {
  name: string;
  ref: string;
};

export const adminVerbsAtom = atom<Verb[]>([]);
export const adminTargetsAtom = atom<Target[]>([]);
export const typepathsAtom = atom<string[]>([]);
export const focusCommandBarAtom = atom<number>(0);
