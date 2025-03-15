import { Antagonist, Category } from '../base';
import { OPERATIVE_MECHANICAL_DESCRIPTION } from './operative';

const ClownOperative: Antagonist = {
  key: 'clownoperative',
  name: 'Бананоопер',
  description: [
    `
      Хонк! К добру это или к худу, но вы были выбраны для участия в Синдикате
      Ударная команда клоунов-оперативников. Ваша миссия, хотите вы этого или нет,
      состоит в том, чтобы вывести из строя самый передовой исследовательский центр Nanotrasen!
      Правильно, ты идешь на клоунскую станцию №13.
      И помните, ни слова про Арматурова.
    `,

    OPERATIVE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default ClownOperative;
