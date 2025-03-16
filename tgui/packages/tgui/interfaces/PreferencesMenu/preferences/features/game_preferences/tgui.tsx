import { CheckboxInput, Feature, FeatureToggle } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const tgui_fancy: FeatureToggle = {
  name: 'Включить необычный TGUI',
  category: 'Интерфейс',
  description: 'Позволяет TGUI окну выглядеть лучше за счет совместимости.',
  component: CheckboxInput,
};

export const tgui_input: FeatureToggle = {
  name: 'Ввод: Включить TGUI',
  category: 'Интерфейс',
  description: 'Визуализирует поля ввода в TGUI.',
  component: CheckboxInput,
};

export const tgui_input_large: FeatureToggle = {
  name: 'Ввод: Кнопки большего размера',
  category: 'Интерфейс',
  description:
    'Делает кнопки TGUI менее традиционными и более функциональными.',
  component: CheckboxInput,
};

export const tgui_input_swapped: FeatureToggle = {
  name: 'Ввод: Поменять местами кнопки отправки/отмены',
  category: 'Интерфейс',
  description:
    'Делает кнопки TGUI менее традиционными и более функциональными.',
  component: CheckboxInput,
};

export const tgui_layout: Feature<string> = {
  name: 'Макет TGUI по умолчанию',
  category: 'Интерфейс',
  description:
    'Применяет выбранный тип компоновки ко всем интерфейсам, где это возможно. Как в Smartfridge.',
  component: FeatureDropdownInput,
};

export const tgui_lock: FeatureToggle = {
  name: 'Привязать TGUI к главному монитору',
  category: 'Интерфейс',
  description: 'Блокирует доступ TGUI окна к вашему основному монитору.',
  component: CheckboxInput,
};

export const tgui_say_light_mode: FeatureToggle = {
  name: 'Стиль окошка Say',
  category: 'Интерфейс',
  description: 'Настраивает TGUI Say на использование упрощённого режима.',
  component: CheckboxInput,
};
