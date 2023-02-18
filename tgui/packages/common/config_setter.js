/**
 * This is a pair file with `tgui_config.js` in config directory
 * @file
 * @copyright 2023 EvilDragonfiend
 * @license MIT
 */

import { PREF_ADDITION_KEY } from '../../../config/tgui_config';
import { storage } from './storage';

export const get_pref_addition_key = () => {
  const thing = '-cfg-' + PREF_ADDITION_KEY;
  return thing;
};

export const get_config_key = () => {
  let thing = sessionStorage.getItem(get_pref_addition_key());
  if (thing === undefined) {
    return '';
  }
  return thing;
};

export const set_config_key = (value) => {
  sessionStorage.setItem(get_pref_addition_key(), value);
  storage.set_config_key(value);
};

export const init_config_key = async () => {
  let thing = await storage.get_config_key();
  if (thing === undefined) {
    thing = '';
  }
  sessionStorage.setItem(get_pref_addition_key(), thing);
};
