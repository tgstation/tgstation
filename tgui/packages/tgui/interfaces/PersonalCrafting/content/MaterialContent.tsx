import { useBackend } from 'tgui/backend';
import { Box, Stack } from 'tgui-core/components';

import { findIcon } from '../helpers';
import type { CraftingData } from '../types';

type Props = {
  atom_id: string;
  occurences: number;
};

export function MaterialContent(props: Props) {
  const { occurences } = props;
  const { data } = useBackend<CraftingData>();

  const atom_id = Number(props.atom_id);
  const name = data.atom_data[atom_id - 1].name;
  const icon = findIcon(atom_id, data);

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
