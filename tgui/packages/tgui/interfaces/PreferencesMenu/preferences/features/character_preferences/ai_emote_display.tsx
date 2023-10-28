import { FeatureIconnedDropdownInput, FeatureWithIcons } from '../base';

export const preferred_ai_emote_display: FeatureWithIcons<string> = {
  name: 'AI emote display',
  description:
    'If you are an AI, this is the default image to be displayed on all AI monitor consoles across the station. This can be changed in-round.',
  component: FeatureIconnedDropdownInput,
};
