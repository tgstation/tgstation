import { CSSProperties } from 'react';
import { Icon, Input, Stack } from 'tgui-core/components';

type RequiredProps = {
  /** The state variable. */
  query: string;
  /** The function to call when the user searches. */
  onSearch: (query: string) => void;
};

type OptionalProps = Partial<{
  /** Whether the input should be focused on mount. */
  autoFocus: boolean;
  /** Whether to show the search icon. */
  noIcon: boolean;
  /** The placeholder text. */
  placeholder: string;
  /** Override styles of the search bar. */
  style: CSSProperties;
}>;

type Props = RequiredProps & OptionalProps;

/**
 * Simple component for searching.
 * This component does not accept box props - just recreate it if needed
 */
export function SearchBar(props: Props) {
  const {
    autoFocus,
    noIcon = false,
    onSearch,
    placeholder = 'Search...',
    query = '',
    style,
  } = props;

  return (
    <Stack fill style={style}>
      <Stack.Item align="center">
        {!noIcon && <Icon name="search" />}
      </Stack.Item>
      <Stack.Item grow>
        <Input
          autoFocus={autoFocus}
          expensive
          fluid
          onChange={onSearch}
          placeholder={placeholder}
          value={query}
        />
      </Stack.Item>
    </Stack>
  );
}
