import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

export const NTA_MECHANICAL_DESCRIPTION = multiline`
      Sen bir Nanotrasen ajanısın. Amacın istasyonda bir tehlike söz konusu
      olursa o tehlikenin peşine düşmektir. Onun dışında istasyonda mesleğini
      yerine getirmek zorundasın.
	    Eğer üstünde olmaması gereken bir şey ile security e yakalanırsan asla
      ve asla Nanotrasen ajanı olduğunu söylememelisin.
	    Unutma ajan, ölmekte görevinin bir parçası.
    `;

const NTAgent: Antagonist = {
  key: 'ntagent',
  name: 'NT Agent',
  description: [`Nanotrasene calisiyorsun.`, NTA_MECHANICAL_DESCRIPTION],
  category: Category.Roundstart,
};

export default NTAgent;
