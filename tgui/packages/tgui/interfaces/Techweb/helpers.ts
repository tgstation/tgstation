import { map } from 'common/collections';

import { useBackend } from '../../backend';
import { NodeCache, TechWebData } from './types';

type Cost = {
  type: string;
  value: number;
};

type RemappedNode = NodeCache & {
  id: string;
  costs: Cost[];
};

type RemappedDesignCache = {
  name: string;
  class: string;
};

// Data reshaping / ingestion (thanks stylemistake for the help, very cool!)
// This is primarily necessary due to measures that are taken to reduce the size
// of the sent static JSON payload to as minimal of a size as possible
// as larger sizes cause a delay for the user when opening the UI.

const remappingIdCache = {};

function remapId(id: string) {
  return remappingIdCache[id];
}

function selectRemappedStaticData(data: TechWebData) {
  // Handle reshaping of node cache to fill in unsent fields, and
  // decompress the node IDs
  const node_cache = {} as RemappedNode;

  for (let id of Object.keys(data.static_data.node_cache)) {
    const node = data.static_data.node_cache[id];

    const costs = Object.keys(node.costs || {}).map((x) => ({
      type: remapId(x),
      value: node.costs[x],
    }));

    node_cache[remapId(id)] = {
      ...node,
      id: remapId(id),
      costs,
      prereq_ids: map(node.prereq_ids || [], remapId),
      design_ids: map(node.design_ids || [], remapId),
      unlock_ids: map(node.unlock_ids || [], remapId),
      required_experiments: node.required_experiments || [],
      discount_experiments: node.discount_experiments || [],
    };
  }

  // Do the same as the above for the design cache
  const design_cache = {} as RemappedDesignCache;
  for (let id of Object.keys(data.static_data.design_cache)) {
    const [name, classes] = data.static_data.design_cache[id];
    design_cache[remapId(id)] = {
      name: name,
      class: classes.startsWith('design') ? classes : `design32x32 ${classes}`,
    };
  }

  return {
    node_cache,
    design_cache,
  };
}

let remappedStaticData: ReturnType<typeof selectRemappedStaticData>;

export function useRemappedBackend() {
  const { data, ...rest } = useBackend<TechWebData>();

  // Only remap the static data once, cache for future use
  if (!remappedStaticData) {
    const id_cache = data.static_data.id_cache;
    for (let i = 0; i < id_cache.length; i++) {
      remappingIdCache[i + 1] = id_cache[i];
    }
    remappedStaticData = selectRemappedStaticData(data);
  }

  return {
    data: {
      ...data,
      static_data: undefined,
      ...remappedStaticData,
    },
    ...rest,
  };
}
