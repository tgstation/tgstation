import type { BooleanLike } from 'tgui-core/react';

import type { VIEWMODE } from './constants';

export type Antagonist = Observable & {
  antag: string;
  antag_group: string;
  icon: string;
  icon_state: string;
};

export type AntagGroup = [string, Antagonist[]];

export type OrbitData = {
  alive: Observable[];
  antagonists: Antagonist[];
  critical: Critical[];
  dead: Observable[];
  deadchat_controlled: Observable[];
  ghosts: Observable[];
  misc: Observable[];
  npcs: Observable[];
  orbiting: Observable | null;
  can_observe: BooleanLike;
};

export type Observable = {
  full_name: string;
  ref: string;
  // Optionals
} & Partial<{
  client: BooleanLike;
  extra: string;
  health: number;
  icon: string;
  icon_state: string;
  mind_icon: string;
  mind_icon_state: string;
  job: string;
  mind_job: string;
  mind_job_icon: string;
  name: string;
  orbiters: number;
  ckey: string;
}>;

type Critical = {
  extra: string;
  full_name: string;
  ref: string;
};

export type ViewMode = (typeof VIEWMODE)[keyof typeof VIEWMODE];
