import { Antagonist, Category } from '../base';

const SentientCreature: Antagonist = {
  key: 'sentiencepotionspawn',
  name: 'Разумное существо',
  description: [
    `
      То ли по космической случайности, то ли из-за махинаций экипажа, вы
      обрели разум!
	  `,

    `
      Это общее предпочтение. К более безобидным относятся случайные человеческие
      повышайте уровень интеллекта, каргориллу и существ, улучшенных с помощью
      зелий чувствительности. К менее дружелюбным относятся королевская крыса и усиленные
      элитные мобы-шахтеры.
	  `,
  ],
  category: Category.Midround,
};

export default SentientCreature;
