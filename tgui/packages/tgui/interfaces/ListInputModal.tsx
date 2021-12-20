import { Loader } from './common/Loader';
import { InputButtons, Preferences, Validator } from './common/InputButtons';
import { Button, Input, Section, Stack } from '../components';
import { KEY_ENTER, KEY_DOWN, KEY_UP, KEY_ESCAPE } from '../../common/keycodes';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';

type ListInputData = {
  items: string[];
  message: string;
  initValue: string;
  preferences: Preferences;
  timeout: number;
  title: string;
};

export const ListInputModal = (_, context) => {
  const { act, data } = useBackend<ListInputData>(context);
  const {
    items = [],
    message,
    initValue,
    preferences,
    timeout,
    title,
  } = data;
  const { large_buttons } = preferences;
  const [selected, setSelected] = useLocalState<number | null>(
    context,
    'selected',
    items.indexOf(initValue),
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
        document!.getElementById('0')?.scrollIntoView();
      } else {
        onClick(selected + 1);
        document!.getElementById((selected + 1).toString())?.scrollIntoView();
      }
    } else if (key === KEY_UP) {
      if (selected === null || selected === 0) {
        onClick(len);
        document!.getElementById(len.toString())?.scrollIntoView();
      } else {
        onClick(selected - 1);
        document!.getElementById((selected - 1).toString())?.scrollIntoView();
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
    }
  };
  // User presses a letter key and searchbar is visible
  const onFocusSearch = () => {
    setSearchBarVisible(false);
    setSearchBarVisible(true);
  };
  // User presses a letter key with no searchbar visible
  const onLetterSearch = (key: number) => {
    const keyChar = String.fromCharCode(key);
    const foundItem = items.find((item) => {
      return item?.toLowerCase().startsWith(keyChar?.toLowerCase());
    });
    if (foundItem) {
      const foundIndex = items.indexOf(foundItem);
      setSelected(foundIndex);
        document!.getElementById(foundIndex.toString())?.scrollIntoView();
    }
  };
  // User types into search bar
  const onSearch = (query: string) => {
    if (query === searchQuery) {
      return;
    }
    setSearchQuery(query);
    setSelected(0);
    document!.getElementById('0')?.scrollIntoView();
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
          if (keyCode === KEY_ENTER && inputIsValid.isValid) {
            event.preventDefault();
            act('submit', { entry: filteredItems[selected!] });
          }
          if (!searchBarVisible && keyCode >= 65 && keyCode <= 90) {
            event.preventDefault();
            onLetterSearch(keyCode);
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
                onFocusSearch={onFocusSearch}
                selected={selected}
              />
            </Stack.Item>
            {searchBarVisible && (
              <SearchBar
                filteredItems={filteredItems}
                isValid={inputIsValid.isValid}
                onSearch={onSearch}
                searchQuery={searchQuery}
                selected={selected}
              />
            )}
            <Stack.Item pl={!large_buttons && 4} pr={!large_buttons && 4}>
              <InputButtons
                input={selected !== null ? filteredItems[selected] : null}
                inputIsValid={inputIsValid}
              />
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
  const { filteredItems, onClick, onFocusSearch, selected } = props;

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
              if (keyCode >= 65 && keyCode <= 90) {
                event.preventDefault();
                onFocusSearch();
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
const SearchBar = (props, context) => {
  const { act } = useBackend<ListInputData>(context);
  const { filteredItems, isValid, onSearch, searchQuery, selected } = props;

  return (
    <Input
      autoFocus
      autoSelect
      fluid
      onEnter={(event) => {
        if (isValid) {
          event.preventDefault();
          act('submit', { entry: filteredItems[selected] });
        }
      }}
      onInput={(_, value) => onSearch(value)}
      placeholder="Search..."
      value={searchQuery}
    />
  );
};
