import { Box } from 'tgui-core/components';

import { LootBox } from './LootBox';
import { SearchItem } from './types';

type Props = {
  contents: SearchItem[];
};

export function RawContents(props: Props) {
  const { contents } = props;

  return (
    <Box m={-0.5}>
      {contents.map((item) => (
        <LootBox key={item.ref} item={item} />
      ))}
    </Box>
  );
}
