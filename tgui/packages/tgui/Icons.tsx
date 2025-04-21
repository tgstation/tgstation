import { Suspense, useEffect } from 'react';
import { fetchRetry } from 'tgui-core/http';

import { resolveAsset } from './assets';
import { logger } from './logging';

function loadIconMap() {
  fetchRetry(resolveAsset('icon_ref_map.json'))
    .then((res) => res.json())
    .then((data) => (Byond.iconRefMap = data))
    .catch((error) => logger.log(error));
}

function IconMapLoader() {
  useEffect(() => {
    if (Object.keys(Byond.iconRefMap).length === 0) {
      loadIconMap();
    }
  }, []);

  return null;
}

export function IconProvider() {
  return (
    <Suspense fallback={null}>
      <IconMapLoader />
    </Suspense>
  );
}
