/**
 * This helps to let players have different settings upto each codebase.
 * The key for backend (check storage.js) is determined by a value declared here
 * @file
 * @copyright 2023 EvilDragonfiend
 * @license MIT
 */

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
