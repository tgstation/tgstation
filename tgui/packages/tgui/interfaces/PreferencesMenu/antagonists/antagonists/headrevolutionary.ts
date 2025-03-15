import { Antagonist, Category } from '../base';

export const REVOLUTIONARY_MECHANICAL_DESCRIPTION = `
      Вооружившись вспышкой, привлеките к революции как можно больше людей.
      Убейте или изгоните всех руководителей станции. Смерть корпаратам!
  `;

const HeadRevolutionary: Antagonist = {
  key: 'headrevolutionary',
  name: 'Главный революционер',
  description: [
    'ДА ЗДРАВСТВУЕТ РЕВОЛЮЦИЯ!',
    REVOLUTIONARY_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default HeadRevolutionary;
