// OCULIS STATION IMPORT
import type { BooleanLike } from 'tgui-core/react';

import type { sendAct } from '../../events/act';
import type {
  LoadoutCategory,
  LoadoutList,
  typePath,
} from './CharacterPreferences/loadout/base';
import type { Gender } from './preferences/gender';

export enum Food {
  Alcohol = 'ALCOHOL',
  Breakfast = 'BREAKFAST',
  Bugs = 'BUGS',
  Bloody = 'BLOODY', // NOVA EDIT ADDITION - Hemophage Food
  Cloth = 'CLOTH',
  Dairy = 'DAIRY',
  Fried = 'FRIED',
  Fruit = 'FRUIT',
  Gore = 'GORE',
  Grain = 'GRAIN',
  Gross = 'GROSS',
  Junkfood = 'JUNKFOOD',
  Meat = 'MEAT',
  Nuts = 'NUTS',
  Oranges = 'ORANGES',
  Pineapple = 'PINEAPPLE',
  Raw = 'RAW',
  Seafood = 'SEAFOOD',
  Stone = 'STONE',
  Sugar = 'SUGAR',
  Toxic = 'TOXIC',
  Vegetables = 'VEGETABLES',
  Egg = 'EGG',
}

export enum JobPriority {
  Low = 1,
  Medium = 2,
  High = 3,
}

export type Name = {
  can_randomize: BooleanLike;
  explanation: string;
  group: string;
  prefixes?: string[]; // NOVA EDIT ADDITION - Drone Prefixes
};

export type Species = {
  name: string;
  desc: string;
  lore: string[];
  icon: string;

  use_skintones: BooleanLike;
  sexes: BooleanLike;

  enabled_features: string[];

  perks: {
    positive: Perk[];
    negative: Perk[];
    neutral: Perk[];
  };

  diet?: {
    liked_food: Food[];
    disliked_food: Food[];
    toxic_food: Food[];
  };
};

export type Perk = {
  ui_icon: string;
  name: string;
  description: string;
};

export type Department = {
  head?: string;
};

export type Job = {
  description: string;
  department: string;
  // NOVA EDIT
  alt_titles?: string[];
  // NOVA EDIT END
};

export type Quirk = {
  description: string;
  icon: string;
  name: string;
  value: number;
  customizable: boolean;
  customization_options?: string[];
};

// NOVA EDIT ADDITION START
export type Language = {
  description: string;
  name: string;
  icon: string;
  speaking: boolean;
};

export type Marking = {
  name: string;
  color: string;
  marking_id: string;
  emissive: boolean;
};

// Augment data types (from get_constant_data)

/** One selectable augment option which models /datum/augment_item */
export type AugmentItem = {
  path: string | null;
  name: string;
  cost: number;
  extra_info: string;
  has_digi: BooleanLike;
  allows_styles: BooleanLike;
  allows_implants: BooleanLike;
  species_blacklist: Record<string, number> | null;
  species_whitelist: Record<string, number> | null;
  ckey_whitelist: string[] | null;
};

/** One marking option with optional species restriction */
export type MarkingChoice = {
  name: string;
  recommended_species: string | null;
};

/** One preset with optional species restriction */
export type MarkingPreset = {
  name: string;
  recommended_species: string | null;
};

/** Models /datum/robotic_style */
export type RoboticStyle = {
  name: string;
  supported_slots: number; // Bitflag
  has_digi: BooleanLike;
};

export type AugmentSlot = {
  slot: string;
  body_zone?: string;
  slot_flag?: number;
  is_bodypart: boolean;
  icon?: string;
  aug_options: AugmentItem[];
  has_implant?: boolean;
  implant_options?: AugmentItem[] | null;
};

// NOVA EDIT ADDITION END
export type QuirkInfo = {
  max_positive_quirks: number;
  quirk_info: Record<string, Quirk>;
  quirk_blacklist: string[][];
  points_enabled: boolean;
};

export type Personality = {
  name: string;
  description: string;
  pos_gameplay_description: string | null;
  neg_gameplay_description: string | null;
  neut_gameplay_description: string | null;
  path: typePath;
  groups: string[] | null;
};

export enum RandomSetting {
  AntagOnly = 1,
  Disabled = 2,
  Enabled = 3,
}

export enum JoblessRole {
  BeOverflow = 1,
  BeRandomJob = 2,
  ReturnToLobby = 3,
}

export enum GamePreferencesSelectedPage {
  Settings,
  Keybindings,
}

export const createSetPreference =
  (act: typeof sendAct, preference: string) => (value: unknown) => {
    act('set_preference', {
      preference,
      value,
    });
  };

export enum PrefsWindow {
  Character = 0,
  Game = 1,
  Keybindings = 2,
}

export type CharacterPreferencesData = {

  clothing: Record<string, string>;
  features: Record<string, string>;
  game_preferences: Record<string, unknown>;
  non_contextual: {
    random_body: RandomSetting;
    [otherKey: string]: unknown;
  };
  secondary_features: Record<string, unknown>;
  supplemental_features: Record<string, unknown>;
  manually_rendered_features: Record<string, string>;

  names: Record<string, string>;
  vocals: Record<string, string>; // NOVA EDIT ADDITION

  misc: {
    gender: Gender;
    joblessrole: JoblessRole;
    species: string;
    loadout_lists: LoadoutList; // NOVA EDIT CHANGE - Multiple loadout presets
    job_clothes: BooleanLike;
    loadout_index: string; // NOVA EDIT ADDITION: Multiple loadout presets
    background_state: string; // NOVA EDIT ADDITION: Swappable character editor backgrounds
  };

  randomization: Record<string, RandomSetting>;
};

export type PreferencesMenuData = {
  character_preview_view: string;
  character_profiles: (string | null)[];

  character_preferences: CharacterPreferencesData;

  content_unlocked: BooleanLike;

  job_bans?: string[];
  job_days_left?: Record<string, number>;
  job_required_experience?: Record<
    string,
    {
      experience_type: string;
      required_playtime: number;
    }
  >;
  job_preferences: Record<string, JobPriority>;

  // NOVA EDIT ADDITION START
  preview_options: string[];
  preview_selection: string;

  erp_pref: BooleanLike;

  job_alt_titles: Record<string, string>;

  markings: Record<string, Marking[]>;
  augments: Record<string, string>;
  augment_styles: Record<string, string>;

  allow_mismatched_parts: BooleanLike;
  digi_legs: BooleanLike;
  taur_legs: BooleanLike;

  selected_languages: Language[];
  unselected_languages: Language[];
  total_language_points: number;
  quirk_points_enabled: number;
  quirks_balance: number;
  positive_quirk_count: number;
  species_restricted_jobs?: string[];
  ckey: string;
  is_donator: BooleanLike;
  is_nova_star: BooleanLike;

  // NOVA EDIT ADDITION END
  keybindings: Record<string, string[]>;
  overflow_role: string;
  default_quirk_balance: number;
  selected_quirks: string[];
  selected_personalities: typePath[] | null;
  max_personalities: number;
  mood_enabled: BooleanLike;
  species_disallowed_quirks: string[];

  antag_bans?: string[];
  antag_days_left?: Record<string, number>;
  selected_antags: string[];

  active_slot: number;
  name_to_use: string;

  window: PrefsWindow;
};

export type ServerData = {
  jobs: {
    departments: Record<string, Department>;
    jobs: Record<string, Job>;
  };
  names: {
    types: Record<string, Name>;
  };
  quirks: QuirkInfo;
  personality: {
    personalities: Personality[];
    personality_incompatibilities: Record<string, string[]>;
  };
  random: {
    randomizable: string[];
  };
  loadout: {
    loadout_tabs: LoadoutCategory[];
  };
  species: Record<string, Species>;
  // NOVA EDIT ADDITION START
  background_state: { choices: string[] };
  limbs_and_markings?: {
    robotic_styles: RoboticStyle[];
    augment_items: AugmentSlot[];
    marking_choices: Record<string, MarkingChoice[]>;
    marking_presets: MarkingPreset[];
  };
  // NOVA EDIT ADDITION END
  [otherKey: string]: unknown;
};
