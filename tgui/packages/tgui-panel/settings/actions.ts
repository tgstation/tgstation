/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createAction } from 'common/redux';

export const importSettings = createAction(
  'settings/import',
  (settings, pages) => ({
    payload: { newSettings: settings, newPages: pages },
  }),
);
