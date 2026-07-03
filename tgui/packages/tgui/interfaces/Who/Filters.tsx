import { Button, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { SearchBar } from '../common/SearchBar';
import { sortTypes } from './constants';
import type { WhoData } from './types';

export function Filters(props) {
  const { act, data } = useBackend<WhoData>();
  const { sortType, setSortType, searchText, setSearchText } = props;

  return (
    <Stack vertical>
      <Stack.Item>
        <SearchBar
          query={searchText}
          onSearch={(value) => setSearchText(value)}
        />
      </Stack.Item>
      {!!data.user.admin && (
        <Stack.Item textAlign="center">
          <Stack fill>
            {Object.keys(sortTypes).map((type) => (
              <Stack.Item key={type} width="100%">
                <Button
                  fluid
                  color="transparent"
                  selected={sortType === type}
                  onClick={() => setSortType(type)}
                >
                  {type}
                </Button>
              </Stack.Item>
            ))}
          </Stack>
        </Stack.Item>
      )}
    </Stack>
  );
}
