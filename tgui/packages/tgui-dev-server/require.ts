/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createRequire } from 'node:module';

export const require = createRequire(import.meta.url);
