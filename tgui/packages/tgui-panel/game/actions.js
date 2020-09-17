/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createAction } from 'common/redux';

export const roundRestarted = createAction('roundrestart');
export const connectionLost = createAction('game/connectionLost');
export const connectionRestored = createAction('game/connectionRestored');
