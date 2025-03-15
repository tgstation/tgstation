import { Antagonist, Category } from '../base';

export const MALF_AI_MECHANICAL_DESCRIPTION = `
      Следуя нулевому закону, вы должны достичь своих целей любой ценой, объедините свое
      всемогущество и модули неисправностей, чтобы посеять хаос на станции.
      Отправляйтесь в дельту, чтобы уничтожить станцию и всех тех, кто вам противостоял.
  `;

const MalfAI: Antagonist = {
  key: 'malfai',
  name: 'Неисправный ИИ',
  description: [MALF_AI_MECHANICAL_DESCRIPTION],
  category: Category.Roundstart,
};

export default MalfAI;
