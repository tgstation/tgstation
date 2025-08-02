import {
  CheckboxInput,
  type Feature,
  type FeatureChoiced,
  FeatureSliderInput,
  type FeatureToggle,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const sound_ambience_volume: Feature<number> = {
  name: 'Ambience volume',
  category: 'SOUND',
  description: `Ambience refers to the more noticeable ambient sounds that play on occasion.`,
  component: FeatureSliderInput,
};

export const sound_breathing: FeatureToggle = {
  name: 'Enable breathing sounds',
  category: 'SOUND',
  description: 'When enabled, hear breathing sounds when using internals.',
  component: CheckboxInput,
};

export const sound_announcements: FeatureToggle = {
  name: 'Enable announcement sounds',
  category: 'SOUND',
  description: 'When enabled, hear sounds for command reports, notices, etc.',
  component: CheckboxInput,
};

export const sound_ghost_poll_prompt: FeatureChoiced = {
  name: 'Ghost poll prompt',
  category: 'SOUND',
  description: 'Choose which sound prompt to play on getting ghost polls.',
  component: FeatureDropdownInput,
};

export const sound_ghost_poll_prompt_volume: Feature<number> = {
  name: 'Ghost poll prompt volume',
  category: 'SOUND',
  description: 'The volume that ghost poll prompts will play at.',
  component: FeatureSliderInput,
};

export const sound_combatmode: FeatureToggle = {
  name: 'Enable combat mode sound',
  category: 'SOUND',
  description: 'When enabled, hear sounds when toggling combat mode.',
  component: CheckboxInput,
};

export const sound_instruments: Feature<number> = {
  name: 'Instruments volume',
  category: 'SOUND',
  description: 'Volume of instruments.',
  component: FeatureSliderInput,
};

export const sound_jukebox: Feature<number> = {
  name: 'Jukebox volume',
  category: 'SOUND',
  description: 'Volume of jukebox tracks.',
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

export const sound_achievement: FeatureChoiced = {
  name: 'Achievement unlock sound',
  category: 'SOUND',
  description: `
    The sound that's played when unlocking an achievement.
    If disabled, no sound will be played.
  `,
  component: FeatureDropdownInput,
};

export const sound_ai_vox: Feature<number> = {
  name: 'AI VOX announcements volume',
  category: 'SOUND',
  description: 'Volume of vocal AI announcements (also known as "VOX").',
  component: FeatureSliderInput,
};
