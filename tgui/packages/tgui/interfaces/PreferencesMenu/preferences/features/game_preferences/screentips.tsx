import {
  CheckboxInput,
  type Feature,
  type FeatureChoiced,
  FeatureColorInput,
  type FeatureToggle,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const screentip_color: Feature<string> = {
  name: 'Screentips: Screentips color',
  category: 'UI',
  description: `
    The color of screen tips, the text you see when hovering over something.
  `,
  component: FeatureColorInput,
};

export const screentip_images: FeatureToggle = {
  name: 'Screentips: Allow images',
  category: 'UI',
  description: `When enabled, screentip hints use images for
    the mouse button rather than LMB/RMB.`,
  component: CheckboxInput,
};

export const screentip_pref: FeatureChoiced = {
  name: 'Screentips: Enable screentips',
  category: 'UI',
  description: `
    Enables screen tips, the text you see when hovering over something.
    When set to "Only with tips", will only show when there is more information
    than just the name, such as what right-clicking it does.
  `,
  component: FeatureDropdownInput,
};
