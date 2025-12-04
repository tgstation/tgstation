import { useEffect, useState } from 'react';
import {
  Autofocus,
  Button,
  Input,
  Section,
  Stack,
  VirtualList,
} from 'tgui-core/components';
import { fetchRetry } from 'tgui-core/http';
import {
  KEY_A,
  KEY_DOWN,
  KEY_ENTER,
  KEY_ESCAPE,
  KEY_F,
  KEY_N,
  KEY_R,
  KEY_UP,
  KEY_Z,
} from 'tgui-core/keycodes';
import { resolveAsset } from '../assets';
import { useBackend } from './../backend';
import { Window } from './../layouts';
import { logger } from '../logging';

type SpawnSearchData = {
  initValue: string | undefined;
  searchNames: boolean;
  regexSearch: boolean;
  fancyTypes: boolean;
  includeAbstracts: boolean;
};

type SpawnAtomData = {
  // Type -> Name
  types: Record<string, string>;
  abstractTypes: Array<string>;
  fancyTypes: Record<string, string>;
};

type AtomPathData = {
  types: Array<AtomTypeData>;
  abstractTypes: Array<string>;
  fancyTypes: Record<string, string>;
};

type AtomTypeData = {
  typepath: string;
  name: string;
};

export const SpawnSearch = () => {
  const { act, data } = useBackend<SpawnSearchData>();
  const { initValue, searchNames, regexSearch, fancyTypes, includeAbstracts } =
    data;
  const [atomData, setAtomData] = useState<AtomPathData>({
    types: [],
    abstractTypes: [],
    fancyTypes: {},
  });
  const [selected, setSelected] = useState<number>(0);
  const [query, setQuery] = useState<string>(
    (regexSearch ? 're:' : '') + (initValue || ''),
  );
  const [spawnAmount, setSpawnAmount] = useState<number>(1);
  const [invalidInput, setInvalidInput] = useState<boolean>(false);
  const [searchBarVisible, setSearchBarVisible] = useState<boolean>(true);

  const filterItems = () => {
    let filterQuery = query;
    setInvalidInput(false);
    const isRegex = filterQuery.indexOf('re:') === 0;
    // Remove regex command
    if (isRegex) filterQuery = filterQuery.slice(3).trimStart();
    // We wiped the whole query in one keypress (Ctrl+A -> Delete)
    // Default to regex if we have it enabled
    else if (regexSearch && filterQuery.length === 0) filterQuery = 're:';
    const possibleAmountData = filterQuery.split(':');
    const amountElement = possibleAmountData[possibleAmountData.length - 1];
    // This language is cursed, check if last : contains a number afterwards
    if (possibleAmountData.length > 1 && !Number.isNaN(+amountElement)) {
      if (+amountElement <= 0) {
        setInvalidInput(true);
        return [];
      }

      filterQuery = filterQuery
        .slice(0, filterQuery.length - amountElement.length - 1)
        .trimEnd();
      setSpawnAmount(+amountElement);
    } else if (spawnAmount !== 1) setSpawnAmount(1);

    if (isRegex !== regexSearch)
      act('setRegexSearch', { regexSearch: regexSearch });

    if (filterQuery.length === 0) return [];

    if (isRegex) {
      try {
        const queryRegex = new RegExp(filterQuery);
        return atomData.types.filter(
          (type: AtomTypeData) =>
            queryRegex.test(type.typepath) ||
            (searchNames && queryRegex.test(type.name)),
        );
      } catch (error) {
        // We'll get plenty of invalid regexes as we type it out, just highlight the input red and abort search
        setInvalidInput(true);
        return [];
      }
    }

    const finalizer = filterQuery.slice(filterQuery.length - 1);
    if (finalizer === '*' || finalizer === '!')
      filterQuery = filterQuery.slice(0, filterQuery.length - 1);
    filterQuery = filterQuery.toLowerCase();
    let searchLambda = (x: string) => x.toLowerCase().includes(filterQuery);
    if (finalizer === '!')
      searchLambda = (x: string) =>
        x.toLowerCase().includes(filterQuery) &&
        x.toLowerCase().lastIndexOf(filterQuery) ===
          x.length - filterQuery.length;
    else if (finalizer === '*')
      searchLambda = (x: string) =>
        x.toLowerCase().includes(filterQuery) &&
        !x.slice(x.toLowerCase().lastIndexOf(filterQuery)).includes('/');
    return atomData.types.filter(
      (type: AtomTypeData) =>
        (searchLambda(type.typepath) ||
          (searchNames && searchLambda(type.name))) &&
        (includeAbstracts || !atomData.abstractTypes.includes(type.typepath)),
    );
  };

  const [filteredItems, setFilteredItems] = useState<Array<AtomTypeData>>([]);

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

  useEffect(
    () => setFilteredItems(filterItems()),
    [query, atomData, includeAbstracts],
  );

  // User presses up or down on keyboard
  // Simulates clicking an item
  const onArrowKey = (key: number) => {
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
  };

  const onSelected = (selection: AtomTypeData) =>
    act('spawn', { type: selection.typepath, amount: spawnAmount });

  const onSearch = (newQuery: string) => {
    if (newQuery === query) {
      return;
    }
    setQuery(newQuery);
    setSelected(0);
    document!.getElementById('0')?.scrollIntoView();
  };

  // Grabs the cursor when no search bar is visible.
  if (!searchBarVisible) {
    setTimeout(() => document!.getElementById(selected.toString())?.focus(), 1);
  }

  return (
    <Window
      title="Spawn Atom"
      width={400}
      height={500}
      buttons={
        <>
          <Button
            icon="percent"
            selected={query.indexOf('re:') === 0}
            tooltip={
              query.indexOf('re:') === 0 ? 'RegEx Mode' : 'Standard Mode'
            }
            onClick={() => {
              query.indexOf('re:') === 0
                ? setQuery(query.slice(3))
                : setQuery(`re:${query}`);
            }}
          />
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
      <Window.Content>
        <Section
          fill
          onKeyDown={(event) => {
            const keyCode = window.event ? event.which : event.keyCode;
            if (keyCode === KEY_DOWN || keyCode === KEY_UP) {
              event.preventDefault();
              onArrowKey(keyCode);
            }

            if (keyCode === KEY_ENTER) {
              event.preventDefault();
              onSelected(filteredItems[selected]);
            }

            if (keyCode === KEY_ESCAPE) {
              event.preventDefault();
              act('cancel');
            }

            if (keyCode === KEY_R && event.altKey) {
              if (query.indexOf('re:') === 0) setQuery(query.slice(3));
              else setQuery(`re:${query}`);
            }

            if (keyCode === KEY_N && event.altKey)
              act('setNameSearch', { searchNames: !searchNames });

            if (keyCode === KEY_F && event.altKey)
              act('setFancyTypes', { fancyTypes: !fancyTypes });
          }}
        >
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
                      id={`${index}`}
                      key={index}
                      onClick={() => {
                        if (index !== selected) setSelected(index);
                      }}
                      onDoubleClick={() => onSelected(item)}
                      onKeyDown={(event) => {
                        const keyCode = window.event
                          ? event.which
                          : event.keyCode;
                        if (keyCode >= KEY_A && keyCode <= KEY_Z) {
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
                      <span
                        style={
                          atomData.abstractTypes.includes(item.typepath)
                            ? { opacity: 0.75, color: '#FFA246' }
                            : {}
                        }
                      >
                        {fancyTypes &&
                        Object.keys(atomData.fancyTypes).findLast(
                          (x: string) => item.typepath.indexOf(x) === 0,
                        )
                          ? item.typepath.replace(
                              Object.keys(atomData.fancyTypes).findLast(
                                (x: string) => item.typepath.indexOf(x) === 0,
                              ) as string,
                              atomData.fancyTypes[
                                Object.keys(atomData.fancyTypes).findLast(
                                  (x: string) => item.typepath.indexOf(x) === 0,
                                ) as string
                              ],
                            )
                          : item.typepath}
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
                      {!!atomData.abstractTypes.includes(item.typepath) && (
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
                    </Button>
                  ))}
                </VirtualList>
              </Section>
            </Stack.Item>
            {!!searchBarVisible && (
              <Input
                autoFocus
                autoSelect
                fluid
                onEnter={() => onSelected(filteredItems[selected])}
                onChange={onSearch}
                placeholder="Search..."
                value={query}
                style={invalidInput ? { borderColor: 'red' } : {}}
              />
            )}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
