import type { BooleanLike } from 'tgui-core/react';

type StoredDesigns = Record<string, 1>;

type DesignDisk = {
  blueprints: string[];
};

type TechDisk = {
  stored_research: StoredDesigns;
};

type ProgressTuple = [string, string, number, number];

type Experiment = {
  name: string;
  description: string;
  tag: string;
  progress: ProgressTuple[];
  completed: BooleanLike;
  performance_hint: string;
};

// Base node type
export type NodeCache = {
  description: string;
  design_ids: string[];
  discount_experiments: Record<string, number>;
  name: string;
  prereq_ids: string[];
  required_experiments?: string[];
  unlock_ids: string[];
};

// The unmapped nodes from Byond
type DefaultNode = NodeCache & {
  costs: Record<string, number>;
};

// Available nodes
export type TechwebNode = {
  can_unlock: BooleanLike;
  enqueued_by_user: BooleanLike;
  have_experiments_done: BooleanLike;
  id: string;
  is_free: BooleanLike;
  tier: number;
};

// Unmapped static data
type StaticData = {
  design_cache: Record<string, [string, string]>;
  id_cache: string[];
  node_cache: Record<string, DefaultNode>;
};

export type TechWebData = {
  d_disk: DesignDisk | null;
  experiments: Record<string, Experiment>;
  locked: BooleanLike;
  nodes: TechwebNode[];
  point_types_abbreviations: Record<string, string>;
  points_last_tick: Record<string, number>;
  points: Record<string, number>;
  queue_nodes: Record<string, string>[];
  researched_designs: StoredDesigns;
  sec_protocols: BooleanLike;
  static_data: StaticData;
  stored_research: BooleanLike;
  t_disk: TechDisk | null;
};
