import { sendAct } from "../../backend";
import { Gender } from "./preferences/gender";

export type CharacterProfile = {
  name: string;
};

export type AssetWithIcon = {
  icon: string;
  value: string;
};

export const createSetPreference = (
  act: typeof sendAct,
  preference: string
) => (value: string) => {
  act("set_preference", {
    preference,
    value,
  });
};

export type PreferencesMenuData = {
  character_preview_view: string;
  character_profiles: (CharacterProfile | null)[];

  real_name: string;

  character_preferences: {
    clothing: Record<string, AssetWithIcon>;

    misc: {
      gender: Gender;
    };
  };

  generated_preference_values?: Record<string, Record<string, string>>;
};
