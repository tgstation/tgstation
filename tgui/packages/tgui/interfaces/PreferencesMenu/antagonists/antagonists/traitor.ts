import { type Antagonist, Category } from '../base';

export const TRAITOR_MECHANICAL_DESCRIPTION = `
      Начните с аплинком, чтобы приобрести снаряжение и приступить к
      выполнению своих зловещих задач. Поднимитесь по карьерной лестнице
      и станьте печально известной легендой.
   `;

const Traitor: Antagonist = {
  key: 'traitor',
  name: 'Предатель',
  description: [
    `
      Неоплаченный долг. Счеты, которые нужно свести. Может быть,
      вы просто оказались не в том месте и не в то время. Каковы бы ни были
      причины, вы были выбраны для проникновения на космическую станцию 13.
    `,
    TRAITOR_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
  priority: -1,
};

export default Traitor;
