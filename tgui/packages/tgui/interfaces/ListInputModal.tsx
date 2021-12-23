import { Loader } from './common/Loader';
import { InputButtons, Preferences, Validator } from './common/InputButtons';
import { Button, Input, Section, Stack } from '../components';
import { KEY_ENTER, KEY_DOWN, KEY_UP, KEY_ESCAPE } from '../../common/keycodes';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';

type ListInputData = {
  items: string[];
  message: string;
  preferences: Preferences;
  timeout: number;
  title: string;
};

export const ListInputModal = (_, context) => {
  const { act, data } = useBackend<ListInputData>(context);
  const { items = [], message, preferences, timeout, title } = data;
  const { large_buttons } = preferences;
  const [selected, setSelected] = useLocalState<number | null>(
    context,
    'selected',
    0
  );
  const [searchBarVisible, setSearchBarVisible] = useLocalState<boolean>(
    context,
    'searchBarVisible',
    items.length > 9
  );
  const [searchQuery, setSearchQuery] = useLocalState<string>(
    context,
    'searchQuery',
    ''
  );
  const [inputIsValid, setInputIsValid] = useLocalState<Validator>(
    context,
    'inputIsValid',
    { isValid: true, error: null }
  );
  // User presses up or down on keyboard
  // Simulates clicking an item
  const onArrowKey = (key: number) => {
    const len = filteredItems.length - 1;
    if (key === KEY_DOWN) {
      if (selected === null || selected === len) {
        onClick(0);
      } else {
        onClick(selected + 1);
      }
    } else if (key === KEY_UP) {
      if (selected === null || selected === 0) {
        onClick(len);
      } else {
        onClick(selected - 1);
      }
    }
  };
  // User selects an item with mouse
  const onClick = (index: number) => {
    if (isNaN(index) || index === selected) {
      setInputIsValid({ isValid: false, error: 'No selection' });
      setSelected(null);
    } else {
      setInputIsValid({ isValid: true, error: null });
      setSelected(index);
      document!.getElementById(index.toString())?.focus();
    }
  };
  // User doesn't have search bar visible & presses a key
  const onLetterKey = (key: number) => {
    const keyChar = String.fromCharCode(key);
    const foundItem = items.find((item) => {
      return item?.toLowerCase().startsWith(keyChar?.toLowerCase());
    });
    if (foundItem) {
      setSelected(filteredItems.indexOf(foundItem));
      document!.getElementById(filteredItems
        .indexOf(foundItem)
        .toString())?.focus();
    }
  };
  // User types into search bar
  const onSearch = (query: string) => {
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
      {timeout && <Loader value={timeout} />}
      <Window.Content
        onKeyDown={(event) => {
          const keyCode = window.event ? event.which : event.keyCode;
          if (keyCode === KEY_DOWN || keyCode === KEY_UP) {
            event.preventDefault();
            onArrowKey(keyCode);
          }
          if (!searchBarVisible && keyCode >= 65 && keyCode <= 90) {
            event.preventDefault();
            onLetterKey(keyCode);
          }
          if (keyCode === KEY_ESCAPE) {
            event.preventDefault();
            act('cancel');
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
          className="ListInput__Section"
          fill
          title={message}>
          <Stack fill vertical>
            <Stack.Item grow>
              <ListDisplay
                filteredItems={filteredItems}
                onClick={onClick}
                isValid={inputIsValid.isValid}
                selected={selected}
              />
            </Stack.Item>
            {searchBarVisible && <SearchBar onSearch={onSearch} />}
            <Stack.Item pl={!large_buttons && 4} pr={!large_buttons && 4}>
              <InputButtons
                input={selected !== null ? filteredItems[selected] : null}
                inputIsValid={inputIsValid} />
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
  const { act } = useBackend<ListInputData>(context);
  const { filteredItems, isValid, onClick, selected } = props;

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
            onKeyDown={(event) => {
              const keyCode = window.event ? event.which : event.keyCode;
              if (keyCode === KEY_ENTER && isValid) {
                event.preventDefault();
                act('submit', { entry: filteredItems[selected] });
              }
            }}
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
      onInput={(_, value) => {
        onSearch(value);
      }}
      placeholder="Search..."
      value={searchQuery}
    />
  );
};
