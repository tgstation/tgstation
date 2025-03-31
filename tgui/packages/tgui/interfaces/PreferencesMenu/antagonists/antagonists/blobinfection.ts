import { Antagonist, Category } from '../base';
import { BLOB_MECHANICAL_DESCRIPTION } from './blob';

const BlobInfection: Antagonist = {
  key: 'blobinfection',
  name: 'Blob Infection',
  description: [
    `
      At any point in the middle of the shift, be strucken with an infection
      that will turn you into the terrifying blob.
    `,
    BLOB_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default BlobInfection;
