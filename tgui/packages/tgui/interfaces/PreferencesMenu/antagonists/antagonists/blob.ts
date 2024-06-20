import { Antagonist, Category } from '../base';

export const BLOB_MECHANICAL_DESCRIPTION = `
  The blob infests the station and destroys everything in its path, including
  hull, fixtures, and creatures. Spread your mass, collect resources, and
  consume the entire station. Make sure to prepare your defenses, because the
  crew will be alerted to your presence!
`;

const Blob: Antagonist = {
  key: 'blob',
  name: 'Blob',
  description: [BLOB_MECHANICAL_DESCRIPTION],
  category: Category.Midround,
};

export default Blob;
