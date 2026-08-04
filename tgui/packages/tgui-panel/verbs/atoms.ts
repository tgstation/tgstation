import type { VerbArgBase } from 'common/verb-constants';
import { atom } from 'jotai';

export type VerbArg = VerbArgBase & {
  name: string;
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
export const clearCommandBarAtom = atom<number>(0);
