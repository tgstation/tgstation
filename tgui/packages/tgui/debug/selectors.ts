/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { zustandStore } from '..';

export const selectDebug = (state) => zustandStore.getState()?.debug;
