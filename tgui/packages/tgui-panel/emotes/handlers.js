import { store } from '../events/store';
import { emotesAtom } from './atom';

export function setEmotesList(payload) {
  store.set(emotesAtom, (state) => ({
    ...state,
    list: payload,
  }));
}

export function toggleEmotes() {
  store.set(emotesAtom, (state) => ({
    ...state,
    visible: !state.visible,
  }));
}
