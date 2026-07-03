import { CheckboxInput, type FeatureToggle } from '../base';

export const tgui_fancy: FeatureToggle = {
  name: 'Включить красивый TGUI',
  category: 'Интерфейс',
  description: 'Окна TGUI будут выглядеть лучше, ценой совместимости.',
  component: CheckboxInput,
};

export const tgui_input: FeatureToggle = {
  name: 'Ввод - Включить TGUI',
  category: 'Интерфейс',
  description: 'Заменяет стандартный ввод, такой как выбор из списка.',
  component: CheckboxInput,
};

export const tgui_input_large: FeatureToggle = {
  name: 'Ввод - Большие кнопки',
  category: 'Интерфейс',
  description: 'Делает кнопки в окнах ввода TGUI большими.',
  component: CheckboxInput,
};

export const tgui_input_swapped: FeatureToggle = {
  name: 'Ввод - Поменять местами кнопки',
  category: 'Интерфейс',
  description: 'Менее традиционные кнопки в окнах ввода TGUI.',
  component: CheckboxInput,
};

export const tgui_lock: FeatureToggle = {
  name: 'TGUI - Только на главном дисплее',
  category: 'Интерфейс',
  description: 'Блокирует местоположение TGUI на главном дисплее.',
  component: CheckboxInput,
};

export const ui_scale: FeatureToggle = {
  name: 'TGUI - Масштабирование интерфейсов',
  category: 'Интерфейс',
  description: 'Должны ли интерфейсы масштабироваться под масштаб в системе?',
  component: CheckboxInput,
};

export const tgui_say_light_mode: FeatureToggle = {
  name: 'Окно общения - Светлый режим',
  category: 'Интерфейс',
  description: 'Если включено, поле ввода для разговора будет в светлой теме.',
  component: CheckboxInput,
};
