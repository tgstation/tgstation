import { useState } from 'react';
import { Autofocus, Button, Input, Section, Stack } from 'tgui-core/components';
import {
  KEY_A,
  KEY_DOWN,
  KEY_ENTER,
  KEY_ESCAPE,
  KEY_UP,
  KEY_Z,
} from 'tgui-core/keycodes';

import { useBackend } from '../../backend';
import { InputButtons } from '../common/InputButtons';

type ListInputModalProps = {
  items: string[];
  default_item: string;
  message: string;
  on_selected: (entry: string) => void;
  on_cancel: () => void;
};

export const ListInputModal = (props: ListInputModalProps) => {
  const { items = [], default_item, message, on_selected, on_cancel } = props;

  const [selected, setSelected] = useState(items.indexOf(default_item));
  const [searchBarVisible, setSearchBarVisible] = useState(items.length > 9);
  const [searchQuery, setSearchQuery] = useState('');

  // User presses up or down on keyboard
  // Simulates clicking an item
  const onArrowKey = (key: number) => {
    const len = filteredItems.length - 1;
    if (key === KEY_DOWN) {
      if (selected === null || selected === len) {
        setSelected(0);
        document!.getElementById('0')?.scrollIntoView();
      } else {
        setSelected(selected + 1);
        document!.getElementById((selected + 1).toString())?.scrollIntoView();
      }
    } else if (key === KEY_UP) {
      if (selected === null || selected === 0) {
        setSelected(len);
        document!.getElementById(len.toString())?.scrollIntoView();
      } else {
        setSelected(selected - 1);
        document!.getElementById((selected - 1).toString())?.scrollIntoView();
      }
    }
  };
  // User selects an item with mouse
  const onClick = (index: number) => {
    if (index === selected) {
      return;
    }
    setSelected(index);
  };
  // User presses a letter key and searchbar is visible
  const onFocusSearch = () => {
    setSearchBarVisible(false);
    setTimeout(() => {
      setSearchBarVisible(true);
    }, 1);
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
    item?.toLowerCase().includes(searchQuery.toLowerCase()),
  );
  // Grabs the cursor when no search bar is visible.
  if (!searchBarVisible) {
    setTimeout(() => document!.getElementById(selected.toString())?.focus(), 1);
  }

  return (
    <Section
      onKeyDown={(event) => {
        const keyCode = window.event ? event.which : event.keyCode;
        if (keyCode === KEY_DOWN || keyCode === KEY_UP) {
          event.preventDefault();
          onArrowKey(keyCode);
        }
        if (keyCode === KEY_ENTER) {
          event.preventDefault();
          on_selected(filteredItems[selected]);
        }
        if (!searchBarVisible && keyCode >= KEY_A && keyCode <= KEY_Z) {
          event.preventDefault();
          onLetterSearch(keyCode);
        }
        if (keyCode === KEY_ESCAPE) {
          event.preventDefault();
          on_cancel();
        }
      }}
      buttons={
        <Button
          compact
          icon={searchBarVisible ? 'search' : 'font'}
          selected
          tooltip={
            searchBarVisible
              ? 'Search Mode. Type to search or use arrow keys to select manually.'
              : 'Hotkey Mode. Type a letter to jump to the first match. Enter to select.'
          }
          tooltipPosition="left"
          onClick={() => onSearchBarToggle()}
        />
      }
      className="ListInput__Section"
      fill
      title={message}
    >
      <Stack fill vertical>
        <Stack.Item grow>
          <ListDisplay
            filteredItems={filteredItems}
            onClick={onClick}
            onFocusSearch={onFocusSearch}
            searchBarVisible={searchBarVisible}
            selected={selected}
          />
        </Stack.Item>
        {searchBarVisible && (
          <SearchBar
            filteredItems={filteredItems}
            onSearch={onSearch}
            searchQuery={searchQuery}
            selected={selected}
          />
        )}
        <Stack.Item>
          <InputButtons
            input={filteredItems[selected]}
            on_submit={() => on_selected(filteredItems[selected])}
            on_cancel={on_cancel}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

/**
 * Displays the list of selectable items.
 * If a search query is provided, filters the items.
 */
const ListDisplay = (props) => {
  const { act } = useBackend();
  const { filteredItems, onClick, onFocusSearch, searchBarVisible, selected } =
    props;

  return (
    <Section fill scrollable>
      <Autofocus />
      {filteredItems.map((item, index) => {
        return (
          <Button
            className="candystripe"
            color="transparent"
            fluid
            id={index}
            key={index}
            onClick={() => onClick(index)}
            onDoubleClick={(event) => {
              event.preventDefault();
              act('submit', { entry: filteredItems[selected] });
            }}
            onKeyDown={(event) => {
              const keyCode = window.event ? event.which : event.keyCode;
              if (searchBarVisible && keyCode >= KEY_A && keyCode <= KEY_Z) {
                event.preventDefault();
                onFocusSearch();
              }
            }}
            selected={index === selected}
            style={{
              animation: 'none',
              transition: 'none',
            }}
          >
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
  const { act } = useBackend();
  const { filteredItems, onSearch, searchQuery, selected } = props;

  return (
    <Input
      autoFocus
      autoSelect
      fluid
      onEnter={(event) => {
        event.preventDefault();
        act('submit', { entry: filteredItems[selected] });
      }}
      onInput={(_, value) => onSearch(value)}
      placeholder="Search..."
      value={searchQuery}
    />
  );
};
