import { Antagonist, Category } from '../base';

const Bloodsucker: Antagonist = {
  key: 'bloodsucker',
  name: 'Bloodsucker',
  description: [
    `
      После смерти вы просыпаетесь и чуствуете себя монстром-нежитью.
      Используйте свои вампирские способности как можно лучше.
      Очистите Космическую Cтанцию 13 или захватите ее, подчиняя себе экипаж.
    `,
  ],
  category: Category.Roundstart,
};

export default Bloodsucker;
