import { atom } from 'jotai';

export type VerbArg = {
  name: string;
  arg_type: number;
  source: string | null;
};

export type AdminVerb = {
  type: string;
  name: string;
  args: VerbArg[];
};

export type AdminTarget = {
  name: string;
  ref: string;
};

export const adminVerbsAtom = atom<AdminVerb[]>([]);
export const adminTargetsAtom = atom<AdminTarget[]>([]);
export const typepathsAtom = atom<string[]>([]);
