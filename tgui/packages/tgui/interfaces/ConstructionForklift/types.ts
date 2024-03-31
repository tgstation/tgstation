type MaterialData = {
  storage_max: number;
  storage_now: number;
  storage: Record<string, number>;
};

type AvailableModules = {
  [ref: string]: string; // key is the ref, value is the name
};

type ModuleData = {
  active_ref: string;
  available: AvailableModules;
};

type CooldownData = {
  build: number;
  deconstruct: number;
  scan: number;
};

type ConstructionForkliftData = {
  materials: MaterialData;
  modules: ModuleData;
  cooldowns: CooldownData;
  holograms: number;
};

type ForkliftModuleData = {
  name: string;
  build_instantly: boolean;
  available_builds: BuildTarget[];
  resource_price: Record<string, number>;
  build_length: number;
  deconstruction_time: number;
  currently_selected_typepath: string;
  available_directions: number[];
  direction: number;
};

type BuildTarget = {
  type: string;
  name: string;
  display_icon_ref: string | undefined;
};
