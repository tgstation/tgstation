import { Window } from "../../layouts";
import { KeybindingsPage } from "./KeybindingsPage";
import { GamePreferencesPage } from "./GamePreferencesPage";

export const GamePreferenceWindow = () => {
  return (
    <Window
      title="Game Preferences"
      width={920}
      height={770}
      scrollable
    >
      {/* <GamePreferencesPage /> */}
      <KeybindingsPage />
    </Window>
  );
};
