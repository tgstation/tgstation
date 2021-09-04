import { BooleanLike } from "common/react";
import { sendAct } from "../../backend";
import { Gender } from "./preferences/gender";

export type AssetWithIcon = {
  icon: string;
  value: string;
};

export enum Food {
  Alcohol = "ALCOHOL",
  Breakfast = "BREAKFAST",
  Cloth = "CLOTH",
  Dairy = "DAIRY",
  Fried = "FRIED",
  Fruit = "FRUIT",
  Grain = "GRAIN",
  Gross = "GROSS",
  Junkfood = "JUNKFOOD",
  Meat = "MEAT",
  Pineapple = "PINEAPPLE",
  Raw = "RAW",
  Sugar = "SUGAR",
  Toxic = "TOXIC",
  Vegetables = "VEGETABLES",
}

export enum JobPriority {
  Low = 1,
  Medium = 2,
  High = 3,
}

export type Name = {
  explanation: string;
  group: string;
};

export type ServerSpeciesData = {
  name: string;

  use_skintones: BooleanLike;
  sexes: BooleanLike;

  enabled_features: string[];

  liked_food: Food[];
  disliked_food: Food[];
  toxic_food: Food[];
};

export enum RandomSetting {
  AntagOnly = 1,
  Disabled = 2,
  Enabled = 3,
}

export const createSetPreference = (
  act: typeof sendAct,
  preference: string
) => (value: unknown) => {
  act("set_preference", {
    preference,
    value,
  });
};

export enum Window {
  Character = 0,
  Game = 1,
}

export type PreferencesMenuData = {
  character_preview_view: string;
  character_profiles: (string | null)[];

  character_preferences: {
    clothing: Record<string, AssetWithIcon>;
    features: Record<string, AssetWithIcon>;
    game_preferences: Record<string, unknown>;
    non_contextual: {
      random_body: RandomSetting,
      [otherKey: string]: unknown;
    };
    secondary_features: Record<string, unknown>;

    names: Record<string, string>;

    misc: {
      gender: Gender;
      species: string;
    };

    randomization: Record<string, RandomSetting>;
  };

  job_preferences: Record<string, JobPriority>;

  keybindings: Record<string, string[]>;
  overflow_role: string;
  selected_quirks: string[];

  antag_bans: string[];
  selected_antags: string[];

  active_name: string;
  name_to_use: string;

  window: Window;
};

export type ServerData = {
  names: {
    types: Record<string, Name>;
  };
  random: {
    randomizable: string[];
  };
  species: Record<string, ServerSpeciesData>;
  [otheyKey: string]: unknown;
};
