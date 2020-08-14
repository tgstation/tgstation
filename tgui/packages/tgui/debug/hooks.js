/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useSelector } from 'common/redux';
import { selectDebug } from './selectors';

export const useDebug = context => useSelector(context, selectDebug);
