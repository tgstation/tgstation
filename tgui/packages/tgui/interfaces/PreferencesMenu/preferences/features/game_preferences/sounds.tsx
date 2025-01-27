import { Feature, FeatureChoiced, FeatureSliderInput } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const sound_ambience_volume: Feature<number> = {
  name: 'Ambience volume',
  category: 'SOUND',
  description: `Ambience refers to the more noticeable ambient sounds that play on occasion.`,
  component: FeatureSliderInput,
};

export const sound_breathing: Feature<number> = {
  name: 'Breathing sounds volume',
  category: 'SOUND',
  description: 'Volume of the breathing sounds when using internals.',
  component: FeatureSliderInput,
};

export const sound_announcements: Feature<number> = {
  name: 'Announcement sounds volume',
  category: 'SOUND',
  description: 'Volume of the sounds for command reports, notices, etc.',
  component: FeatureSliderInput,
};

export const sound_combatmode: Feature<number> = {
  name: 'Combat mode sound volume',
  category: 'SOUND',
  description: 'Volume of the sounds when toggling combat mode.',
  component: FeatureSliderInput,
};

export const sound_endofround: Feature<number> = {
  name: 'End of round sounds volume',
  category: 'SOUND',
  description: 'Volume of the sound when the server is rebooting.',
  component: FeatureSliderInput,
};

export const sound_instruments: Feature<number> = {
  name: 'Instruments volume',
  category: 'SOUND',
  description: 'Volume of instruments.',
  component: FeatureSliderInput,
};

export const sound_tts: FeatureChoiced = {
  name: 'Enable TTS',
  category: 'SOUND',
  description: `
    When enabled, be able to hear text-to-speech sounds in game.
    When set to "Blips", text to speech will be replaced with blip sounds based on the voice.
  `,
  component: FeatureDropdownInput,
};

export const sound_tts_volume: Feature<number> = {
  name: 'TTS Volume',
  category: 'SOUND',
  description: 'The volume that the text-to-speech sounds will play at.',
  component: FeatureSliderInput,
};

export const sound_jukebox: Feature<number> = {
  name: 'Jukebox music volume',
  category: 'SOUND',
  description: 'Volume of jukeboxes, dance machines, etc.',
  component: FeatureSliderInput,
};

export const sound_lobby_volume: Feature<number> = {
  name: 'Lobby music volume',
  category: 'SOUND',
  component: FeatureSliderInput,
};

export const sound_midi: Feature<number> = {
  name: 'Admin music volume',
  category: 'SOUND',
  description: 'Volume of admin musics.',
  component: FeatureSliderInput,
};

export const sound_ship_ambience_volume: Feature<number> = {
  name: 'Ship ambience volume',
  category: 'SOUND',
  description: `Ship ambience refers to the low ambient buzz that plays on loop.`,
  component: FeatureSliderInput,
};

export const sound_elevator: Feature<number> = {
  name: 'Elevator music volume',
  category: 'SOUND',
  component: FeatureSliderInput,
};

export const sound_achievement: FeatureChoiced = {
  name: 'Achievement unlock sound',
  category: 'SOUND',
  description: `
    The sound that's played when unlocking an achievement.
    If disabled, no sound will be played.
  `,
  component: FeatureDropdownInput,
};

export const sound_radio_noise: Feature<number> = {
  name: 'Radio noise volume',
  category: 'SOUND',
  description: `Volume of talking and hearing radio chatter sounds.`,
  component: FeatureSliderInput,
};

export const sound_ai_vox: Feature<number> = {
  name: 'AI VOX announcements volume',
  category: 'SOUND',
  description: 'Volume of vocal AI announcements (also known as "VOX").',
  component: FeatureSliderInput,
};
