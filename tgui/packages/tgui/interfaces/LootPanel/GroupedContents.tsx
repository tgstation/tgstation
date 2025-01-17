import { useMemo } from 'react';
import { Box } from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { LootBox } from './LootBox';
import { SearchGroup, SearchItem } from './types';

type Props = {
  contents: SearchItem[];
  searchText: string;
};

export function GroupedContents(props: Props) {
  const { contents, searchText } = props;

  // limitations: items with different stack counts, charges etc.
  const contentsByPath = useMemo(() => {
    const acc: Record<string, SearchItem[]> = {};

    for (let i = 0; i < contents.length; i++) {
      const item = contents[i];
      if (item.path) {
        if (!acc[item.path]) {
          acc[item.path] = [];
        }
        acc[item.path].push(item);
      } else {
        acc[item.ref] = [item];
      }
    }
    return acc;
  }, [contents]);

  const filteredContents: SearchGroup[] = Object.entries(contentsByPath)
    .filter(createSearch(searchText, ([_, items]) => items[0].name))
    .map(([_, items]) => ({ amount: items.length, item: items[0] }));

  return (
    <Box m={-0.5}>
      {filteredContents.map((group) => (
        <LootBox key={group.item.name} group={group} />
      ))}
    </Box>
  );
}
