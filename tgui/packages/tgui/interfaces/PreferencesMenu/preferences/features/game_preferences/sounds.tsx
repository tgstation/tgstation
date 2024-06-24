import {
  CheckboxInput,
  Feature,
  FeatureChoiced,
  FeatureSliderInput,
  FeatureToggle,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const sound_ambience: FeatureToggle = {
  name: 'Enable ambience',
  category: 'SOUND',
  description: `Ambience refers to the more noticeable ambient sounds that play on occasion.`,
  component: CheckboxInput,
};

export const sound_announcements: FeatureToggle = {
  name: 'Enable announcement sounds',
  category: 'SOUND',
  description: 'When enabled, hear sounds for command reports, notices, etc.',
  component: CheckboxInput,
};

export const sound_combatmode: FeatureToggle = {
  name: 'Enable combat mode sound',
  category: 'SOUND',
  description: 'When enabled, hear sounds when toggling combat mode.',
  component: CheckboxInput,
};

export const sound_endofround: FeatureToggle = {
  name: 'Enable end of round sounds',
  category: 'SOUND',
  description: 'When enabled, hear a sound when the server is rebooting.',
  component: CheckboxInput,
};

export const sound_instruments: FeatureToggle = {
  name: 'Enable instruments',
  category: 'SOUND',
  description: 'When enabled, be able hear instruments in game.',
  component: CheckboxInput,
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

export const sound_jukebox: FeatureToggle = {
  name: 'Enable jukebox music',
  category: 'SOUND',
  description: 'When enabled, hear music for jukeboxes, dance machines, etc.',
  component: CheckboxInput,
};

export const sound_lobby: FeatureToggle = {
  name: 'Enable lobby music',
  category: 'SOUND',
  component: CheckboxInput,
};

export const sound_midi: FeatureToggle = {
  name: 'Enable admin music',
  category: 'SOUND',
  description: 'When enabled, admins will be able to play music to you.',
  component: CheckboxInput,
};

export const sound_ship_ambience: FeatureToggle = {
  name: 'Enable ship ambience',
  category: 'SOUND',
  description: `Ship ambience refers to the low ambient buzz that plays on loop.`,
  component: CheckboxInput,
};

export const sound_elevator: FeatureToggle = {
  name: 'Enable elevator music',
  category: 'SOUND',
  component: CheckboxInput,
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
