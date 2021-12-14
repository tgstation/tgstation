import { Loader } from './common/Loader';
import { InputButtons, Preferences, Validator } from './common/InputButtons';
import { Button, Input, Section, Stack } from '../components';
import { KEY_ENTER, KEY_DOWN, KEY_UP } from 'common/keycodes';
import { Window } from '../layouts';
import { useBackend, useSharedState } from '../backend';

type ListInputData = {
  items: string[];
  message: string;
  preferences: Preferences;
  timeout: number;
  title: string;
};

export const ListInputModal = (_, context) => {
  const { act, data } = useBackend<ListInputData>(context);
  const { items = [], message, preferences, title, timeout } = data;
  const { large_buttons } = preferences;
  const [selected, setSelected] = useSharedState<string | null>(
    context,
    'input',
    null
  );
  const [searchBarVisible, setSearchBarVisible] = useSharedState<boolean>(
    context,
    'searchBarVisible',
    items.length > 9
  );
  const [searchQuery, setSearchQuery] = useSharedState<string>(
    context,
    'searchQuery',
    ''
  );
  const [inputIsValid, setInputIsValid] = useSharedState<Validator>(
    context,
    'inputIsValid',
    { isValid: true, error: null }
  );
  const onArrowKey = (key: any) => {
    if (key === KEY_DOWN) {
      if (selected === null) {
        setSelected(items[0]);
      } else {
        setSelected(items[(items.indexOf(selected) + 1) % items.length]);
      }
    } else if (key === KEY_UP) {
      if (selected === null) {
        setSelected(items[items.length - 1]);
      } else {
        setSelected(
          items[(items.indexOf(selected) - 1 + items.length) % items.length]
        );
      }
    }
  };
  const onClick = (item: string) => {
    if (item === undefined || item === selected) {
      setInputIsValid({ isValid: false, error: 'No selection' });
      setSelected(null);
    } else {
      setInputIsValid({ isValid: true, error: null });
      setSelected(item);
    }
  };
  const onSearch = (query: string) => {
    setSearchQuery(query);
  };
  const onSearchBarToggle = () => {
    setSearchBarVisible(!searchBarVisible);
    setSearchQuery('');
  };

  return (
    <Window title={title} width={325} height={325 + (large_buttons ? 5 : 0)}>
      {timeout && <Loader value={timeout} />}
      <Window.Content
        onKeyDown={(event) => {
          const keyCode = window.event ? event.which : event.keyCode;
          if (keyCode === KEY_ENTER && inputIsValid.isValid) {
            act('submit', { entry: selected });
          }
          if (keyCode === KEY_DOWN || keyCode === KEY_UP) {
            onArrowKey(keyCode);
          }
        }}>
        <Section
          buttons={
            <Button
              compact
              icon="search"
              color="transparent"
              selected={searchBarVisible}
              tooltip="Search Bar"
              tooltipPosition="left"
              onClick={() => onSearchBarToggle()}
            />
          }
          fill
          title={message}>
          <Stack fill vertical>
            <Stack.Item grow>
              <ListDisplay
                onClick={onClick}
                searchQuery={searchQuery}
                selected={selected}
              />
            </Stack.Item>
            {searchBarVisible && <SearchBar onSearch={onSearch} />}
            <Stack.Item pl={!large_buttons && 4} pr={!large_buttons && 4}>
              <InputButtons input={selected} inputIsValid={inputIsValid} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

/**
 * Displays the list of selectable items.
 * If a search query is provided, filters the items.
 */
const ListDisplay = (props, context) => {
  const { data } = useBackend<ListInputData>(context);
  const { items } = data;
  const { onClick, searchQuery, selected } = props;
  const filteredItems = items.filter((item) =>
    item.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <Section fill scrollable tabIndex={4}>
      {filteredItems.map((item, index) => {
        return (
          <Button
            color="transparent"
            fluid
            key={index}
            onClick={() => onClick(item)}
            selected={item === selected}
            style={{
              'animation': 'none',
              'transition': 'none',
            }}>
            {item.replace(/^\w/, (c) => c.toUpperCase())}
          </Button>
        );
      })}
    </Section>
  );
};

/**
 * Renders a search bar input.
 * Closing the bar defaults input to an empty string.
 */
const SearchBar = (props) => {
  const { onSearch, searchQuery } = props;

  return (
    <Input
      fluid
      onInput={(e, value) => {
        onSearch(value);
      }}
      value={searchQuery}
    />
  );
};
