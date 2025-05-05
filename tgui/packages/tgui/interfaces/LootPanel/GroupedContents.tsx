import { Box } from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { LootBox } from './LootBox';
import { SearchGroup, SearchItem } from './types';

type Props = {
  contents: Record<string, SearchItem[]>;
  searchText: string;
};

export function GroupedContents(props: Props) {
  const { contents, searchText } = props;

  const filteredContents: SearchGroup[] = Object.entries(contents)
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
