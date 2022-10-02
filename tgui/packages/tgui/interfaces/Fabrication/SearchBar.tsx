import { Stack, Input, Icon } from '../../components';

/**
 * The properties of a search bar.
 */
export type SearchBarProps = {
  /**
   * The hint displayed in the search bar when it is empty.
   */
  hint?: string;

  /**
   * The currently set search text.
   */
  searchText: string;

  /**
   * Invoked whenever the search text is changed by the user.
   */
  onSearchTextChanged: (newSearchText: string) => void;
};

/**
 * A simple, stylized search bar.
 */
export const SearchBar = (props: SearchBarProps, context) => {
  const { searchText, onSearchTextChanged, hint } = props;

  return (
    <Stack align="baseline">
      <Stack.Item>
        <Icon name="search" />
      </Stack.Item>
      <Stack.Item grow>
        <Input
          fluid
          placeholder={hint ? hint : 'Search for...'}
          onInput={(_e: unknown, v: string) => onSearchTextChanged(v)}
          value={searchText}
        />
      </Stack.Item>
    </Stack>
  );
};
