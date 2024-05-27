import { useState } from 'react';

import { BooleanLike } from '../../../common/react';
import { useBackend } from '../../backend';
import {
  Box,
  Button,
  DmIcon,
  Flex,
  Icon,
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
  only_when_selected?: BooleanLike;
};

type LoadoutItem = {
  name: string;
  path: string; // typepath
  icon: string | null; // dmi
  icon_state: string | null;
  buttons: LoadoutButton[];
};

export type LoadoutCategory = {
  name: string;
  title_postfix: string | null;
  contents: LoadoutItem[];
};

type LoadoutManagerData = PreferencesMenuData & {
  job_clothes: BooleanLike;
};

export const LoadoutPage = () => {
  return (
    <ServerPreferencesFetcher
      render={(serverData) => {
        if (!serverData) {
          return <NoticeBox>Loading...</NoticeBox>;
        }
        const loadout_tabs: LoadoutCategory[] = serverData.loadout
          .loadout_tabs as LoadoutCategory[];
        return <LoadoutPageInner loadout_tabs={loadout_tabs} />;
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
              placeholder="Search for an item..."
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

const ItemIcon = (props: { item: LoadoutItem }) => {
  const { item } = props;
  const icon_to_use = item.icon;
  const icon_state_to_use = item.icon_state;

  if (!icon_to_use || !icon_state_to_use) {
    return (
      <Icon
        name="question"
        size={8}
        color="red"
        style={{ transform: 'translateX(6px) translateY(6px)' }}
      />
    );
  }

  return (
    <DmIcon
      fallback={<Icon name="spinner" spin color="gray" />}
      icon={icon_to_use}
      icon_state={icon_state_to_use}
      style={{ transform: 'scale(3) translateX(10px) translateY(12px)' }}
    />
  );
};

// Is an item showing buttons?
const ShowsButtons = (item: LoadoutItem, active: boolean) => {
  for (const button of item.buttons) {
    if (button.only_when_selected && !active) {
      continue;
    }
    return true;
  }
  return false;
};

const ItemDisplayButton = (props: {
  item: LoadoutItem;
  button: LoadoutButton;
  active: boolean;
}) => {
  const { act } = useBackend<LoadoutItem>();
  const { item, button, active } = props;

  if (button.only_when_selected && !active) {
    return null;
  }

  return (
    <Button
      icon={button.icon}
      height="22px"
      width="22px"
      tooltip={button.tooltip}
      tooltipPosition={'bottom-start'}
      disabled={!button.act_key}
      color="yellow"
      style={{ zIndex: '2' }}
      onClick={(e) => {
        e.stopPropagation();
        act('pass_to_loadout_item', {
          path: item.path,
          subaction: button.act_key,
        });
      }}
    />
  );
};

const ItemDisplayButtons = (props: { item: LoadoutItem; active: boolean }) => {
  const { item, active } = props;
  const buttons = item.buttons;
  return (
    <Flex>
      {buttons.map((button) => (
        <Flex.Item key={button.act_key} mr={1}>
          <ItemDisplayButton item={item} button={button} active={active} />
        </Flex.Item>
      ))}
    </Flex>
  );
};

const ItemDisplay = (props: { item: LoadoutItem; active: boolean }) => {
  const { act } = useBackend<LoadoutItem>();
  const { item, active } = props;
  return (
    <Button
      height="100px"
      width="100px"
      color={active ? 'green' : 'default'}
      style={{ textTransform: 'capitalize', zIndex: '1' }}
      tooltip={item.name}
      tooltipPosition={'bottom'}
      onClick={() =>
        act('select_item', {
          path: item.path,
          deselect: active,
        })
      }
    >
      <Stack vertical>
        <Stack.Item ml={-1}>
          <ItemDisplayButtons item={item} active={active} />
        </Stack.Item>
        <Stack.Item mt={ShowsButtons(item, active) ? -4 : 0}>
          <ItemIcon item={item} />
        </Stack.Item>
      </Stack>
    </Button>
  );
};

const ItemListDisplay = (props: { items: LoadoutItem[] }) => {
  const { data } = useBackend<LoadoutManagerData>();
  const loadout = data.character_preferences.misc.loadout_list;
  return (
    <Flex wrap>
      {props.items.map((item) => (
        <Flex.Item key={item.name} mr={2} mb={2}>
          <ItemDisplay
            item={item}
            active={loadout && loadout[item.path] !== undefined}
          />
        </Flex.Item>
      ))}
    </Flex>
  );
};

const LoadoutTabDisplay = (props: {
  category: LoadoutCategory | undefined;
}) => {
  const { category } = props;
  if (!category) {
    return (
      <NoticeBox>
        Erroneous category detected! This is a bug, please report it.
      </NoticeBox>
    );
  }

  return <ItemListDisplay items={category.contents} />;
};

const SearchDisplay = (props: {
  loadout_tabs: LoadoutCategory[];
  currentSearch: string;
}) => {
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
    return <NoticeBox>No items found!</NoticeBox>;
  }

  return <ItemListDisplay items={validLoadoutItems} />;
};

const LoadoutTabs = (props: {
  loadout_tabs: LoadoutCategory[];
  currentTab: string;
  currentSearch: string;
}) => {
  const { act } = useBackend<LoadoutManagerData>();
  const { loadout_tabs, currentTab, currentSearch } = props;
  const activeCategory = loadout_tabs.find((curTab) => {
    return curTab.name === currentTab;
  });
  const searching = currentSearch.length > 1;

  const formatName = (category: LoadoutCategory | undefined) => {
    if (!category) {
      return 'No category selected';
    }
    if (category.title_postfix) {
      return `Catalog (${category.title_postfix})`;
    }
    return 'Catalog';
  };

  return (
    <Stack fill>
      <Stack.Item align="center" width="250px">
        <LoadoutPreviewSection />
      </Stack.Item>
      <Stack.Item grow>
        {searching || activeCategory?.contents ? (
          <Section
            title={searching ? 'Searching...' : formatName(activeCategory)}
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
              <Stack.Item>
                {searching ? (
                  <SearchDisplay
                    loadout_tabs={loadout_tabs}
                    currentSearch={currentSearch}
                  />
                ) : (
                  <LoadoutTabDisplay category={activeCategory} />
                )}
              </Stack.Item>
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
  const { act, data } = useBackend<LoadoutManagerData>();

  return (
    <Section
      height="100%"
      title="Preview"
      buttons={
        <Button.Checkbox
          align="center"
          checked={data.job_clothes}
          onClick={() => act('toggle_job_clothes')}
        >
          Job Clothes
        </Button.Checkbox>
      }
    >
      <Stack vertical height="500px">
        <Stack.Item grow align="center">
          <CharacterPreview height="100%" id={data.character_preview_view} />
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
