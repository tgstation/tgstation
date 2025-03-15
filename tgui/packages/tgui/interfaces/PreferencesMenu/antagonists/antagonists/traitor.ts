import { Antagonist, Category } from '../base';

export const TRAITOR_MECHANICAL_DESCRIPTION = `
      Начните с аплинка, чтобы приобрести снаряжение и приступить к выполнению своих зловещих
      задач. Продвигайтесь по служебной лестнице и станьте печально известной легендой.
  `;

const Traitor: Antagonist = {
  key: 'traitor',
  name: 'Тайный агент Синдиката',
  description: [
    `
      Неоплаченный долг. Нужно свести счеты. Возможно, вы просто оказались не в том
      месте и не в то время. Каковы бы ни были причины, вас выбрали для
      проникновения на космическую станцию 13.
    `,
    TRAITOR_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
  priority: -1,
};

export default Traitor;
