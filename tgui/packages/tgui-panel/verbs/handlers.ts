import { fetchRetry } from 'tgui-core/http';
import { resolveAsset } from '../events/handlers/assets';
import { store } from '../events/store';
import {
  adminTargetsAtom,
  adminVerbsAtom,
  clearCommandBarAtom,
  focusCommandBarAtom,
  hotkeysAtom,
  initializeCommandBarAtom,
  type Target,
  typepathsAtom,
  type Verb,
} from './atoms';

let typepathsLoaded = false;

function loadTypepaths() {
  if (typepathsLoaded) return;
  typepathsLoaded = true;
  fetchRetry(resolveAsset('spawn_menu_atom_data.json'))
    .then((response) => response.json())
    .then((data: { types: Record<string, string> }) => {
      store.set(typepathsAtom, Object.keys(data.types));
    })
    .catch(() => {
      typepathsLoaded = false;
    });
}

export function handleVerbsInit(payload: { verbs: Verb[] }) {
  store.set(adminVerbsAtom, payload.verbs || []);
  store.set(initializeCommandBarAtom, (n) => n + 1);
  loadTypepaths();
}

export function handleAddVerbs(payload: { verbs: Verb[] }) {
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
  store.set(
    adminVerbsAtom,
    current.filter((v) => !toRemove.has(v.name)),
  );
}

export function handleTargets(payload: { targets: Target[] }) {
  store.set(adminTargetsAtom, payload.targets || []);
}

export function handleFocusCommandBar() {
  store.set(focusCommandBarAtom, (n) => n + 1);
}

export function handleClearCommandBar() {
  store.set(clearCommandBarAtom, (n) => n + 1);
}

export function handleHotkeyMode(payload: { hotkeys?: number }) {
  if (payload.hotkeys != null) {
    store.set(hotkeysAtom, !!payload.hotkeys);
  }
}
