import { loadMappings } from 'common/assets';
import { loadedMappings } from '../../assets';
import { loadIconMap } from '../../iconMap';

/// --------- Handlers ------------------------------------------------------///

export function handleLoadAssets(payload: Record<string, string>): void {
  loadMappings(payload, loadedMappings);

  if (payload['icon_ref_map.json']) {
    void loadIconMap(payload['icon_ref_map.json']);
  }
}
