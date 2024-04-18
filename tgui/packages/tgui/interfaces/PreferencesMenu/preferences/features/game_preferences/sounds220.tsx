import { Feature, FeatureSliderInput } from '../base';

// BANDASTATION SOUND PREFS

export const sound_tts_volume_radio: Feature<number> = {
  name: 'TTS - громкость рации',
  category: 'ЗВУК',
  description: 'Громкость text-to-speech, когда используется рация.',
  component: FeatureSliderInput,
};
