import { BooleanLike } from 'common/react';

import { VIEWMODE } from './constants';

export type Antagonist = Observable & { antag: string; antag_group: string };

export type AntagGroup = [string, Antagonist[]];

export type OrbitData = {
  alive: Observable[];
  antagonists: Antagonist[];
  dead: Observable[];
  deadchat_controlled: Observable[];
  ghosts: Observable[];
  misc: Observable[];
  npcs: Observable[];
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
  job: string;
  name: string;
  orbiters: number;
}>;

export type ViewMode = (typeof VIEWMODE)[keyof typeof VIEWMODE];
