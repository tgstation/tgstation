/**
 * This is a pair file with `tgui_config.js` in config directory
 * @file
 * @copyright 2023 EvilDragonfiend
 * @license MIT
 */

import { PREF_ADDITION_KEY } from '../../../config/tgui_config';
import { storage } from './storage';

export const getPrefAdditionKey = () => {
  const thing = '-cfg-' + PREF_ADDITION_KEY;
  return thing;
};

export const getConfigKey = () => {
  let thing = sessionStorage.getItem(getPrefAdditionKey());
  if (thing === undefined) {
    return '';
  }
  return thing;
};

export const setConfigKey = (value) => {
  sessionStorage.setItem(getPrefAdditionKey(), value);
  storage.set_noconfig(getPrefAdditionKey(), value);
};

export const setupConfigKey = async () => {
  let thing = await storage.get_noconfig(getPrefAdditionKey());
  if (thing === undefined) {
    thing = '';
  }
  sessionStorage.setItem(getPrefAdditionKey(), thing);
};
