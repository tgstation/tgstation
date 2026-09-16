import { assetMap } from './assets';

function getAssetUrl(name: string): string | null {
  return assetMap[name] ?? null;
}

function playOneShot(name: string) {
  const url = getAssetUrl(name);
  if (!url) return;
  const audio = new Audio(url);
  audio.volume = 0.6;
  audio.play().catch(() => {});
}

export function playSelectSound() {
  playOneShot('ui_select1.ogg');
}

export function playCollapseSound() {
  playOneShot('menu_rollup1.ogg');
}

export function playExpandSound() {
  playOneShot('menu_rolldown1.ogg');
}
