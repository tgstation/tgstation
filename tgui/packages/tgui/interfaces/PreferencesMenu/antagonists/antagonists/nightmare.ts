import { type Antagonist, Category } from '../base';

const Nightmare: Antagonist = {
  key: 'nightmare',
  name: 'Кошмар',
  description: [
    `
      Используйте свой клинок для уничтожения источников света,
      чтобы жить и процветать во тьме. Пробирайтесь сквозь тьму и
      ищите добычу с помощью ночного зрения.
    `,
  ],
  category: Category.Midround,
};

export default Nightmare;
