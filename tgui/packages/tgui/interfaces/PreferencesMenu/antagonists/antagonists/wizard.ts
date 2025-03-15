import { Antagonist, Category } from '../base';

export const WIZARD_MECHANICAL_DESCRIPTION = `
      Выбирайте между различными могущественными заклинаниями, чтобы посеять хаос
      на Космической станции 13.
    `;

const Wizard: Antagonist = {
  key: 'wizard',
  name: 'Маг',
  description: [
    `"ПРИВЕТСТВУЕМ. МЫ - ВОЛШЕБНИКИ ИЗ ФЕДЕРАЦИИ ВОЛШЕБНИКОВ."`,
    WIZARD_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Wizard;
