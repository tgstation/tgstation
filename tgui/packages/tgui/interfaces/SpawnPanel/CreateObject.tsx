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
import { CreateObjectProps } from './types';

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

export function CreateObject(props: CreateObjectProps) {
  const { act, data } = useBackend<SpawnPanelData>();
  const { objList } = props;

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

  const currentList = objList?.[currentType] || {};

  useEffect(() => {
    if (data.selected_object) {
      setSelectedObj(data.selected_object);
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
    }
  }, [data.copied_type, objList]);

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
    storage.set('spawnpanel-searchText', searchText);
  }, [searchText]);

  useEffect(() => {
    storage.set('spawnpanel-searchBy', searchBy);
  }, [searchBy]);

  useEffect(() => {
    storage.set('spawnpanel-sortBy', sortBy);
  }, [sortBy]);

  useEffect(() => {
    storage.set('spawnpanel-hideMapping', hideMapping);
  }, [hideMapping]);

  useEffect(() => {
    storage.set('spawnpanel-showIcons', showIcons);
  }, [showIcons]);

  useEffect(() => {
    storage.set('spawnpanel-showPreview', showPreview);
  }, [showPreview]);

  const sendPreferences = (settings) => {
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

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section>
          <CreateObjectSettings onCreateObject={sendPreferences} />
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
                    icon={currentList[selectedObj].icon}
                    icon_state={currentList[selectedObj].icon_state}
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
                    setSortBy(types[nextIndex]);
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
                    setSearchBy(!searchBy);
                  }}
                >
                  {searchBy ? 'By type' : 'By name'}
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button.Checkbox
                  onClick={() => {
                    setHideMapping(!hideMapping);
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
                    setshowIcons(!showIcons);
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
                    setshowPreview(!showPreview);
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
                    setSearchText(query);
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
                          ? 'rgba(255, 255, 255, 0.1)'
                          : undefined,
                      color: selectedObj === obj ? '#fff' : undefined,
                    }}
                    onDoubleClick={() => {
                      if (selectedObj) {
                        sendPreferences({ object_list: selectedObj });
                      }
                    }}
                    onMouseDown={(e) => {
                      if (e.button === 0 && e.shiftKey) {
                        setTooltipIcon(true);
                      }
                    }}
                    onMouseUp={(e) => {
                      if (e.button === 0) {
                        setTooltipIcon(false);
                      }
                    }}
                    onClick={() => {
                      setSelectedObj(obj);
                      act('selected-object-changed', {
                        newObj: obj,
                      });
                    }}
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
