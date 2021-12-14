import { InputButtons, Preferences, Validator } from './common/InputButtons';
import { Button, Input, Section, Stack } from '../components';
import { KEY_ENTER, KEY_DOWN, KEY_UP } from 'common/keycodes';
import { Window } from '../layouts';
import { useBackend, useSharedState } from '../backend';

type ListInputData = {
  items: string[];
  message: string;
  preferences: Preferences;
  title: string;
};

export const ListInputModal = (_, context) => {
  const { act, data } = useBackend<ListInputData>(context);
  const { items = [], message, preferences, title } = data;
  const { large_buttons } = preferences;
  const [selected, setSelected] = useSharedState<number | null>(
    context,
    'input',
    0
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
  // User presses up or down on keyboard
  const onArrowKey = (key: number) => {
    const len = filteredItems.length;
    if (key === KEY_DOWN) {
      if (selected === null) {
        setSelected(0);
      } else {
        setSelected((len + (selected + 1)) % len);
      }
    } else if (key === KEY_UP) {
      if (selected === null) {
        setSelected(len);
      } else {
        setSelected((len + (selected - 1)) % len);
      }
    }
    document!.getElementById(selected?.toString() || '0')?.focus();
    setInputIsValid({ isValid: true, error: null });
  };
  // User selects an item with mouse
  const onClick = (index: number) => {
    if (index === undefined || index === selected) {
      setInputIsValid({ isValid: false, error: 'No selection' });
      setSelected(null);
    } else {
      setInputIsValid({ isValid: true, error: null });
      setSelected(index);
    }
  };
  // User doesn't have search bar visible & presses a key
  const onLetterKey = (key: number) => {
    const keyChar = String.fromCharCode(key);
    const foundItem = items.find((item) => {
      return item?.toLowerCase().startsWith(keyChar?.toLowerCase());
    });
    if (foundItem) {
      setSelected(items.indexOf(foundItem));
      document!.getElementById(items.indexOf(foundItem)!.toString())?.focus();
    }
  };
  // User types into search bar
  const onSearch = (query: string) => {
    setSelected(0);
    setSearchQuery(query);
  };
  // User presses the search button
  const onSearchBarToggle = () => {
    setSearchBarVisible(!searchBarVisible);
    setSearchQuery('');
  };
  const filteredItems = items.filter((item) =>
    item?.toLowerCase().includes(searchQuery.toLowerCase())
  );
  // Dynamically changes the window height based on the message.
  const windowHeight
    = 325 + Math.ceil(message?.length / 3) + (large_buttons ? 5 : 0);

  return (
    <Window title={title} width={325} height={windowHeight}>
      <Window.Content
        onKeyDown={(event) => {
          const keyCode = window.event ? event.which : event.keyCode;
          if (keyCode === KEY_ENTER && inputIsValid.isValid) {
            act('submit', { entry: selected });
          }
          if (keyCode === KEY_DOWN || keyCode === KEY_UP) {
            onArrowKey(keyCode);
          }
          if (!searchBarVisible && keyCode >= 65 && keyCode <= 90) {
            onLetterKey(keyCode);
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
                filteredItems={filteredItems}
                onClick={onClick}
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
const ListDisplay = (props) => {
  const { filteredItems, onClick, selected } = props;

  return (
    <Section fill scrollable tabIndex={0}>
      {filteredItems.map((item, index) => {
        return (
          <Button
            color="transparent"
            fluid
            id={index}
            key={index}
            onClick={() => onClick(index)}
            selected={index === selected}
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
      autoFocus
      fluid
      onInput={(e, value) => {
        onSearch(value);
      }}
      placeholder="Search..."
      value={searchQuery}
    />
  );
};
