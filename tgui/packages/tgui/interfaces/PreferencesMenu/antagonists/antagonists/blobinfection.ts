import { Antagonist, Category } from '../base';
import { BLOB_MECHANICAL_DESCRIPTION } from './blob';

const BlobInfection: Antagonist = {
  key: 'blobinfection',
  name: 'Инфицированный Блобом',
  description: [
    `
      В любой момент в середине смены вас может поразить инфекция,
      которая превратит вас в ужасающую каплю.
    `,
    BLOB_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default BlobInfection;
