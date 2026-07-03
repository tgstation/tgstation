import { type Antagonist, Category } from '../base';

const Xenomorph: Antagonist = {
  key: 'xenomorph',
  name: 'Ксеноморф',
  description: [
    `
      Станьте внеземным ксеноморфом. Начните как ларва и продвигайтесь
      по касте, вплоть до Королевы!
    `,
  ],
  category: Category.Midround,
};

export default Xenomorph;
