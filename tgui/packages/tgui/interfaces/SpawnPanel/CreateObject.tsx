import { storage } from 'common/storage';
import { useEffect, useState } from 'react';
import {
  Button,
  DmIcon,
  NoticeBox,
  Section,
  Stack,
  VirtualList,
} from 'tgui-core/components';
import { useFuzzySearch } from 'tgui-core/fuzzysearch';

import { useBackend } from '../../backend';
import { SearchBar } from '../common/SearchBar';
import { listNames, listTypes } from './constants';
import { CreateObjectSettings } from './CreateObjectSettings';
import { AtomData, CreateObjectProps, SpawnPanelPreferences } from './types';

interface SpawnPanelData {
  icon: string;
  iconState: string;
  selected_object?: string;
  copied_type?: string;
  preferences?: SpawnPanelPreferences;
}

interface SpawnPreferences {
  hide_icons: boolean;
  hide_mappings: boolean;
  sort_by: string;
  search_text: string;
  search_by: string;
  object_list?: string;
}

interface StateSetterConfig<T extends unknown> {
  value: T;
  storageKey: string;
  setter: (value: T) => void;
}

const setStateAndStorage = async <T extends unknown>({
  value,
  storageKey,
  setter,
}: StateSetterConfig<T>) => {
  setter(value);
  await storage.set(storageKey, value);
};

interface CurrentList {
  Atoms: {
    [key: string]: AtomData;
  };
}

export function CreateObject(props: CreateObjectProps) {
  const { act, data } = useBackend<SpawnPanelData>();
  const { setAdvancedSettings, iconSettings, objList = { Atoms: {} } } = props;

  const [tooltipIcon, setTooltipIcon] = useState(false);
  const [selectedObj, setSelectedObj] = useState<string | null>(null);

  const [searchText, setSearchText] = useState('');
  const [searchBy, setSearchBy] = useState(false);
  const [sortBy, setSortBy] = useState(listTypes.Objects);
  const [hideMapping, setHideMapping] = useState(false);
  const [showIcons, setshowIcons] = useState(false);
  const [showPreview, setshowPreview] = useState(false);

  const allObjects = Object.entries(objList).reduce<Record<string, AtomData>>(
    (acc, [_, objects]: [string, Record<string, AtomData>]) => {
      return { ...acc, ...objects };
    },
    {},
  );

  const currentList = objList as CurrentList;
  const currentType = allObjects[data.copied_type ?? '']?.type || 'Objects';

  const { query, setQuery, results } = useFuzzySearch({
    searchArray: Object.keys(allObjects),
    matchStrategy: 'smart',
    getSearchString: (key) => (searchBy ? key : allObjects[key]?.name || ''),
  });

  useEffect(() => {
    setQuery(query);
  }, [searchBy]);

  const filteredResults = results.filter((obj) => {
    const item = allObjects[obj];
    if (!item) return false;
    if (sortBy !== listTypes[item.type]) return false;
    if (hideMapping && item.mapping) return false;
    return true;
  });

  useEffect(() => {
    if (data.selected_object) {
      setSelectedObj(data.selected_object);
      if (currentList[data.selected_object]) {
        props.onIconSettingsChange?.({
          icon: currentList[data.selected_object].icon,
          iconState: currentList[data.selected_object].icon_state,
        });
      }
    }
  }, [data.selected_object]);

  useEffect(() => {
    if (data.copied_type) {
      setSelectedObj(data.copied_type);
      setSearchText(data.copied_type);

      setSortBy(listTypes[objList[data.copied_type]]);
      setSearchBy(true);

      const list = objList.Atoms;
      if (list[data.copied_type]) {
        props.onIconSettingsChange?.({
          icon: list[data.copied_type].icon,
          iconState: list[data.copied_type].icon_state,
        });
      }
    }
  }, [data.copied_type]);

  useEffect(() => {
    const loadStoredValues = async () => {
      const storedSearchText = await storage.get('spawnpanel-searchText');
      const storedSearchBy = await storage.get('spawnpanel-searchBy');
      const storedSortBy = await storage.get('spawnpanel-sortBy');
      const storedHideMapping = await storage.get('spawnpanel-hideMapping');
      const storedShowIcons = await storage.get('spawnpanel-showIcons');
      const storedShowPreview = await storage.get('spawnpanel-showPreview');

      if (storedSearchText) setSearchText(storedSearchText);
      if (storedSearchBy !== undefined) setSearchBy(storedSearchBy);
      if (storedSortBy) setSortBy(storedSortBy);
      if (storedHideMapping !== undefined) setHideMapping(storedHideMapping);
      if (storedShowIcons !== undefined) setshowIcons(storedShowIcons);
      if (storedShowPreview !== undefined) setshowPreview(storedShowPreview);
    };

    loadStoredValues();
  }, []);

  useEffect(() => {
    setSelectedObj(null);
  }, [currentType]);

  const updateSearchText = (value: string) => {
    setStateAndStorage({
      value,
      storageKey: 'spawnpanel-searchText',
      setter: setSearchText,
    });
  };

  const updateSearchBy = (value: boolean) => {
    setStateAndStorage({
      value,
      storageKey: 'spawnpanel-searchBy',
      setter: setSearchBy,
    });
  };

  const updateSortBy = (value: string) => {
    setStateAndStorage({
      value,
      storageKey: 'spawnpanel-sortBy',
      setter: setSortBy,
    });
  };

  const updateHideMapping = (value: boolean) => {
    setStateAndStorage({
      value,
      storageKey: 'spawnpanel-hideMapping',
      setter: setHideMapping,
    });
  };

  const updateShowIcons = (value: boolean) => {
    setStateAndStorage({
      value,
      storageKey: 'spawnpanel-showIcons',
      setter: setshowIcons,
    });
  };

  const updateShowPreview = (value: boolean) => {
    setStateAndStorage({
      value,
      storageKey: 'spawnpanel-showPreview',
      setter: setshowPreview,
    });
  };

  const sendPreferences = (settings: Partial<SpawnPreferences>) => {
    const prefsToSend = {
      hide_icons: showIcons,
      hide_mappings: hideMapping,
      sort_by:
        Object.keys(listTypes).find((key) => listTypes[key] === sortBy) ||
        'Objects',
      search_text: searchText,
      search_by: searchBy ? 'type' : 'name',
      ...settings,
    };

    act('create-object-action', prefsToSend);
  };

  const handleObjectSelect = (obj: string) => {
    setSelectedObj(obj);
    act('selected-object-changed', {
      newObj: obj,
    });
    if (allObjects[obj]) {
      props.onIconSettingsChange?.({
        icon: allObjects[obj].icon,
        iconState: allObjects[obj].icon_state,
      });
    }
  };

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section>
          <CreateObjectSettings
            onCreateObject={sendPreferences}
            setAdvancedSettings={setAdvancedSettings}
            iconSettings={iconSettings}
          />
        </Section>
      </Stack.Item>

      {showPreview && selectedObj && allObjects[selectedObj] && (
        <Stack.Item>
          <Section
            style={{
              height: '6em',
            }}
          >
            <Stack>
              <Stack.Item>
                <Button
                  width="5em"
                  height="4.8em"
                  mb="-3px"
                  color="transparent"
                  ml="1px"
                  style={{
                    alignContent: 'center',
                  }}
                >
                  <DmIcon
                    width="4em"
                    mt="2px"
                    icon={iconSettings.icon || allObjects[selectedObj].icon}
                    icon_state={
                      iconSettings.iconState ||
                      allObjects[selectedObj].icon_state
                    }
                  />
                </Button>
              </Stack.Item>
              <Stack.Item
                grow
                style={{
                  maxHeight: '4.8em',
                  overflowY: 'auto',
                }}
              >
                <Stack vertical>
                  <Stack.Item bold>{allObjects[selectedObj].name}</Stack.Item>
                  <Stack.Item
                    grow
                    italic
                    style={{ color: 'rgba(200, 200, 200, 0.7)' }}
                  >
                    {allObjects[selectedObj].description || 'no description'}
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      )}

      <Stack.Item>
        <Section>
          <Stack vertical>
            <Stack>
              <Stack.Item>
                <Button
                  icon={sortBy}
                  onClick={() => {
                    const types = Object.values(listTypes);
                    const currentIndex = types.indexOf(sortBy);
                    const nextIndex = (currentIndex + 1) % types.length;
                    updateSortBy(types[nextIndex]);
                  }}
                >
                  {
                    listNames[
                      Object.keys(listTypes).find(
                        (key) => listTypes[key] === sortBy,
                      ) || 'Objects'
                    ]
                  }
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon={searchBy ? 'code' : 'font'}
                  onClick={() => {
                    updateSearchBy(!searchBy);
                  }}
                >
                  {searchBy ? 'By type' : 'By name'}
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button.Checkbox
                  onClick={() => {
                    updateHideMapping(!hideMapping);
                  }}
                  color={!hideMapping && 'good'}
                  checked={!hideMapping}
                >
                  Mapping
                </Button.Checkbox>
              </Stack.Item>
              <Stack.Item>
                <Button.Checkbox
                  onClick={() => {
                    updateShowIcons(!showIcons);
                  }}
                  color={showIcons && 'good'}
                  checked={showIcons}
                >
                  Icons
                </Button.Checkbox>
              </Stack.Item>
              <Stack.Item>
                <Button.Checkbox
                  onClick={() => {
                    updateShowPreview(!showPreview);
                  }}
                  color={showPreview && 'good'}
                  checked={showPreview}
                >
                  Preview
                </Button.Checkbox>
              </Stack.Item>
            </Stack>
            <Stack>
              <Stack.Item grow ml="-0.5em">
                <SearchBar
                  noIcon
                  placeholder={'Search here...'}
                  query={query}
                  onSearch={setQuery}
                />
              </Stack.Item>
            </Stack>
          </Stack>
        </Section>
      </Stack.Item>

      <Stack.Item grow>
        <Section fill scrollable>
          {query !== '' && (
            <VirtualList>
              {results.length > 0 && Object.keys(currentList).length > 0 ? (
                filteredResults.map((obj, index) => (
                  <Button
                    key={index}
                    color="transparent"
                    tooltip={
                      (showIcons || tooltipIcon) &&
                      allObjects[obj] && (
                        <DmIcon
                          icon={allObjects[obj].icon}
                          icon_state={allObjects[obj].icon_state}
                        />
                      )
                    }
                    tooltipPosition="top-start"
                    fluid
                    selected={selectedObj === obj}
                    style={{
                      backgroundColor:
                        selectedObj === obj
                          ? 'rgba(160, 200, 255, 0.1)'
                          : undefined,
                      color: selectedObj === obj ? '#fff' : undefined,
                    }}
                    onDoubleClick={() => {
                      if (selectedObj) {
                        sendPreferences({ object_list: selectedObj });
                      }
                    }}
                    onClick={() => handleObjectSelect(obj)}
                  >
                    {searchBy ? (
                      obj
                    ) : (
                      <>
                        {allObjects[obj]?.name}
                        <span
                          className="label label-info"
                          style={{
                            marginLeft: '0.5em',
                            color: 'rgba(200, 200, 200, 0.5)',
                            fontSize: '10px',
                          }}
                        >
                          {obj}
                        </span>
                      </>
                    )}
                  </Button>
                ))
              ) : (
                <NoticeBox textAlign="center" color="label" mt={2}>
                  Nothing found
                </NoticeBox>
              )}
            </VirtualList>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
}
