import { Antagonist, Category } from '../base';

const Obsessed: Antagonist = {
  key: 'obsessed',
  name: 'Одержимый',
  description: [
    `
      Вы одержимы кем-то! Ваши одержимые могут начать замечать, что у них
      крадут личные вещи, а их коллеги пропадают без вести,
      но поймут ли они вовремя, что они - ваша следующая жертва?
    `,
  ],
  category: Category.Midround,
};

export default Obsessed;
