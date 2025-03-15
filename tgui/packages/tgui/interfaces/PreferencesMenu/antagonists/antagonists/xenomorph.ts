import { Antagonist, Category } from '../base';

const Xenomorph: Antagonist = {
  key: 'xenomorph',
  name: 'Чужой',
  description: [
    `
      Станьте инопланетным ксеноморфом. Начните с личинки и продвигайтесь по
      карьерной лестнице, вплоть до королевы!
    `,
  ],
  category: Category.Midround,
};

export default Xenomorph;
