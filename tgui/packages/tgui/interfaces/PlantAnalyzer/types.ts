import type { BooleanLike } from 'tgui-core/react';

export enum PlantAnalyzerTabs {
  STATS = 1,
  CHEM = 2,
}

export type PlantAnalyzerData = {
  graft_data: GraftData | null;
  seed_data: SeedData | null;
  plant_data: PlantData | null;
  tray_data: TrayData | null;
  // Static
  cycle_seconds: number;
  trait_db: TraitData[];
  active_tab: PlantAnalyzerTabs;
};

type TrayData = {
  being_pollinated: BooleanLike;
  icon: string;
  icon_state: string;
  is_dead: BooleanLike;
  light_level: number;
  name: string;
  nutri: number;
  nutri_max: number;
  pests: number;
  pests_max: number;
  plant_age: number;
  plant_health: number;
  reagents: ReagentVolume[];
  self_sustaining: BooleanLike;
  toxins: number;
  toxins_max: number;
  water: number;
  water_max: number;
  weeds: number;
  weeds_max: number;
  yield_mod: number;
};

export type SeedData = {
  core_traits: string[];
  distill_reagent: string;
  endurance: number;
  graft_gene: string;
  grind_results: string[];
  icon_state: string;
  icon: string;
  instability: number;
  juice_name: string;
  lifespan: number;
  maturation: number;
  mutatelist: string[];
  name: string;
  potency: number;
  product_icon_state: string;
  product_icon: string;
  product: string;
  production: number;
  reagents: ReagentData[];
  removable_traits: string[];
  volume_mod: number;
  volume_units: number;
  weed_chance: number;
  weed_rate: number;
  yield: number;
  unique_labels: UniqueSeedLabel[];
  unique_collapsibles: UniqueSeedCollapsible[];
};

type UniqueSeedLabel = {
  label: string;
  data: string;
};

type UniqueSeedCollapsible = {
  label: string;
  // key is shown text, value is tooltip text
  data: Record<string, string>;
};

export type PlantData = {
  reagents: ReagentVolume[];
};

type GraftData = {
  endurance: number;
  graft_gene: string;
  icon_state: string;
  icon: string;
  lifespan: number;
  name: string;
  production: number;
  weed_chance: number;
  weed_rate: number;
  yield: number;
};

type ReagentVolume = {
  name: string;
  volume: number;
  color: string;
};

export type ReagentData = {
  name: string;
  rate: number;
};

type TraitData = {
  description: string;
  icon: string;
  name: string;
  path: string;
};
