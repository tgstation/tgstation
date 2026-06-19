import { atom } from 'jotai';

export type AdminVerb = {
  type: string;
  name: string;
  args: string[];
};

export type AdminTarget = {
  name: string;
  ref: string;
};

export const adminVerbsAtom = atom<AdminVerb[]>([]);
export const adminTargetsAtom = atom<AdminTarget[]>([]);
