import { storage } from 'common/storage';
import { useEffect, useState } from 'react';
import {
  Button,
  DmIcon,
  Input,
  NoticeBox,
  Section,
  Stack,
  VirtualList,
} from 'tgui-core/components';
import { useFuzzySearch } from 'tgui-core/fuzzysearch';

import { useBackend } from '../../backend';
import { CreateObjectSettings } from './CreateObjectSettings';
import { listNames, listTypes } from './constants';
import type {
  AtomData,
  CreateObjectProps,
  SpawnPanelPreferences,
} from './types';

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
  selected_atom?: string;
}

export function CreateObject(props: CreateObjectProps) {
  const { act, data } = useBackend<SpawnPanelData>();
  const { setAdvancedSettings, iconSettings, objList = { atoms: {} } } = props;

  const [tooltipIcon, setTooltipIcon] = useState(false);
  const [selectedObj, setSelectedObj] = useState<string | null>(null);
  const [searchBy, setSearchBy] = useState(false);
  const [sortBy, setSortBy] = useState(listTypes.Objects);
  const [hideMapping, setHideMapping] = useState(false);
  const [showIcons, setshowIcons] = useState(false);
  const [showPreview, setshowPreview] = useState(false);

  // flattening the object lists
  const allObjects = objList.atoms;

  const currentList = objList;
  const currentType = allObjects[data.copied_type ?? '']?.type || 'Objects';

  const { query, setQuery, results } = useFuzzySearch({
    searchArray: Object.keys(allObjects),
    matchStrategy: 'smart',
    getSearchString: (key) => (searchBy ? key : allObjects[key]?.name || ''),
  });

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
      setQuery(data.copied_type);

      const copiedAtom: AtomData = objList.atoms[data.copied_type];
      setSortBy(listTypes[copiedAtom.type]);
      setSearchBy(true);

      const list = objList.atoms;
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
      const storedSelectedObj = await storage.get('spawnpanel-selectedObj');

      if (storedSearchText) setQuery(storedSearchText);
      if (storedSearchBy !== undefined) setSearchBy(storedSearchBy);
      if (storedSortBy) setSortBy(storedSortBy);
      if (storedHideMapping !== undefined) setHideMapping(storedHideMapping);
      if (storedShowIcons !== undefined) setshowIcons(storedShowIcons);
      if (storedShowPreview !== undefined) setshowPreview(storedShowPreview);
      if (storedSelectedObj) {
        if (allObjects[storedSelectedObj]) {
          setSelectedObj(storedSelectedObj);
          props.onIconSettingsChange?.({
            icon: allObjects[storedSelectedObj].icon,
            iconState: allObjects[storedSelectedObj].icon_state,
          });
        }
      }
    };

    loadStoredValues();
  }, []);

  useEffect(() => {
    setSelectedObj(null);
  }, [currentType]);

  useEffect(() => {
    if (selectedObj !== null) {
      storage.set('spawnpanel-selectedObj', selectedObj);
    }
  }, [selectedObj]);

  useEffect(() => {
    if (data.selected_object) {
      setSelectedObj(data.selected_object);
    } else if (data.copied_type) {
      setSelectedObj(data.copied_type);
    }
  }, [data.selected_object, data.copied_type]);

  useEffect(() => {
    if (data.iconState !== undefined) {
      props.onIconSettingsChange({
        iconState: data.iconState,
      });
    }
  }, [data.iconState]);

  const sendUpdatedSettings = (
    changedSettings: Partial<Record<string, unknown>> = {},
  ) => {
    act('update-settings', changedSettings);
  };

  const updateSearchText = (value: string) => {
    setQuery(value);
    storage.set('spawnpanel-searchText', value);
  };

  const updateSearchBy = (value: boolean) => {
    setSearchBy(value);
    storage.set('spawnpanel-searchBy', value);
  };

  const updateSortBy = (value: string) => {
    setSortBy(value);
    storage.set('spawnpanel-sortBy', value);
  };

  const updateHideMapping = (value: boolean) => {
    setHideMapping(value);
    storage.set('spawnpanel-hideMapping', value);
  };

  const updateShowIcons = (value: boolean) => {
    setshowIcons(value);
    storage.set('spawnpanel-showIcons', value);
  };

  const updateShowPreview = (value: boolean) => {
    setshowPreview(value);
    storage.set('spawnpanel-showPreview', value);
  };

  const sendPreferences = (settings: Partial<SpawnPreferences>) => {
    const parseOffset = (offsetStr: string): number[] => {
      if (!offsetStr.trim()) return [0, 0, 0];

      const parts = offsetStr.split(',').map((part) => {
        return parseInt(part.trim());
      });

      while (parts.length < 3) {
        parts.push(0);
      }

      return parts.slice(0, 3);
    };

    const prefsToSend = {
      hide_icons: showIcons,
      hide_mappings: hideMapping,
      sort_by:
        Object.keys(listTypes).find((key) => listTypes[key] === sortBy) ||
        'Objects',
      search_text: query,
      search_by: searchBy ? 'type' : 'name',
      ...settings,
    };

    act('create-atom-action', prefsToSend);
  };

  const handleObjectSelect = (obj: string) => {
    setSelectedObj(obj);
    act('selected-atom-changed', {
      newObj: obj,
    });
    if (allObjects[obj]) {
      props.onIconSettingsChange?.({
        icon: allObjects[obj].icon,
        iconState: allObjects[obj].icon_state,
      });
    }
  };

  const handleResetIconState = () => {
    props.onIconSettingsChange({
      iconState: null,
      icon: selectedObj ? allObjects[selectedObj]?.icon : null,
    });
    act('reset-icon-state');
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
          <Section style={{ height: '6em' }}>
            <Stack>
              <Stack.Item>
                <Button
                  width="5em"
                  height="4.8em"
                  mb="-3px"
                  color="transparent"
                  ml="1px"
                  style={{ alignContent: 'center' }}
                >
                  <DmIcon
                    width="4em"
                    mt="2px"
                    icon={
                      iconSettings.icon ||
                      data.icon ||
                      allObjects[selectedObj].icon
                    }
                    icon_state={
                      iconSettings.iconState ||
                      data.iconState ||
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
                  tooltip={`Cycle the searching target (objects, mobs, turfs)`}
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
                  tooltip={`Cycle the search method (by name, by type)`}
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
                  tooltip={`Toggle mapping objects visibility`}
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
                  tooltip={`Toggle preview icons on hovering`}
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
                  tooltip={`Toggle the large object preview panel`}
                >
                  Preview
                </Button.Checkbox>
              </Stack.Item>
              <Stack.Item>
                <Button
                  height="1.7em"
                  color="transparent"
                  icon="close"
                  onClick={() => setQuery('')}
                />
              </Stack.Item>
            </Stack>
            <Stack.Item grow>
              <Input
                placeholder="Search here..."
                value={query}
                onChange={(value) => updateSearchText(value)}
                fluid
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      <Stack.Item grow>
        <Section fill scrollable={filteredResults.length !== 0}>
          {query === '' ? (
            <NoticeBox textAlign="center" color="blue" width="100%">
              Begin typing to search...
            </NoticeBox>
          ) : !filteredResults.length ? (
            <NoticeBox textAlign="center" color="blue" width="100%">
              Nothing found
            </NoticeBox>
          ) : (
            <VirtualList>
              {filteredResults.map((obj, index) => (
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
                      sendPreferences({ selected_atom: selectedObj });
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
              ))}
            </VirtualList>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
}
