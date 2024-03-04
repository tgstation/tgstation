import { exhaustiveCheck } from 'common/exhaustive';

import { useBackend } from '../../backend';
import { CharacterPreferenceWindow } from './CharacterPreferenceWindow';
import {
  GamePreferencesSelectedPage,
  PreferencesMenuData,
  Window,
} from './data';
import { GamePreferenceWindow } from './GamePreferenceWindow';

export const PreferencesMenu = (props) => {
  const { data } = useBackend<PreferencesMenuData>();

  const window = data.window;

  switch (window) {
    case Window.Character:
      return <CharacterPreferenceWindow />;
    case Window.Game:
      return <GamePreferenceWindow />;
    case Window.Keybindings:
      return (
        <GamePreferenceWindow
          startingPage={GamePreferencesSelectedPage.Keybindings}
        />
      );
    default:
      exhaustiveCheck(window);
  }
};
