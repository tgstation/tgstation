import { Window } from "../../layouts";
import { GamePreferencesPage } from "./GamePreferencesPage";

export const GamePreferenceWindow = () => {
  return (
    <Window
      title="Character Preferences"
      width={920}
      height={770}
      scrollable
    >
      <GamePreferencesPage />
    </Window>
  );
};
