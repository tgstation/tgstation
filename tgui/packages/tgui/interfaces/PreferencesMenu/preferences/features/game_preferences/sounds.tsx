import {
  CheckboxInput,
  Feature,
  FeatureChoiced,
  FeatureSliderInput,
  FeatureToggle,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const sound_ambience_volume: Feature<number> = {
  name: 'Эмбиент',
  category: 'Звук',
  description: `Эмбиент относится к более заметным окружающим звукам, которые время от времени воспроизводятся.`,
  component: FeatureSliderInput,
};

export const sound_breathing: FeatureToggle = {
  name: 'Включите звуки дыхания',
  category: 'Звук',
  description:
    'Если этот параметр включен, при использовании внутренних устройств будут слышны звуки дыхания.',
  component: CheckboxInput,
};

export const sound_announcements: FeatureToggle = {
  name: 'Включить звук объявления',
  category: 'Звук',
  description:
    'Когда эта функция включена, вы можете слышать звуковые сигналы для командных отчетов, уведомлений и т.д.',
  component: CheckboxInput,
};

export const sound_ghost_poll_prompt: FeatureChoiced = {
  name: 'Призрачный опрос',
  category: 'Звук',
  description:
    'Выберите, какую звуковую подсказку воспроизводить при получении призрачных опросов.',
  component: FeatureDropdownInput,
};

export const sound_ghost_poll_prompt_volume: Feature<number> = {
  name: 'Громкость звка на призрачный опрос',
  category: 'Звук',
  description:
    'Громкость, на которой будут воспроизводиться подсказки Призрачный опрос.',
  component: FeatureSliderInput,
};

export const sound_combatmode: FeatureToggle = {
  name: 'Включить звук боевого режима',
  category: 'Звук',
  description: 'При включении слышны звуки при переключении боевого режима.',
  component: CheckboxInput,
};

export const sound_instruments: Feature<number> = {
  name: 'Объем инструментов',
  category: 'Звук',
  description: 'Количество инструментов.',
  component: FeatureSliderInput,
};

export const sound_tts: FeatureChoiced = {
  name: 'ТТС',
  category: 'Звук',
  description: `
    Если эта функция включена, вы сможете слышать звуки преобразования текста в речь в игре.
    Если установить значение "Мгновенные сигналы", преобразование текста в речь будет заменено мгновенными звуками, основанными на голосе.
  `,
  component: FeatureDropdownInput,
};

export const sound_tts_volume: Feature<number> = {
  name: 'Громкость ТТС',
  category: 'Звук',
  description:
    'Громкость, с которой будут воспроизводиться звуки преобразования текста в речь.',
  component: FeatureSliderInput,
};

export const sound_lobby_volume: Feature<number> = {
  name: 'Громкость музыки в лобби',
  category: 'Звук',
  component: FeatureSliderInput,
};

export const sound_midi: Feature<number> = {
  name: 'Громкость мызыки админа',
  category: 'Звук',
  description: 'Громкость музыки администратора.',
  component: FeatureSliderInput,
};

export const sound_ship_ambience_volume: Feature<number> = {
  name: 'Громкость эмбиента на станции',
  category: 'Звук',
  description: `Станционная атмосфера - это низкий окружающий гул, который звучит в цикле.`,
  component: FeatureSliderInput,
};

export const sound_achievement: FeatureChoiced = {
  name: 'Звук выполнения Достижение',
  category: 'Звук',
  description: `
    Звук, который воспроизводится при разблокировке достижения.
    Если он отключен, звук воспроизводиться не будет.
  `,
  component: FeatureDropdownInput,
};

export const sound_radio_noise: Feature<number> = {
  name: 'Громкость радио',
  category: 'Звук',
  description: `Громкость разговоров и звуков радиопереговоров.`,
  component: FeatureSliderInput,
};

export const sound_ai_vox: Feature<number> = {
  name: 'Громкость объявлений ИИ',
  category: 'Звук',
  description: 'Громкость голосовых объявлений искусственного интеллекта.',
  component: FeatureSliderInput,
};
