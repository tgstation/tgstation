import {
  CheckboxInput,
  type Feature,
  type FeatureChoiced,
  FeatureSliderInput,
  type FeatureToggle,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const sound_ambience_volume: Feature<number> = {
  name: 'Громкость окружения',
  category: 'Звук',
  description: `Различные звуки оружения, играющие по ситуации.`,
  component: FeatureSliderInput,
};

export const sound_breathing: FeatureToggle = {
  name: 'Включить звук дыхания',
  category: 'Звук',
  description: 'Слышать звук дыхания, когда подключен баллон.',
  component: CheckboxInput,
};

export const sound_announcements: FeatureToggle = {
  name: 'Включить звук анонсов',
  category: 'Звук',
  description: 'Играть звук при оповещениях с ЦК, уведомлений и тд.',
  component: CheckboxInput,
};

export const sound_ghost_poll_prompt: FeatureChoiced = {
  name: 'Оповещения призрака',
  category: 'Звук',
  description: 'Выберите какой звук будет при оповещении, когда вы призрак.',
  component: FeatureDropdownInput,
};

export const sound_ghost_poll_prompt_volume: Feature<number> = {
  name: 'Оповещения призрака - громкость',
  category: 'Звук',
  description: 'Звук оповещенией призрака.',
  component: FeatureSliderInput,
};

export const sound_combatmode: FeatureToggle = {
  name: 'Включить звук режима боя',
  category: 'Звук',
  description: 'Играть звук при переключении режима боя.',
  component: CheckboxInput,
};

export const sound_instruments: Feature<number> = {
  name: 'Включить звук музыкальных инструментов',
  category: 'Звук',
  description: 'Играть звук музыкальных инструментов.',
  component: FeatureSliderInput,
};

export const sound_jukebox: Feature<number> = {
  name: 'Громкость музыкальных автоматов',
  category: 'Звук',
  description: 'Громкость треков в музыкальных автоматах.',
  component: FeatureSliderInput,
};

export const sound_tts: FeatureChoiced = {
  name: 'TTS - включить',
  category: 'Звук',
  description: `
    Играть звук text-to-speech.
    Функция "Blips" не работает.
  `,
  component: FeatureDropdownInput,
};

export const sound_tts_radio: FeatureChoiced = {
  name: 'Enable TTS Over Radio',
  category: 'SOUND',
  description: `
    When enabled, be able to hear text-to-speech sounds in game over radio channels.
    When set to "Departmental Radio Only", text to speech over the radio will only play for departmental radio channels. Anything that isn't Common.
    When disabled, text to speech will not play over radio sources.
  `,
  component: FeatureDropdownInput,
};

export const sound_tts_hear_self_radio: FeatureToggle = {
  name: 'Enable TTS Hear Self Over Radio',
  category: 'SOUND',
  description: 'When enabled, hear yourself over the radio when Text to Speech and TTS Over Radio is enabled.',
  component: CheckboxInput,
};

export const sound_tts_volume: Feature<number> = {
  name: 'TTS - громкость',
  category: 'Звук',
  description: 'Громкость text-to-speech.',
  component: FeatureSliderInput,
};

export const sound_tts_volume_radio: Feature<number> = {
  name: 'TTS - громкость рации',
  category: 'Звук',
  description: 'Громкость text-to-speech для рации.',
  component: FeatureSliderInput,
};

export const sound_tts_volume_announcement: Feature<number> = {
  name: 'TTS - громкость оповещений',
  category: 'Звук',
  description: 'Громкость text-to-speech для оповещений.',
  component: FeatureSliderInput,
};

export const sound_tts_volume_telepathy: Feature<number> = {
  name: 'TTS - громкость телепатической речи',
  category: 'Звук',
  description: 'Громкость text-to-speech для телепатии (хайвмайнд генокрадов, телепатия ревенанта и тд).',
  component: FeatureSliderInput,
};

export const sound_tts_radio_volume: Feature<number> = {
  name: 'TTS Radio Volume',
  category: 'SOUND',
  description: 'The volume that radio text-to-speech sounds will play at. This is independent of regular TTS volume.',
  component: FeatureSliderInput,
};

export const sound_lobby_volume: Feature<number> = {
  name: 'Громкость музыки в лобби',
  category: 'Звук',
  component: FeatureSliderInput,
};

export const sound_midi: Feature<number> = {
  name: 'Громкость админской музыки',
  category: 'Звук',
  description: 'Громкость музыки, запускаемой администрацией.',
  component: FeatureSliderInput,
};

export const sound_ship_ambience_volume: Feature<number> = {
  name: 'Громкость звуков корабля',
  category: 'Звук',
  description: `Зацикленный звук окружения корабля (низкий гул).`,
  component: FeatureSliderInput,
};

export const sound_achievement: FeatureChoiced = {
  name: 'Звук при получении достижений',
  category: 'Звук',
  description: `
    Выбор звука, который будет играть при получении достижения.
    При отключении звука не будет.
  `,
  component: FeatureDropdownInput,
};

export const sound_radio_noise: Feature<number> = {
  name: 'Громкость оповещения рации',
  category: 'Звук',
  description: `Громкость оповещений, когда в рацию кто-то говорит.`,
  component: FeatureSliderInput,
};

export const sound_ai_vox: Feature<number> = {
  name: 'Громкость оповещения VOX ИИ',
  category: 'Звук',
  description: 'Громкость вокальных оповещений ИИ (также известных как "VOX").',
  component: FeatureSliderInput,
};
