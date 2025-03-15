import { Antagonist, Category } from '../base';

const BloodBrother: Antagonist = {
  key: 'bloodbrother',
  name: 'Кровный брат',
  description: [
    `
      Объединяйтесь с другими членами экипажа как кровные братья, чтобы объединить сильные
      стороны ваших подразделений, вызволить друг друга из тюрьмы и захватить
      станцию.
    `,
  ],
  category: Category.Roundstart,
};

export default BloodBrother;
