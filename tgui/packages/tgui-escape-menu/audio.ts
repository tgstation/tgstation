import { assetMap } from './assets';

let ambientAudio: HTMLAudioElement | null = null;

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

function startAmbient(name: string) {
  stopAmbient();
  const url = getAssetUrl(name);
  if (!url) return;
  ambientAudio = new Audio(url);
  ambientAudio.volume = 0.8;
  ambientAudio.play().catch(() => {});
}

function stopAmbient() {
  if (ambientAudio) {
    const audio = ambientAudio;
    ambientAudio = null;
    audio.pause();
  }
}

export function playOpenSounds() {
  playOneShot('esc_open.ogg');
  startAmbient('esc_middle.ogg');
}

export function playCloseSounds() {
  stopAmbient();
  playOneShot('esc_close.ogg');
}
