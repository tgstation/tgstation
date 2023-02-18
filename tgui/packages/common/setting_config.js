/**
 * This helps to let players have different settings upto each codebase.
 * The key for backend (check storage.js) is determined by a value declared here
 *
 * @file
 * @copyright 2023 EvilDragonfiend
 * @license MIT
 */

import { storage } from "./storage";



// This key is important as a configurable setting.
// This key is recommended to be different up to each codebase
export const PREF_ADDITION_KEY = 'tgstation';

// This is the list of configurable options.
// You can put more options as much as you want
// but removing `Shared ABC` isn't recommended, and should be used for all codebases
export const PREF_KEYS = [
  {
    id: 'Default',
    value: '', // put this as blank
  },
  {
    id: 'Shared A',
    value: 'shared_a',
  },
  {
    id: 'Shared B',
    value: 'shared_b',
  },
  {
    id: 'Shared C',
    value: 'shared_c',
  },
  // customs
  {
    id: 'TGstation A',
    value: 'tgstation_a',
  },
  {
    id: 'TGstation B',
    value: 'tgstation_b',
  },
  {
    id: 'TGstation C',
    value: 'tgstation_c',
  },
];


// -------------------------------------------------------------------------
// These are NOT configurable.
export const get_pref_addition_key = () => {
  const thing = '-cfg-'+PREF_ADDITION_KEY;
  return thing;
};

export const get_config_key = () => {
  let thing = sessionStorage.getItem(get_pref_addition_key());
  if (thing === undefined) { return ''; }
  return thing;
};

export const set_config_key = (value) => {
  sessionStorage.setItem(get_pref_addition_key(), value);
  storage.set_config_key(value);
};

export const init_config_key = async () => {
  let thing = await storage.get_config_key();
  if (thing === undefined) { thing = ''; }
  sessionStorage.setItem(get_pref_addition_key(), thing);
};
