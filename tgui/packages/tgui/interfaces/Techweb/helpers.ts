import { map } from 'es-toolkit/compat';
import { createContext, useContext } from 'react';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';
import type { ExperimentData } from '../ExperimentConfigure';
import type { Design } from '../Fabrication/Types';
import {
  type CatalogueFile,
  type DesignDisk,
  type NodeCache,
  NodeFlag,
  type TechDisk,
  type TechWebData,
  type TechwebNode,
} from './types';

type Cost = {
  type: string;
  value: number;
};

type RemappedNode = NodeCache & {
  costs: Cost[];
};

type RemappedDesignCache = Design & {
  class: string;
  department_flags: number;
  build_type: number;
};

// Data reshaping / ingestion (thanks stylemistake for the help, very cool!)
// This is primarily necessary due to measures that are taken to reduce the size
// of the sent JSON payloads to as minimal of a size as possible
// as larger sizes cause a delay for the user when opening the UI.

/** Turns id, value pairs back into a record keyed by what the ids stand for, keeping the order */
function remapPairs(pairs: number[], remapId: (id: number) => string) {
  const record: Record<string, number> = {};
  for (let offset = 0; offset < pairs.length; offset += 2) {
    record[remapId(pairs[offset])] = pairs[offset + 1];
  }
  return record;
}

export function remapCatalogue(file: CatalogueFile) {
  const remapId = (id: string | number) =>
    file.id_cache[Number(id) - 1] as string;
  // Handle reshaping of node cache to fill in unsent fields, and
  // decompress the node IDs
  const node_cache = {} as RemappedNode;

  for (const id of Object.keys(file.node_cache)) {
    const node = file.node_cache[id];

    const costs = Object.keys(node.costs || {}).map((x) => ({
      type: remapId(x),
      value: node.costs[x],
    }));

    node_cache[remapId(id)] = {
      ...node,
      id: remapId(id),
      costs,
      prerequisite_nodes: map(node.prerequisite_nodes || [], remapId),
      unlocked_designs: map(node.unlocked_designs || [], String),
      unlocked_nodes: map(node.unlocked_nodes || [], remapId),
      required_experiments: map(node.required_experiments || [], remapId),
      discount_experiments: node.discount_experiments
        ? remapPairs(node.discount_experiments, remapId)
        : [],
      discount_boosts: node.discount_boosts || [],
    };
  }

  // Do the same as the above for the design cache, except we keep it keyed by id
  const design_cache = {} as RemappedDesignCache;
  for (const id of Object.keys(file.design_cache)) {
    const [name, cost, build_types, department_flags, classes] =
      file.design_cache[id];
    design_cache[id] = {
      name: name,
      cost: remapPairs(cost, remapId),
      build_types: build_types,
      department_flags: department_flags,
      class: classes.startsWith('design') ? classes : `design32x32 ${classes}`,
    };
  }

  return {
    node_cache,
    design_cache,
    build_types: file.build_types,
    department_flags: file.department_flags,
    SHEET_MATERIAL_AMOUNT: file.SHEET_MATERIAL_AMOUNT,
    point_types_abbreviations: file.point_types_abbreviations,
    remapId,
  };
}

/** Everything the techweb shows, which is our data joined with the catalogue */
export type ResearchData = ReturnType<typeof remapCatalogue> & {
  d_disk: DesignDisk | null;
  experiments: Record<string, ExperimentData>;
  locked: BooleanLike;
  nodes: TechwebNode[];
  /** Each node's tier by path, for looking prerequisites up */
  node_tiers: Record<string, number>;
  points_last_tick: Record<string, number>;
  points: Record<string, number>;
  queue_nodes: Record<string, string>[];
  sec_protocols: BooleanLike;
  stored_research: BooleanLike;
  t_disk: TechDisk | null;
};

/** Joins our data with the catalogue, skipping anything the catalogue on screen doesn't have yet */
export function joinResearch(
  data: TechWebData,
  catalogue: ReturnType<typeof remapCatalogue>,
): ResearchData {
  const { node_cache, design_cache, remapId } = catalogue;

  const nodes: TechwebNode[] = [];
  const node_tiers: Record<string, number> = {};
  for (let offset = 0; offset < data.nodes.length; offset += 3) {
    const path = remapId(data.nodes[offset]);
    if (!node_cache[path]) {
      continue;
    }
    const flags = data.nodes[offset + 2];
    const tier = data.nodes[offset + 1];
    node_tiers[path] = tier;
    nodes.push({
      path,
      is_free: flags & NodeFlag.Free ? 1 : 0,
      can_unlock: flags & NodeFlag.CanUnlock ? 1 : 0,
      have_experiments_done: flags & NodeFlag.ExperimentsDone ? 1 : 0,
      tier,
      enqueued_by_user: flags & NodeFlag.QueuedByViewer ? 1 : 0,
      discount_boosted: flags & NodeFlag.Boosted ? 1 : 0,
    });
  }

  // An empty queue has to stay an array, that's how the components tell it's empty (they check .length)
  let queue_nodes: Record<string, string> | [] = [];
  if (data.queue_nodes.length) {
    const queued: Record<string, string> = {};
    for (let offset = 0; offset < data.queue_nodes.length; offset += 2) {
      const path = remapId(data.queue_nodes[offset] as number);
      if (node_cache[path]) {
        queued[path] = data.queue_nodes[offset + 1] as string;
      }
    }
    queue_nodes = queued;
  }

  const experiments: Record<string, ExperimentData> = {};
  for (let offset = 0; offset < data.experiments.length; offset += 3) {
    const id = data.experiments[offset] as number;
    const values = data.experiments[offset + 1] as number[][];
    const description = data.experiment_metadata?.[id];
    // The stage texts come with our static data, so they can only fail to line up while that is on its way
    if (description?.stages.length === values.length) {
      const { stages, ...metadata } = description;
      experiments[remapId(id)] = {
        ...metadata,
        progress: stages.map((stage, index) => [
          ...stage,
          ...values[index],
        ]) as ExperimentData['progress'],
        completed: data.experiments[offset + 2] as BooleanLike,
      };
    }
  }

  return {
    ...catalogue,
    nodes,
    node_tiers,
    queue_nodes: queue_nodes as Record<string, string>[],
    experiments,
    t_disk: data.t_disk && {
      stored_research: Object.fromEntries(
        data.t_disk
          .map(remapId)
          .filter((path) => node_cache[path])
          .map((path): [string, 1] => [path, 1]),
      ),
    },
    // Empty slots stay null
    d_disk: data.d_disk && {
      blueprints: data.d_disk.map((id) =>
        id !== null && design_cache[id] ? String(id) : null,
      ) as string[],
    },
    locked: data.locked,
    points: data.points,
    points_last_tick: data.points_last_tick,
    sec_protocols: data.sec_protocols,
    stored_research: data.stored_research,
  };
}

export const TechwebDataContext = createContext<ResearchData | undefined>(
  undefined,
);

/** Like useBackend(), but with the data already joined with the catalogue by TechwebDataProvider */
export function useRemappedBackend() {
  const backend = useBackend<TechWebData>();
  const data = useContext(TechwebDataContext) as ResearchData;
  return { ...backend, data };
}
