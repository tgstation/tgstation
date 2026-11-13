import { useBackend } from 'tgui/backend';
import { Box, Stack } from 'tgui-core/components';

import { findIcon } from '../helpers';
import type { AtomData, CraftingData, IconData } from '../types';

type Props = {
  atom_id: string;
  occurences: number;
  iconData: IconData;
  atomData: AtomData[];
};

export function MaterialContent(props: Props) {
  const { occurences, iconData } = props;
  const { data } = useBackend<CraftingData>();

  const atom_id = Number(props.atom_id);
  const name = props.atomData[atom_id - 1].name;
  const icon = findIcon(atom_id, data, iconData);

  return (
    <Stack>
      <Stack.Item>
        <Box
          verticalAlign="middle"
          inline
          ml={-1.5}
          mr={-0.5}
          className={icon}
        />
      </Stack.Item>
      <Stack.Item
        height="32px"
        lineHeight="32px"
        grow
        style={{
          textTransform: 'capitalize',
          overflow: 'hidden',
          textOverflow: 'ellipsis',
          whiteSpace: 'nowrap',
        }}
      >
        {name}
      </Stack.Item>
      <Stack.Item height="32px" lineHeight="32px">
        {occurences}
      </Stack.Item>
    </Stack>
  );
}
