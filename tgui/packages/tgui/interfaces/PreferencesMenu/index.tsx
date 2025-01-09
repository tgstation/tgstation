import { useEffect, useState } from 'react';
import { exhaustiveCheck } from 'tgui-core/exhaustive';
import { fetchRetry } from 'tgui-core/http';

import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';
import { logger } from '../../logging';
import { CharacterPreferenceWindow } from './CharacterPreferences';
import { GamePreferenceWindow } from './GamePreferences';
import { LoadingPage } from './Loading';
import {
  GamePreferencesSelectedPage,
  PreferencesMenuData,
  ServerData,
  Window,
} from './types';
import { RandomToggleState } from './useRandomToggleState';
import { ServerPrefs } from './useServerPrefs';

export function PreferencesMenu(props) {
  const { data } = useBackend<PreferencesMenuData>();
  const { window } = data;

  const [serverData, setServerData] = useState<ServerData>();
  const randomization = useState(false);

  useEffect(() => {
    fetchRetry(resolveAsset('preferences.json'))
      .then((response) => response.json())
      .then((data) => {
        setServerData(data);
      })
      .catch((error) => {
        logger.log('Failed to fetch preferences.json', error);
      });
  }, []);

  if (!serverData) {
    return <LoadingPage />;
  }

  let content;
  switch (window) {
    case Window.Character:
      content = <CharacterPreferenceWindow />;
      break;
    case Window.Game:
      content = <GamePreferenceWindow />;
      break;
    case Window.Keybindings:
      content = (
        <GamePreferenceWindow
          startingPage={GamePreferencesSelectedPage.Keybindings}
        />
      );
      break;
    default:
      exhaustiveCheck(window);
  }
  return (
    <ServerPrefs.Provider value={serverData}>
      <RandomToggleState.Provider value={randomization}>
        {content}
      </RandomToggleState.Provider>
    </ServerPrefs.Provider>
  );
}
