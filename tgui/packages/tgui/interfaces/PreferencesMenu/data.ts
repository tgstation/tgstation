import { BooleanLike } from "common/react";
import { sendAct } from "../../backend";
import { Gender } from "./preferences/gender";

export type CharacterProfile = {
  name: string;
};

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
  value: string;
};

export type ServerSpeciesData = {
  name: string;

  use_skintones: BooleanLike;
  sexes: BooleanLike;

  liked_food: Food[];
  disliked_food: Food[];
  toxic_food: Food[];
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

  character_preferences: {
    clothing: Record<string, AssetWithIcon>;
    features: Record<string, AssetWithIcon>;

    names: Record<string, Name>;

    misc: {
      gender: Gender;
      species: string;
    };
  };

  job_preferences: Record<string, JobPriority>;

  generated_preference_values?: Record<string, Record<string, string>>;
  overflow_role: string;
  species: Record<string, ServerSpeciesData>;

  active_name: string;
  name_to_use: string;
};
