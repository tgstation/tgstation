import { loadMappings } from 'common/assets';
import { loadedMappings } from '../../assets';

/// --------- Handlers ------------------------------------------------------///

/** This just lets us load in our own independent map */
export function handleLoadAssets(payload: Record<string, string>): void {
  loadMappings(payload, loadedMappings);
}
