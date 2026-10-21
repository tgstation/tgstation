import type { BooleanLike } from 'tgui-core/react';
import type { CatalogueRef } from '../common/catalogue';
import type { ExperimentData } from '../ExperimentConfigure';

type StoredDesigns = Record<string, 1>;

export type DesignDisk = {
  blueprints: string[];
};

export type TechDisk = {
  stored_research: StoredDesigns;
};

// Base node type
export type NodeCache = {
  name: string;
  description: string;
  prerequisite_nodes?: string[];
  unlocked_designs?: string[];
  unlocked_nodes?: string[];
  required_experiments?: string[];
  discount_experiments?: Record<string, number>;
  discount_boosts?: Record<string, number>;
};

// The unmapped nodes from Byond - point types, nodes, designs and experiments are all by id
type DefaultNode = {
  name: string;
  description: string;
  costs: Record<string, number>;
  prerequisite_nodes?: number[];
  unlocked_designs?: number[];
  unlocked_nodes?: number[];
  required_experiments?: number[];
  /** Id, discount pairs */
  discount_experiments?: number[];
  discount_boosts?: Record<string, number>;
};

// Available nodes
export type TechwebNode = {
  can_unlock: BooleanLike;
  enqueued_by_user: BooleanLike;
  have_experiments_done: BooleanLike;
  discount_boosted: BooleanLike;
  path: string;
  is_free: BooleanLike;
  tier: number;
};

/** The catalogue file, which has the display data for every node and design */
export type CatalogueFile = {
  version: number;
  point_types_abbreviations: Record<string, string>;
  /** Name, material id and amount pairs, build types, department flags, icon class */
  design_cache: Record<string, [string, number[], number, number, string]>;
  /** What each id stands for, in id order. Designs are just 0 since we only ever look them up by id */
  id_cache: (string | 0)[];
  node_cache: Record<string, DefaultNode>;
  build_types: Record<string, string>;
  department_flags: Record<string, string>;
  SHEET_MATERIAL_AMOUNT: number;
};

/** Flags for the nodes in TechWebData - keep these in sync with the defines in code/modules/research/techweb/_techweb.dm */
export enum NodeFlag {
  Free = 1 << 0,
  CanUnlock = 1 << 1,
  ExperimentsDone = 1 << 2,
  QueuedByViewer = 1 << 3,
  Boosted = 1 << 4,
}

/** The data we get sent, with nodes, designs and experiments all referenced by catalogue id */
export type TechWebData = {
  /** Not just catalogue, as NT Shopping's static data can still be around for a moment after an app switch */
  techweb_catalogue?: CatalogueRef;
  /** Experiment descriptions by id, with the type and text of each stage of their progress */
  experiment_metadata?: Record<
    string,
    Omit<ExperimentData, 'progress' | 'completed'> & {
      stages: [string, string][];
    }
  >;
  /** Each slot's design id, null when empty */
  d_disk: (number | null)[] | null;
  /** Id, stage values, completed triples */
  experiments: (number | number[][] | BooleanLike)[];
  locked: BooleanLike;
  /** Id, tier, NodeFlag triples */
  nodes: number[];
  points_last_tick: Record<string, number>;
  points: Record<string, number>;
  /** Id, queuer pairs */
  queue_nodes: (number | string | null)[];
  sec_protocols: BooleanLike;
  stored_research: BooleanLike;
  t_disk: number[] | null;
};
