import { FeatureChoiced, FeatureDropdownInput, Feature, FeatureTTSTestInput } from '../base';

export const tts_voice: FeatureChoiced = {
  name: 'Voice',
  component: FeatureDropdownInput,
};

export const tts_test: Feature<string> = {
  name: 'Test TTS',
  component: FeatureTTSTestInput,
};
