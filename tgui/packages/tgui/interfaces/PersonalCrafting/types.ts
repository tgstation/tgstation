import type { BooleanLike } from 'tgui-core/react';

export enum MODE {
  crafting,
  cooking,
}

export enum TABS {
  category,
  material,
  foodtype,
}

export type AtomData = {
  name: string;
  is_reagent: BooleanLike;
  icon: string;
};

type Material = {
  atom_id: string;
  occurences: number;
};

export type Recipe = {
  category: string;
  chem_catalysts: Record<number, number>;
  complexity: number;
  desc: string;
  foodtypes: string[];
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
  atom_data: AtomData[];
  categories: string[];
  complexity: number;
  diet: Diet;
  foodtypes: string[];
  icon_data: Record<number, string>;
  material_occurences: Material[];
  recipes: Recipe[];
};
