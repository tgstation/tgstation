import { storage } from 'common/storage';
import { useEffect, useState } from 'react';
import {
  Button,
  DmIcon,
  Section,
  Stack,
  VirtualList,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { SearchBar } from '../common/SearchBar';
import { listNames, listTypes } from './constants';
import { CreateObjectSettings } from './CreateObjectSettings';
import { AtomData, CreateObjectProps } from './types';

interface SpawnPanelData {
  icon: string;
  iconState: string;
  selected_object?: string;
  copied_type?: string;
  preferences?: {
    hide_icons: boolean;
    hide_mappings: boolean;
    sort_by: string;
    search_text: string;
    search_by: string;
  };
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
  [key: string]: AtomData;
}

export function CreateObject(props: CreateObjectProps) {
  const { act, data } = useBackend<SpawnPanelData>();
  const { objList, setAdvancedSettings, iconSettings } = props;

  const [tooltipIcon, setTooltipIcon] = useState(false);
  const [selectedObj, setSelectedObj] = useState<string | null>(null);

  const [searchText, setSearchText] = useState('');
  const [searchBy, setSearchBy] = useState(false);
  const [sortBy, setSortBy] = useState(listTypes.Objects);
  const [hideMapping, setHideMapping] = useState(false);
  const [showIcons, setshowIcons] = useState(false);
  const [showPreview, setshowPreview] = useState(false);
  const currentType =
    Object.entries(listTypes).find(([_, value]) => value === sortBy)?.[0] ||
    'Objects';

  const currentList = (objList?.[currentType] || {}) as CurrentList;

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
      if (objList.Turfs[data.copied_type]) {
        setSortBy(listTypes.Turfs);
      } else if (objList.Mobs[data.copied_type]) {
        setSortBy(listTypes.Mobs);
      } else {
        setSortBy(listTypes.Objects);
      }
      setSearchBy(true);
      const list = objList.Turfs[data.copied_type]
        ? objList.Turfs
        : objList.Mobs[data.copied_type]
          ? objList.Mobs
          : objList.Objects;
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
    if (currentList[obj]) {
      props.onIconSettingsChange?.({
        icon: currentList[obj].icon,
        iconState: currentList[obj].icon_state,
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

      {showPreview && selectedObj && currentList[selectedObj] && (
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
                    icon={iconSettings.icon || currentList[selectedObj].icon}
                    icon_state={
                      iconSettings.iconState ||
                      currentList[selectedObj].icon_state
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
                  <Stack.Item>
                    <b>{currentList[selectedObj].name}</b>
                  </Stack.Item>
                  <Stack.Item grow>
                    <i style={{ color: 'rgba(200, 200, 200, 0.7)' }}>
                      {currentList[selectedObj].description || 'no description'}
                    </i>
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
                  query={searchText}
                  onSearch={(query) => {
                    updateSearchText(query);
                  }}
                />
              </Stack.Item>
            </Stack>
          </Stack>
        </Section>
      </Stack.Item>

      <Stack.Item grow>
        <Section fill scrollable>
          {searchText !== '' && (
            <VirtualList>
              {Object.keys(currentList)
                .filter((obj: string) => {
                  if (!hideMapping && Boolean(currentList[obj].mapping)) {
                    return false;
                  }
                  if (searchBy) {
                    return obj.toLowerCase().includes(searchText.toLowerCase());
                  }
                  return currentList[obj].name
                    ?.toLowerCase()
                    .includes(searchText.toLowerCase());
                })
                .map((obj, index) => (
                  <Button
                    key={index}
                    color="transparent"
                    tooltip={
                      (showIcons || tooltipIcon) && (
                        <DmIcon
                          icon={currentList[obj].icon}
                          icon_state={currentList[obj].icon_state}
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
                        {currentList[obj].name}
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
