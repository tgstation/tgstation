/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useSelector } from '../backend';
import { selectDebug } from './selectors';

export const useDebug = () => useSelector(selectDebug);
