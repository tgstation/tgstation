import { chatRenderer } from '../../chat/renderer';
import { roundRestartedAtAtom } from '../../game/atoms';
import { store } from '../store';

export function roundrestart() {
  chatRenderer.saveToDisk();
  store.set(roundRestartedAtAtom, Date.now());
}
