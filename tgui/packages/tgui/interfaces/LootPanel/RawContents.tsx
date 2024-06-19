import { createSearch } from 'common/string';

import { Flex } from '../../components';
import { LootBox } from './LootBox';
import { SearchItem } from './types';

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
    <Flex wrap>
      {filteredContents.map((item) => (
        <Flex.Item key={item.ref} m={1}>
          <LootBox item={item} />
        </Flex.Item>
      ))}
    </Flex>
  );
}
