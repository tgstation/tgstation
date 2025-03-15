import { Antagonist, Category } from '../base';

export const OPERATIVE_MECHANICAL_DESCRIPTION = `
  Достаньте диск с ядерной идентификацией, используйте его для активации
  ядерногой боеголовки и уничтожьте станцию.
`;

const Operative: Antagonist = {
  key: 'operative',
  name: 'Ядерный оперативник',
  description: [
    `
      Поздравляем, агент. Вы были выбраны для вступления в Синдикат -
      Оперативная ядерная ударная группа. Ваша миссия, хотите вы того или нет,
      заключается в уничтожении самого передового исследовательского центра Нанотразена!
      Все верно, вы отправляетесь на космическую станцию 13.
    `,

    OPERATIVE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Operative;
