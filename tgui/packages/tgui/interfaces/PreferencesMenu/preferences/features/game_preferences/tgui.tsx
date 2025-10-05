import { CheckboxInput, type FeatureToggle } from '../base';

export const tgui_fancy: FeatureToggle = {
  name: 'Enable fancy TGUI',
  category: 'UI',
  description: 'Makes TGUI windows look better, at the cost of compatibility.',
  component: CheckboxInput,
};

export const tgui_input: FeatureToggle = {
  name: 'Input: Enable TGUI',
  category: 'UI',
  description: 'Renders input boxes in TGUI.',
  component: CheckboxInput,
};

export const tgui_input_large: FeatureToggle = {
  name: 'Input: Larger buttons',
  category: 'UI',
  description: 'Makes TGUI buttons less traditional, more functional.',
  component: CheckboxInput,
};

export const tgui_input_swapped: FeatureToggle = {
  name: 'Input: Swap Submit/Cancel buttons',
  category: 'UI',
  description: 'Makes TGUI buttons less traditional, more functional.',
  component: CheckboxInput,
};

export const tgui_lock: FeatureToggle = {
  name: 'Lock TGUI to main monitor',
  category: 'UI',
  description: 'Locks TGUI windows to your main monitor.',
  component: CheckboxInput,
};

export const ui_scale: FeatureToggle = {
  name: 'Toggle UI scaling',
  category: 'UI',
  description: 'If UIs should scale up to match your monitor scaling.',
  component: CheckboxInput,
};

export const tgui_say_light_mode: FeatureToggle = {
  name: 'Say: Light mode',
  category: 'UI',
  description: 'Sets TGUI Say to use a light mode.',
  component: CheckboxInput,
};
