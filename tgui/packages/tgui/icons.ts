import { resolveAsset } from './assets';
import { fetchRetry } from './http';
import { logger } from './logging';

export function loadIconRefMap() {
  if (Object.keys(Byond.iconRefMap).length > 0) {
    return;
  }

  fetchRetry(resolveAsset('icon_ref_map.json'))
    .then((res) => res.json())
    .then((data) => (Byond.iconRefMap = data))
    .catch((error) => logger.log(error));
}
