import { Box } from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { LootBox } from './LootBox';
import type { SearchItem } from './types';

type Props = {
  contents: SearchItem[];
  searchText: string;
};

export function RawContents(props: Props) {
  const { contents, searchText } = props;

  const filteredContents = contents.filter(
    createSearch(searchText, (item: SearchItem) => item.name),
  );

  return (
    <Box m={-0.5}>
      {filteredContents.map((item) => (
        <LootBox key={item.ref} item={item} />
      ))}
    </Box>
  );
}
