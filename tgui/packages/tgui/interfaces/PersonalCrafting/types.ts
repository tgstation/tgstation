import type { BooleanLike } from 'tgui-core/react';

export enum MODE {
  crafting,
  cooking,
}

export enum TABS {
  category,
  material,
}

export type AtomData = {
  name: string;
  is_reagent: BooleanLike;
  icon: string;
};

export type Material = {
  atom_id: string;
  occurences: number;
};

export type Recipe = {
  category: string;
  chem_catalysts: Record<number, number>;
  desc: string;
  has_food_effect: BooleanLike;
  id: number;
  is_reaction: BooleanLike;
  machinery: string[];
  mass_craftable: BooleanLike;
  name: string;
  non_craftable: BooleanLike;
  ref: string;
  reqs: Record<number, number>;
  steps: string[];
  structures: string[];
  tool_behaviors: string[];
  tool_paths: string[];
  // only used for food recipes
  foodtypes?: string[];
  complexity?: number;
  cuisine_category?: string;
  dish_category?: string;
  meal_category?: string;
};

export type Diet = {
  disliked_food: string[];
  liked_food: string[];
  toxic_food: string[];
};

export type CraftingData = {
  // Dynamic
  busy: BooleanLike;
  craftability: Record<string, BooleanLike>;
  display_compact: BooleanLike;
  display_craftable_only: BooleanLike;
  forced_mode: BooleanLike;
  mode: BooleanLike;
  // Static
  complexity: number;
  diet: Diet;
  foodtypes: string[];
  material_occurences: Material[];
  json_to_use: string;
  visible_recipes: string[];
};

export type RecipeServerData = {
  categories: string[];
  recipes: Recipe[];
  icon_data: IconData;
  atom_data: AtomData[];
};

export type IconData = Record<number, string>;
