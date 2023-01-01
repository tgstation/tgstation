export type Antags = Array<Observable & { antag: string }>;

export type AntagGroup = [string, Antags];

export type OrbitData = {
  alive: Observable[];
  antagonists: Antags;
  dead: Observable[];
  ghosts: Observable[];
  misc: Observable[];
  npcs: Observable[];
};

export type Observable = {
  extra?: string;
  full_name: string;
  health?: number;
  job?: string;
  job_icon?: string;
  name?: string;
  orbiters?: number;
  ref: string;
};
