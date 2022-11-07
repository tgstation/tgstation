export type AntagGroup = [string, Antags];

export type Antags = Array<Observable & { antag: string }>;

export type OrbitData = {
  alive: Array<Observable>;
  antagonists: Antags;
  dead: Array<Observable>;
  ghosts: Array<Observable>;
  misc: Array<Observable>;
  npcs: Array<Observable>;
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
