import { Antagonist, Category } from '../base';
import { REVOLUTIONARY_MECHANICAL_DESCRIPTION } from './headrevolutionary';

const Provocateur: Antagonist = {
  key: 'provocateur',
  name: 'Революционер',
  description: [
    `
      Революционная форма головы, которая может быть активирована при присоединении к текущей
      смене.
    `,

    REVOLUTIONARY_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Latejoin,
};

export default Provocateur;
