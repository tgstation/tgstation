import { useBackend } from 'tgui/backend';
import { Box } from 'tgui-core/components';

import { findIcon } from '../helpers';
import type { CraftingData } from '../types';

type Props = {
  amount: number;
  atom_id: string;
};

export function AtomContent(props: Props) {
  const { amount } = props;
  const { data } = useBackend<CraftingData>();

  const atom_id = Number(props.atom_id);
  const atom = data.atom_data[atom_id - 1];

  return (
    <Box my={1}>
      <Box
        verticalAlign="middle"
        inline
        my={-1}
        mr={0.5}
        className={findIcon(atom_id, data)}
      />
      <Box inline verticalAlign="middle">
        {atom.name}
        {atom.is_reagent ? `\xa0${amount}u` : amount > 1 && `\xa0${amount}x`}
      </Box>
    </Box>
  );
}
