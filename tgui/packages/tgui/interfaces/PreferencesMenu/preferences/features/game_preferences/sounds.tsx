import { multiline } from 'common/string';
import { CheckboxInput, FeatureChoiced, FeatureDropdownInput, FeatureToggle } from '../base';

export const sound_ambience: FeatureToggle = {
  name: 'Enable ambience',
  category: 'SOUND',
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
  component: CheckboxInput,
};

export const sound_achievement: FeatureChoiced = {
  name: 'Achievement unlock sound',
  category: 'SOUND',
  description: multiline`
    The sound that's played when unlocking an achievement.
    If disabled, no sound will be played.
  `,
  component: FeatureDropdownInput,
};

// monke edit start - AI vox announcement toggle
export const sound_vox: FeatureToggle = {
  name: 'Enable AI VOX announcements',
  category: 'SOUND',
  subcategory: 'IC',
  description: 'When enabled, hear AI VOX (text-to-speech) announcements.',
  component: CheckboxInput,
};
// monke edit end
