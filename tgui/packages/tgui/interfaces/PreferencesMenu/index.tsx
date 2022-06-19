import { exhaustiveCheck } from 'common/exhaustive';
import { useBackend } from '../../backend';
import { GamePreferencesSelectedPage, PreferencesMenuData, Window } from './data';
import { CharacterPreferenceWindow } from './CharacterPreferenceWindow';
import { GamePreferenceWindow } from './GamePreferenceWindow';

export const PreferencesMenu = (_, context) => {
	const { data } = useBackend<PreferencesMenuData>(context);

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
