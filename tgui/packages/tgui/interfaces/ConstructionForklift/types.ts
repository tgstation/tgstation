type StorageData = {
  storage_max: number;
  storage_now: number;
  storage: StorageActual;
}

type StorageActual = Record<string, number>;

type ModuleData = {
  active: string | undefined;
  available: AvailableModules;
}

type AvailableModules = Record<string, string>;

type CooldownData = {
  build: number;
  scan: number;
  deconstruct: number;
}

type ForkliftData = {
  materials: StorageData;
  modules: ModuleData;
  cooldowns: CooldownData;
  hologram_count: number;
  active_module_data: ActiveModuleData | undefined;
}

type ActiveModuleData = {
  name: string;
  build_instantly: boolean;
  resource_price: BuildPriceData;
  build_length: number;
  deconstruction_time: number;
  current_selected_typepath: string;
  available_directions: number[];
  direction: number;
  available_builds: BuildData;
}

type BuildPriceData = Record<string, Record<string, number>>;
type BuildData = Record<string, {
  name: string;
  display_src: string;
}>;
