import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';

const ClockCultist: Antagonist = {
  key: 'clockcultist',
  name: 'Clock Cultist',
  description: [
    multiline`
      You are one of the last remaining servants of
      Rat'var, The Clockwork Justicar.
      After a long and destructive war, Rat'Var was imprisoned
      inside a dimension of suffering.
      You must free him by protecting The Ark so that his light may
      shine again.
    `,

    multiline`
      Gather power by putting Integration Cogs inside APCs
      and fortify Reebe and The Ark aganist the crew's assault
      long enough for it to open.
    `,
  ],
  category: Category.Roundstart,
};

export default ClockCultist;
