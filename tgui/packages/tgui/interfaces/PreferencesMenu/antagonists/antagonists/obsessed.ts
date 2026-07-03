import { type Antagonist, Category } from '../base';

const Obsessed: Antagonist = {
  key: 'obsessed',
  name: 'Одержимый',
  description: [
    `
    Вы кем-то одержимы! Ваша цель одержимости может начать замечать,
    что их личные вещи были украдены, а коллеги пропали,
    но поймут ли они вовремя, что она - ваша следующая жертва?
    `,
  ],
  category: Category.Midround,
};

export default Obsessed;
