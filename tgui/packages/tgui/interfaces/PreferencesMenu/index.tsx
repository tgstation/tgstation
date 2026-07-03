import { Suspense, useEffect, useState } from 'react';
import { Button } from 'tgui-core/components';
import { exhaustiveCheck } from 'tgui-core/exhaustive';
import { fetchRetry } from 'tgui-core/http';

import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { logger } from '../../logging';
import { LoadingScreen } from '../common/LoadingScreen';
import { CharacterPreferenceWindow } from './CharacterPreferences';
import { GamePreferenceWindow } from './GamePreferences';
import {
  GamePreferencesSelectedPage,
  type PreferencesMenuData,
  PrefsWindow,
  type ServerData,
} from './types';
import { RandomToggleState } from './useRandomToggleState';
import { ServerPrefs } from './useServerPrefs';

export function PreferencesMenu() {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { window } = data;

  const [title, setTitle] = useState('Настройки');
  const isCharacterWindow = window === PrefsWindow.Character;

  return (
    <Window
      width={900}
      height={741}
      title={title}
      theme="ss220"
      buttons={
        <Button
          icon={isCharacterWindow ? 'cog' : 'user'}
          onClick={() => act('change_preferences_window')}
        />
      }
    >
      <Window.Content className="PreferencesMenu">
        <Suspense fallback={<LoadingScreen />}>
          <PrefsWindowInner setTitle={setTitle} />
        </Suspense>
      </Window.Content>
    </Window>
  );
}

/** We're abstracting this by one level to use Suspense */
function PrefsWindowInner(props) {
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

  let content;
  let title;
  switch (window) {
    case PrefsWindow.Character:
      title = 'Настройки персонажа';
      content = <CharacterPreferenceWindow />;
      break;
    case PrefsWindow.Game:
      title = 'Настройки игры';
      content = <GamePreferenceWindow />;
      break;
    case PrefsWindow.Keybindings:
      content = (
        <GamePreferenceWindow
          startingPage={GamePreferencesSelectedPage.Keybindings}
        />
      );
      break;
    default:
      exhaustiveCheck(window);
  }

  useEffect(() => {
    props.setTitle(title);
  }, [window]);

  return (
    <ServerPrefs.Provider value={serverData}>
      <RandomToggleState.Provider value={randomization}>
        {content}
      </RandomToggleState.Provider>
    </ServerPrefs.Provider>
  );
}
