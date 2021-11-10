/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createRequire } from 'module';

export const require = createRequire(import.meta.url);
