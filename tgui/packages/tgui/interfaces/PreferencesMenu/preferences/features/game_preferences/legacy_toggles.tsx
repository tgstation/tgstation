import { multiline } from 'common/string';
import { FeatureToggle, CheckboxInput, CheckboxInputInverse } from '../base';

export const admin_ignore_cult_ghost: FeatureToggle = {
  name: 'Prevent being summoned as a cult ghost',
  category: 'ADMIN',
  description: multiline`
    When enabled and observing, prevents Spirit Realm from forcing you
    into a cult ghost.
  `,
  component: CheckboxInput,
};

export const announce_login: FeatureToggle = {
  name: 'Announce login',
  category: 'ADMIN',
  description: 'Admins will be notified when you login.',
  component: CheckboxInput,
};

export const combohud_lighting: FeatureToggle = {
  name: 'Enable fullbright Combo HUD',
  category: 'ADMIN',
  component: CheckboxInput,
};

export const deadmin_always: FeatureToggle = {
  name: 'Auto deadmin - Always',
  category: 'ADMIN',
  description: 'When enabled, you will automatically deadmin.',
  component: CheckboxInput,
};

export const deadmin_antagonist: FeatureToggle = {
  name: 'Auto deadmin - Antagonist',
  category: 'ADMIN',
  description: 'When enabled, you will automatically deadmin as an antagonist.',
  component: CheckboxInput,
};

export const deadmin_position_head: FeatureToggle = {
  name: 'Auto deadmin - Head of Staff',
  category: 'ADMIN',
  description:
    'When enabled, you will automatically deadmin as a head of staff.',
  component: CheckboxInput,
};

export const deadmin_position_security: FeatureToggle = {
  name: 'Auto deadmin - Security',
  category: 'ADMIN',
  description:
    'When enabled, you will automatically deadmin as a member of security.',
  component: CheckboxInput,
};

export const deadmin_position_silicon: FeatureToggle = {
  name: 'Auto deadmin - Silicon',
  category: 'ADMIN',
  description: 'When enabled, you will automatically deadmin as a silicon.',
  component: CheckboxInput,
};

export const disable_arrivalrattle: FeatureToggle = {
  name: 'Notify for new arrivals',
  category: 'GHOST',
  description: 'When enabled, you will be notified as a ghost for new crew.',
  component: CheckboxInputInverse,
};

export const disable_deathrattle: FeatureToggle = {
  name: 'Notify for deaths',
  category: 'GHOST',
  description:
    'When enabled, you will be notified as a ghost whenever someone dies.',
  component: CheckboxInputInverse,
};

export const member_public: FeatureToggle = {
  name: 'Publicize BYOND membership',
  category: 'CHAT',
  description:
    'When enabled, a BYOND logo will be shown next to your name in OOC.',
  component: CheckboxInput,
};

export const sound_adminhelp: FeatureToggle = {
  name: 'Enable adminhelp sounds',
  category: 'ADMIN',
  component: CheckboxInput,
};

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

export const sound_prayers: FeatureToggle = {
  name: 'Enable prayer sound',
  category: 'ADMIN',
  component: CheckboxInput,
};

export const sound_ship_ambience: FeatureToggle = {
  name: 'Enable ship ambience',
  category: 'SOUND',
  component: CheckboxInput,
};

export const split_admin_tabs: FeatureToggle = {
  name: 'Split admin tabs',
  category: 'ADMIN',
  description: "When enabled, will split the 'Admin' panel into several tabs.",
  component: CheckboxInput,
};
