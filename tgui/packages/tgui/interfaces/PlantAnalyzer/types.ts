export type PlantAnalyzerData = {
  graft_data: GraftData;
  seed_data: SeedData;
  tray_data: TrayData;
  // Static
  cycle_seconds: number;
  trait_db: TraitData[];
};

type TrayData = {
  being_pollinated: boolean;
  icon_state: string;
  icon: string;
  light_level: number;
  name: string;
  nutri_max: number;
  nutri: number;
  pests_max: number;
  pests: number;
  plant_age: number;
  plant_health: number;
  reagents: ReagentVolume[];
  self_sustaining: boolean;
  toxins_max: number;
  toxins: number;
  water_max: number;
  water: number;
  weeds_max: number;
  weeds: number;
  yield_mod: number;
};

type SeedData = {
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
  volume: string;
};

type ReagentData = {
  name: string;
  rate: number;
};

type TraitData = {
  description: string;
  icon: string;
  name: string;
  path: string;
};
