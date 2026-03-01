import { CheckboxInput, type FeatureToggle } from '../base';

export const widescreenpref: FeatureToggle = {
  name: 'Enable widescreen',
  category: 'UI',
  component: CheckboxInput,
};

export const fullscreen_mode: FeatureToggle = {
  name: 'Toggle Fullscreen',
  category: 'UI',
  description: 'Toggles Fullscreen for the game, can also be toggled with F11.',
  component: CheckboxInput,
};
