import { exhaustiveCheck } from "common/exhaustive";
import { sendAct, useBackend, useLocalState } from "../../backend";
import { CharacterProfile, PreferencesMenuData, Window } from "./data";
import { CharacterPreferenceWindow } from "./CharacterPreferenceWindow";
import { GamePreferenceWindow } from "./GamePreferenceWindow";

export const PreferencesMenu = (props, context) => {
  const { data } = useBackend<PreferencesMenuData>(context);

  const window = data.window;

  switch (window) {
    case Window.Character:
      return <CharacterPreferenceWindow />;
    case Window.Game:
      return <GamePreferenceWindow />;
    default:
      exhaustiveCheck(window);
  }
};
