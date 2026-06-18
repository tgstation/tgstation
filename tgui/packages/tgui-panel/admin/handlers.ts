import {
  type AdminTarget,
  type AdminVerb,
  adminTargetsAtom,
  adminVerbsAtom,
} from './atoms';
import { store } from '../events/store';

export function adminVerbs(payload: { verbs: AdminVerb[] }) {
  console.log('adminVerbs received:', payload?.verbs?.length, 'verbs');
  store.set(adminVerbsAtom, payload.verbs || []);
}

export function adminTargets(payload: { targets: AdminTarget[] }) {
  console.log('adminTargets received:', payload?.targets?.length, 'targets');
  store.set(adminTargetsAtom, payload.targets || []);
}
