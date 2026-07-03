import { type Antagonist, Category } from '../base';

const SentientCreature: Antagonist = {
  key: 'sentiencepotionspawn',
  name: 'Разумное существо',
  description: [
    `
        Либо по космической случайности, либо из-за махинаций экипажа,
        вы получили разум!
	  `,

    `
        Это универсальное предпочтение. К более дружелюбным относятся случайные события,
        связанные с интеллектом человеческого уровня, каргорилла и существа,
        поднятые с помощью зелий разумности. К менее дружелюбным относятся
        крысиный король и усиленные шахтерские элитные мобы.
	  `,
  ],
  category: Category.Midround,
};

export default SentientCreature;
