import { globalEvents } from 'tgui-core/events';
import { acquireHotKey } from 'tgui-core/hotkeys';
import { KEY_BACKSPACE, KEY_F11, KEY_F12 } from 'tgui-core/keycodes';
import { kitchenSinkAtom, store } from '../events/store';

export function setDebugHotKeys(): void {
  acquireHotKey(KEY_F11);
  acquireHotKey(KEY_F12); // Just to avoid the HUD disappearing on F12

  globalEvents.on('keydown', (evt) => {
    if (evt.code === KEY_F11) {
      store.set(kitchenSinkAtom, (prev) => !prev);
    }

    if (evt.ctrl && evt.alt && evt.code === KEY_BACKSPACE) {
      // NOTE: We need to call this in a timeout, because we need a clean
      // stack in order for this to be a fatal error.
      setTimeout(() => {
        throw new Error(
          'OOPSIE WOOPSIE!! UwU We made a fucky wucky!! A wittle' +
            ' fucko boingo! The code monkeys at our headquarters are' +
            ' working VEWY HAWD to fix this!',
        );
      });
    }
  });
}
