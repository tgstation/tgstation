import { type Antagonist, Category } from '../base';
import { OPERATIVE_MECHANICAL_DESCRIPTION } from './operative';

const ClownOperative: Antagonist = {
  key: 'clownoperative',
  name: 'Клоунский оперативник',
  description: [
    `
      Хонк! Вы были выбраны, к лучшему или худшему, в Синдикатовскую ударную группу
      клоунов. Ваша миссия, вне зависимости от ваших щекоток,
      заключается в отхонкивании самого передового исследовательского центра Нанотрейзен!
      Правильно, вы отправитесь на клоунскую станцию 13.
    `,

    OPERATIVE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default ClownOperative;
