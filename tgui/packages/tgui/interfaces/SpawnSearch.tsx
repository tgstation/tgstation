import { useEffect, useMemo, useState } from 'react';
import {
  Autofocus,
  Box,
  Button,
  Icon,
  Input,
  Section,
  Stack,
  VirtualList,
} from 'tgui-core/components';
import { fetchRetry } from 'tgui-core/http';
import {
  KEY_DOWN,
  KEY_ENTER,
  KEY_ESCAPE,
  KEY_F,
  KEY_N,
  KEY_R,
  KEY_UP,
} from 'tgui-core/keycodes';
import type { BooleanLike } from 'tgui-core/react';
import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { logger } from '../logging';

type SpawnSearchData = {
  initValue: string | null;
  searchNames: BooleanLike;
  regexSearch: BooleanLike;
  fancyTypes: BooleanLike;
  includeAbstracts: BooleanLike;
};

type SpawnAtomData = {
  // Type -> Name
  types: Record<string, string>;
  abstractTypes: Record<string, boolean>;
  fancyTypes: Record<string, string>;
};

type AtomPathData = {
  types: AtomTypeData[];
  abstractTypes: Record<string, boolean>;
  fancyTypes: Record<string, string>;
};

type AtomTypeData = {
  typepath: string;
  name: string;
};

const initialAtomPathData: AtomPathData = {
  types: [],
  abstractTypes: {},
  fancyTypes: {},
};

export function SpawnSearch() {
  const { act, data } = useBackend<SpawnSearchData>();
  const {
    fancyTypes,
    includeAbstracts,
    initValue = '',
    regexSearch,
    searchNames,
  } = data;

  const [atomData, setAtomData] = useState(initialAtomPathData);
  const [selected, setSelected] = useState(0);
  const [query, setQuery] = useState(initValue || '');
  const [searchBarVisible, setSearchBarVisible] = useState(true);

  const { invalidInput, spawnAmount } = useMemo(() => {
    let invalidInput = false;
    let spawnAmount = 1;

    const possibleAmountData = query.split(':');
    const amountElement = possibleAmountData[possibleAmountData.length - 1];

    if (possibleAmountData.length > 1 && !Number.isNaN(+amountElement)) {
      if (+amountElement <= 0) {
        invalidInput = true;
      } else {
        spawnAmount = +amountElement;
      }
    }

    if (regexSearch) {
      try {
        new RegExp(query);
      } catch (error) {
        invalidInput = true;
      }
    }

    return { invalidInput, spawnAmount };
  }, [query, regexSearch]);

  const filteredItems = useMemo(() => {
    let filterQuery = query;

    // Extract amount suffix (e.g., ":5" from "query:5")
    const amountMatch = query.match(/^(.+):(\d+)$/);
    if (amountMatch) {
      const amount = +amountMatch[2];
      if (amount <= 0) {
        return [];
      }
      filterQuery = amountMatch[1].trimEnd();
    }

    if (filterQuery.length === 0) return [];

    if (regexSearch) {
      try {
        const queryRegex = new RegExp(filterQuery);
        return atomData.types.filter(
          (type: AtomTypeData) =>
            queryRegex.test(type.typepath) ||
            (searchNames && queryRegex.test(type.name)),
        );
      } catch (error) {
        return [];
      }
    }

    const finalizer = filterQuery.slice(filterQuery.length - 1);
    if (finalizer === '*' || finalizer === '!')
      filterQuery = filterQuery.slice(0, filterQuery.length - 1);
    filterQuery = filterQuery.toLowerCase();

    let searchLambda = (x: string) => x.toLowerCase().includes(filterQuery);
    if (finalizer === '!') {
      searchLambda = (x: string) =>
        x.toLowerCase().includes(filterQuery) &&
        x.toLowerCase().lastIndexOf(filterQuery) ===
          x.length - filterQuery.length;
    } else if (finalizer === '*') {
      searchLambda = (x: string) =>
        x.toLowerCase().includes(filterQuery) &&
        !x.slice(x.toLowerCase().lastIndexOf(filterQuery)).includes('/');
    }

    return atomData.types.filter(
      (type: AtomTypeData) =>
        (searchLambda(type.typepath) ||
          (searchNames && searchLambda(type.name))) &&
        (includeAbstracts || !atomData.abstractTypes[type.typepath]),
    );
  }, [query, atomData, regexSearch, includeAbstracts, searchNames]);

  useEffect(() => {
    fetchRetry(resolveAsset('spawn_menu_atom_data.json'))
      .then((response) => response.json())
      .then((data: SpawnAtomData) => {
        setAtomData({
          types: Object.keys(data.types).map((x: string) => ({
            typepath: x,
            name: data.types[x],
          })),
          abstractTypes: data.abstractTypes,
          fancyTypes: data.fancyTypes,
        });
      })
      .catch((error) => {
        logger.log(
          'Failed to fetch spawn_menu_atom_data.json',
          JSON.stringify(error),
        );
      });
  }, []);

  // User presses up or down on keyboard
  // Simulates clicking an item
  function handleArrowKey(key: number): void {
    const len = Object.keys(filteredItems).length - 1;
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
  }

  function handleKeyDown(event: React.KeyboardEvent<HTMLDivElement>): void {
    const keyCode = window.event ? event.which : event.keyCode;
    if (keyCode === KEY_DOWN || keyCode === KEY_UP) {
      event.preventDefault();
      handleArrowKey(keyCode);
    }

    if (keyCode === KEY_ENTER) {
      event.preventDefault();
      handleSelect(filteredItems[selected]);
    }

    if (keyCode === KEY_ESCAPE) {
      event.preventDefault();
      act('cancel');
    }

    if (keyCode === KEY_R && event.altKey) {
      act('setRegexSearch', { regexSearch: !regexSearch });
    }

    if (keyCode === KEY_N && event.altKey) {
      act('setNameSearch', { searchNames: !searchNames });
    }

    if (keyCode === KEY_F && event.altKey) {
      act('setFancyTypes', { fancyTypes: !fancyTypes });
    }
  }

  function handleSelect(selection: AtomTypeData): void {
    act('spawn', { type: selection.typepath, amount: spawnAmount });
  }

  function handleSearch(newQuery: string): void {
    if (newQuery === query) return;

    setQuery(newQuery);
    setSelected(0);
    document!.getElementById('0')?.scrollIntoView();
  }

  // Grabs the cursor when no search bar is visible.
  if (!searchBarVisible) {
    setTimeout(() => document!.getElementById(selected.toString())?.focus(), 1);
  }

  const modeText = regexSearch ? 'RegEx Mode' : 'Standard Mode';

  return (
    <Window
      title="Spawn Atom"
      width={400}
      height={500}
      buttons={
        <>
          <Button
            icon="font"
            selected={includeAbstracts}
            tooltip="Include Abstract Types"
            onClick={() =>
              act('setIncludeAbstracts', {
                includeAbstracts: !includeAbstracts,
              })
            }
          />
          <Button
            icon="file-signature"
            selected={searchNames}
            tooltip="Name Search"
            onClick={() => act('setNameSearch', { searchNames: !searchNames })}
          />
          <Button
            icon="wand-magic-sparkles"
            selected={fancyTypes}
            tooltip="Fancy Type Display"
            onClick={() => act('setFancyTypes', { fancyTypes: !fancyTypes })}
          />
        </>
      }
    >
      <Window.Content onKeyDown={handleKeyDown}>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section fill scrollable>
              <Autofocus />
              <VirtualList>
                {filteredItems.map((item, index) => (
                  <Button
                    className="candystripe"
                    color="transparent"
                    fluid
                    key={index}
                    onClick={() => {
                      if (index !== selected) setSelected(index);
                    }}
                    onDoubleClick={() => handleSelect(item)}
                    onKeyDown={(event) => {
                      if (/^[a-z]$/i.test(event.key)) {
                        event.preventDefault();
                        setSearchBarVisible(false);
                        setTimeout(() => {
                          setSearchBarVisible(true);
                        }, 1);
                      }
                    }}
                    selected={index === selected}
                    style={{
                      animation: 'none',
                      transition: 'none',
                    }}
                  >
                    <ListItem atomData={atomData} item={item} />
                  </Button>
                ))}
              </VirtualList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            {!!searchBarVisible && (
              <Stack fill align="center" g={0.5}>
                <Stack.Item width={2}>
                  <Button
                    color="transparent"
                    tooltip={modeText}
                    onClick={() => {
                      act('setRegexSearch', { regexSearch: !regexSearch });
                    }}
                  >
                    {regexSearch ? (
                      <Box as="span" color="good">
                        re:
                      </Box>
                    ) : (
                      <Icon name="search" />
                    )}
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  <Input
                    autoFocus
                    autoSelect
                    expensive
                    fluid
                    onEnter={() => handleSelect(filteredItems[selected])}
                    onChange={handleSearch}
                    placeholder="Search..."
                    value={query}
                    style={{
                      borderColor: invalidInput ? 'red' : undefined,
                    }}
                  />
                </Stack.Item>
              </Stack>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

type AtomSpanProps = {
  atomData: AtomPathData;
  item: AtomTypeData;
};

function ListItem(props: AtomSpanProps) {
  const { atomData, item } = props;

  const { data } = useBackend<SpawnSearchData>();
  const { fancyTypes } = data;

  const matchingKey = fancyTypes
    ? Object.keys(atomData.fancyTypes).findLast(
        (x: string) => item.typepath.indexOf(x) === 0,
      )
    : undefined;

  const displayPath = matchingKey
    ? item.typepath.replace(matchingKey, atomData.fancyTypes[matchingKey])
    : item.typepath;

  return (
    <>
      <span
        style={
          atomData.abstractTypes[item.typepath]
            ? { opacity: 0.75, color: '#FFA246' }
            : {}
        }
      >
        {displayPath}
      </span>
      <span
        className="label label-info"
        style={{
          marginLeft: '0.5em',
          color: 'rgba(200, 200, 200, 0.5)',
          fontSize: '10px',
        }}
      >
        {item.name}
      </span>
      {!!atomData.abstractTypes[item.typepath] && (
        <span
          style={{
            float: 'right',
            marginRight: '0.5em',
            color: 'rgba(255, 162, 70, 0.5)',
          }}
        >
          Abstract
        </span>
      )}
    </>
  );
}
