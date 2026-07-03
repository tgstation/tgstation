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
  // BANDASTATION ADDITION START - TTS
  text_to_speech: {
    providers: [],
    seeds: [],
    phrases: [],
  },
  // BANDASTATION ADDITION END - TTS
  // BANDASTATION ADDITION START - Feat: Augmentations
  pref_job_slots: {},
  profile_index: 0,
  body_modifications: [],
  // BANDASTATION ADDITION END - Feat: Augmentations
});

export function useServerPrefs() {
  return useContext(ServerPrefs);
}
