/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import type { Dispatch } from 'common/redux';

import type { Action, AnyAction, Middleware } from '../common/redux';

const EXCLUDED_PATTERNS = [/v4shim/i];
const loadedMappings: Record<string, string> = {};

export const resolveAsset = (name: string): string =>
  loadedMappings[name] || name;

export const assetMiddleware: Middleware =
  (storeApi) =>
  <ActionType extends Action = AnyAction>(next: Dispatch<ActionType>) =>
  (action: ActionType) => {
    const { type, payload } = action as AnyAction;
    if (type === 'asset/stylesheet') {
      Byond.loadCss(payload);
      return;
    }
    if (type === 'asset/mappings') {
      for (const name of Object.keys(payload)) {
        // Skip anything that matches excluded patterns
        if (EXCLUDED_PATTERNS.some((regex) => regex.test(name))) {
          continue;
        }
        const url = payload[name];
        const ext = name.split('.').pop();
        loadedMappings[name] = url;
        if (ext === 'css') {
          Byond.loadCss(url);
        }
        if (ext === 'js') {
          Byond.loadJs(url);
        }
      }
      return;
    }
    next(action);
  };
