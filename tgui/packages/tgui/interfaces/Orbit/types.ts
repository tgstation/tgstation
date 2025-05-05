import { BooleanLike } from 'tgui-core/react';

import { VIEWMODE } from './constants';

export type Antagonist = Observable & {
  antag: string;
  antag_group: string;
  antag_icon: string;
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
  mind_icon: string;
  job: string;
  mind_job: string;
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
