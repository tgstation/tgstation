import { loadMappings } from 'common/assets';

const loadedMappings = {} as Record<string, string>;

/** This just lets us load in our own independent map */
export function handleLoadAssets(payload: Record<string, string>): void {
  loadMappings(payload, loadedMappings);
}
