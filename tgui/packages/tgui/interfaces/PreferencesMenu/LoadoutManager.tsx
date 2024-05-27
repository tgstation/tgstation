import { BooleanLike } from 'common/react';
import { useState } from 'react';

import { useBackend } from '../../backend';
import {
  Box,
  Button,
  Input,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from '../../components';
import { CharacterPreview } from '../common/CharacterPreview';
import { PreferencesMenuData } from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

type LoadoutButton = {
  icon: string;
  act_key?: string;
  tooltip?: string;
};

type LoadoutItem = {
  name: string;
  path: string; // typepath
  buttons: LoadoutButton[];
};

export type LoadoutCategory = {
  name: string;
  title: string;
  contents: LoadoutItem[];
};

type Data = PreferencesMenuData & {
  job_clothes: BooleanLike;
  loadout_preview_view: string;
};

export const LoadoutPage = () => {
  return (
    <ServerPreferencesFetcher
      render={(serverData) => {
        return serverData ? (
          <LoadoutPageInner loadout_tabs={serverData.loadout.loadout_tabs} />
        ) : (
          <NoticeBox>Loading...</NoticeBox>
        );
      }}
    />
  );
};

const LoadoutPageInner = (props: { loadout_tabs: LoadoutCategory[] }) => {
  const { loadout_tabs } = props;
  const [searchLoadout, setSearchLoadout] = useState<string>('');
  const [selectedTabName, setSelectedTab] = useState<string>(
    loadout_tabs[0].name,
  );

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section
          title="Loadout Categories"
          align="center"
          buttons={
            <Input
              width="200px"
              onInput={(_, value) => setSearchLoadout(value)}
              placeholder="Search for item"
              value={searchLoadout}
            />
          }
        >
          <Tabs fluid align="center">
            {loadout_tabs.map((curTab) => (
              <Tabs.Tab
                key={curTab.name}
                selected={
                  searchLoadout.length <= 1 && curTab.name === selectedTabName
                }
                onClick={() => {
                  setSelectedTab(curTab.name);
                  setSearchLoadout('');
                }}
              >
                {curTab.name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <LoadoutTabs
          loadout_tabs={loadout_tabs}
          currentTab={selectedTabName}
          currentSearch={searchLoadout}
        />
      </Stack.Item>
    </Stack>
  );
};

const LoadoutListIncludes = (
  list: Record<string, Record<string, string> | []>,
  path: string,
) => {
  if (!list) {
    return false;
  }
  return list[path] !== undefined;
};

const ItemDisplay = (props: { item: LoadoutItem; active: boolean }) => {
  const { act } = useBackend<LoadoutItem>();
  const { item, active } = props;
  return (
    <Stack>
      <Stack.Item grow align="left" style={{ textTransform: 'capitalize' }}>
        {item.name}
      </Stack.Item>
      {item.buttons.map((button) => (
        <Stack.Item key={button.act_key}>
          <Button
            icon={button.icon}
            tooltip={button.tooltip}
            disabled={button.act_key === undefined}
            onClick={() =>
              act('pass_to_loadout_item', {
                path: item.path,
                subaction: button.act_key,
              })
            }
          />
        </Stack.Item>
      ))}
      <Stack.Item>
        <Button.Checkbox
          checked={active}
          fluid
          onClick={() =>
            act('select_item', {
              path: item.path,
              deselect: active,
            })
          }
        >
          Select
        </Button.Checkbox>
      </Stack.Item>
    </Stack>
  );
};

const LoadoutTabDisplay = (props: {
  category: LoadoutCategory | undefined;
}) => {
  const { data } = useBackend<Data>();
  const { category } = props;
  if (!category) {
    return (
      <Stack.Item>
        <NoticeBox>
          Erroneous category detected! This is a bug, please report it.
        </NoticeBox>
      </Stack.Item>
    );
  }

  return (
    <>
      {category.contents.map((item) => (
        <Stack.Item key={item.name}>
          <ItemDisplay
            item={item}
            active={LoadoutListIncludes(
              data.character_preferences.misc.loadout_list,
              item.path,
            )}
          />
        </Stack.Item>
      ))}
    </>
  );
};

const SearchDisplay = (props: {
  loadout_tabs: LoadoutCategory[];
  currentSearch: string;
}) => {
  const { data } = useBackend<Data>();
  const { loadout_tabs, currentSearch } = props;

  const allLoadoutItems = () => {
    const concatItems: LoadoutItem[] = [];
    for (const tab of loadout_tabs) {
      for (const item of tab.contents) {
        concatItems.push(item);
      }
    }
    return concatItems.sort((a, b) => a.name.localeCompare(b.name));
  };
  const validLoadoutItems = allLoadoutItems().filter((item) =>
    item.name.toLowerCase().includes(currentSearch.toLowerCase()),
  );

  if (validLoadoutItems.length === 0) {
    return (
      <Stack.Item>
        <NoticeBox>No items found!</NoticeBox>
      </Stack.Item>
    );
  }

  return (
    <>
      {validLoadoutItems.map((item) => (
        <Stack.Item key={item.name}>
          <ItemDisplay
            item={item}
            active={LoadoutListIncludes(
              data.character_preferences.misc.loadout_list,
              item.path,
            )}
          />
        </Stack.Item>
      ))}
    </>
  );
};

const LoadoutTabs = (props: {
  loadout_tabs: LoadoutCategory[];
  currentTab: string;
  currentSearch: string;
}) => {
  const { act } = useBackend<Data>();
  const { loadout_tabs, currentTab, currentSearch } = props;
  const activeCategory = loadout_tabs.find((curTab) => {
    return curTab.name === currentTab;
  });
  const searching = currentSearch.length > 1;

  return (
    <Stack fill>
      <Stack.Item grow align="center">
        <LoadoutPreviewSection />
      </Stack.Item>
      <Stack.Item grow>
        {searching || (activeCategory && activeCategory.contents) ? (
          <Section
            title={
              searching ? 'Searching...' : activeCategory?.title || 'Error'
            }
            fill
            scrollable
            buttons={
              <Button.Confirm
                icon="times"
                color="red"
                align="center"
                tooltip="Clears ALL selected items from all categories."
                onClick={() => act('clear_all_items')}
              >
                Clear All Items
              </Button.Confirm>
            }
          >
            <Stack vertical>
              {searching ? (
                <SearchDisplay
                  loadout_tabs={loadout_tabs}
                  currentSearch={currentSearch}
                />
              ) : (
                <LoadoutTabDisplay category={activeCategory} />
              )}
            </Stack>
          </Section>
        ) : (
          <Section fill>
            <Box>No contents for selected tab.</Box>
          </Section>
        )}
      </Stack.Item>
    </Stack>
  );
};

const LoadoutPreviewSection = () => {
  const { act, data } = useBackend<Data>();
  const { job_clothes, loadout_preview_view } = data;

  return (
    <Section
      title={`Preview: ${data.character_preferences.names.real_name}`}
      height="100%"
      buttons={
        <Button.Checkbox
          align="center"
          content="Toggle Job Clothes"
          checked={job_clothes}
          onClick={() => act('toggle_job_clothes')}
        />
      }
    >
      {/* The heights on these sections are fucked, whatever fix it later */}
      <Stack vertical height="500px">
        <Stack.Item grow align="center">
          <CharacterPreview height="100%" id={loadout_preview_view} />
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item align="center">
          <Stack>
            <Stack.Item>
              <Button
                icon="chevron-left"
                onClick={() =>
                  act('rotate_dummy', {
                    dir: 'left',
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="chevron-right"
                onClick={() =>
                  act('rotate_dummy', {
                    dir: 'right',
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
