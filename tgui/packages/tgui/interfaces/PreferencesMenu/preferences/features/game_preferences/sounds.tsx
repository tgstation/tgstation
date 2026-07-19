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
  name: 'TTS - Включить поверх радио',
  category: 'Звук',
  description: `
    Когда включено, вы будете слышать text-to-speech звуки в игре поверх радио каналов.
    Когда режим выставлен в "Только радио отделов", text-to-speech звуки поверх радио будут слышны только для каналов отделов, и любых частот которые не являются Общей.
    Когда выключено, text-to-speech не будет слышно поверх радио.
  `,
  component: FeatureDropdownInput,
};

export const sound_tts_hear_self_radio: FeatureToggle = {
  name: 'TTS - слышать себя в рации',
  category: 'Звук',
  description:
    'Когда включено, вы будете слышать себя в рации когда говорите в неё.',
  component: CheckboxInput,
};

export const sound_tts_volume: Feature<number> = {
  name: 'TTS - громкость',
  category: 'Звук',
  description: 'Громкость text-to-speech.',
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
  name: 'TTS - громкость рации',
  category: 'Звук',
  description:
    'Громкость text-to-speech для рации. Громкость независима от обычной громкости text-to-speech.',
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
