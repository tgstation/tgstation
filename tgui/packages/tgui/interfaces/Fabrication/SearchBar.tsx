import { Component } from 'inferno';
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

export class SearchBar extends Component<SearchBarProps> {
  timeout?: NodeJS.Timeout;

  onInput(value: string) {
    if (this.timeout) {
      clearTimeout(this.timeout);
    }

    this.timeout = setTimeout(() => this.props.onSearchTextChanged(value), 200);
  }

  render() {
    const { searchText, hint } = this.props;

    return (
      <Stack align="baseline">
        <Stack.Item>
          <Icon name="search" />
        </Stack.Item>
        <Stack.Item grow>
          <Input
            fluid
            placeholder={hint ? hint : 'Search for...'}
            onInput={(_e: unknown, v: string) => this.onInput(v)}
            value={searchText}
          />
        </Stack.Item>
      </Stack>
    );
  }
}
