import { type Antagonist, Category } from '../base';

export const MALF_AI_MECHANICAL_DESCRIPTION = `
    Имея нулевой закон, гласящий выполнить свои задачи любой ценой, объедините
    свое всемогущество с модулями сбойного ИИ, чтобы посеять хаос на всей станции.
    Активируйте код Дельта, чтобы уничтожить станцию и всех, кто вам противостоит.
  `;

const MalfAI: Antagonist = {
  key: 'malfai',
  name: 'Сбойный ИИ',
  description: [MALF_AI_MECHANICAL_DESCRIPTION],
  category: Category.Roundstart,
};

export default MalfAI;
