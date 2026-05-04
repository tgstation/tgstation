import { createContext, useContext } from 'react';

import type { ServerData } from './types';

export const ServerPrefs = createContext<ServerData | undefined>({
  jobs: {
    departments: {},
    jobs: {},
  },
  names: {
    types: {},
  },
  quirks: {
    max_positive_quirks: -1,
    quirk_info: {},
    quirk_blacklist: [],
    points_enabled: false,
  },
  personality: {
    personalities: [],
    personality_incompatibilities: {},
  },
  random: {
    randomizable: [],
  },
  loadout: {
    loadout_tabs: [],
  },
  species: {},
});

export function useServerPrefs() {
  return useContext(ServerPrefs);
}
