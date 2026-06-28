import { store } from '../events/store';
import {
  type AdminTarget,
  type AdminVerb,
  adminTargetsAtom,
  adminVerbsAtom,
  focusCommandBarAtom,
  typepathsAtom,
} from './atoms';

export function handleVerbsInit(payload: { verbs: AdminVerb[] }) {
  store.set(adminVerbsAtom, payload.verbs || []);
}

export function handleAddVerbs(payload: { verbs: AdminVerb[] }) {
  const current = store.get(adminVerbsAtom);
  const newVerbs = payload.verbs || [];
  const existingNames = new Set(current.map((v) => v.name));
  const toAdd = newVerbs.filter((v) => !existingNames.has(v.name));
  if (toAdd.length > 0) {
    store.set(adminVerbsAtom, [...current, ...toAdd]);
  }
}

export function handleRemoveVerbs(payload: { names: string[] }) {
  const current = store.get(adminVerbsAtom);
  const toRemove = new Set(payload.names || []);
  store.set(adminVerbsAtom, current.filter((v) => !toRemove.has(v.name)));
}

export function handleTargets(payload: { targets: AdminTarget[] }) {
  store.set(adminTargetsAtom, payload.targets || []);
}

export function handleTypepaths(payload: { paths: string[] }) {
  store.set(typepathsAtom, payload.paths || []);
}

export function handleFocusCommandBar() {
  store.set(focusCommandBarAtom, (n) => n + 1);
}
