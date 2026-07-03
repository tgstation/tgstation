import { type Antagonist, Category } from '../base';

export const BLOB_MECHANICAL_DESCRIPTION = `
  Блоб заражает станцию и уничтожает все на своем пути, включая корпус,
  основание станции и существ. Распространяйте свою массу, собирайте ресурсы
  и поглотите всю станцию. Не забудьте подготовить оборону, потому что экипаж
  будет предупрежден о вашем присутствии!
`;

const Blob: Antagonist = {
  key: 'blob',
  name: 'Блоб',
  description: [BLOB_MECHANICAL_DESCRIPTION],
  category: Category.Midround,
};

export default Blob;
