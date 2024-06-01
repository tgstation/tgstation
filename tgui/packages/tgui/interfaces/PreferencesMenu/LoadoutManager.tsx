import { useState } from 'react';

import { BooleanLike } from '../../../common/react';
import { useBackend } from '../../backend';
import {
  Box,
  Button,
  Dimmer,
  Divider,
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
import { PreferencesMenuData, ServerData } from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

// Generic types
type DmIconFile = string;
type DmIconState = string;
type FAIcon = string;
type typePath = string;

// Info about a loadout item (key to info, such as color, reskin, layer, etc)
type LoadoutListInfo = Record<string, string> | [];
// Typepath to info about the item
export type LoadoutList = Record<typePath, LoadoutListInfo>;

// Used in LoadoutButton to make non-standard buttons
enum LoadoutButtonTypes {
  Checkbox = 'checkbox',
  IconList = 'icon_button_list',
}

type LoadoutCheckboxButton = LoadoutButton & {
  enable_text?: string;
  disable_text?: string;
};

type LoadoutIconListButton = LoadoutButton & {
  button_icons: LoadoutIconListSubbutton[];
};

// Used in LoadoutIconListButton to make sub-buttons with icons
type LoadoutIconListSubbutton = {
  tooltip?: string;
  sub_icon: DmIconFile;
  sub_icon_state: DmIconState;
};

// Used in LoadoutItem to make buttons relating to how an item can be edited
type LoadoutButton = {
  label: string;
  act_key?: string;
  button_type?: LoadoutButtonTypes;
  button_icon?: FAIcon;
};

// Actual item passed in from the loadout
type LoadoutItem = {
  name: string;
  path: typePath;
  icon: DmIconFile | null;
  icon_state: DmIconState | null;
  buttons: LoadoutButton[];
  information: string[];
};

// Category of items in the loadout
type LoadoutCategory = {
  name: string;
  category_icon: FAIcon | null;
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
        const loadoutServerData: ServerData = serverData;
        return (
          <LoadoutPageInner
            loadout_tabs={loadoutServerData.loadout.loadout_tabs}
          />
        );
      }}
    />
  );
};

const LoadoutPageInner = (props: { loadout_tabs: LoadoutCategory[] }) => {
  const { loadout_tabs } = props;
  const [searchLoadout, setSearchLoadout] = useState('');
  const [selectedTabName, setSelectedTab] = useState(loadout_tabs[0].name);
  const [modifyItemDimmer, setModifyItemDimmer] = useState(false);

  return (
    <Stack vertical fill>
      <Stack.Item>
        {!!modifyItemDimmer && (
          <Dimmer style={{ zIndex: '100' }}>
            <Button
              onClick={() => {
                setModifyItemDimmer(false);
              }}
            >
              Done
            </Button>
          </Dimmer>
        )}
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
                icon={curTab.category_icon}
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
          modifyItemDimmer={modifyItemDimmer}
          setModifyItemDimmer={setModifyItemDimmer}
        />
      </Stack.Item>
    </Stack>
  );
};

const ItemIcon = (props: { item: LoadoutItem; scale?: number }) => {
  const { item, scale = 3 } = props;
  const icon_to_use = item.icon;
  const icon_state_to_use = item.icon_state;

  if (!icon_to_use || !icon_state_to_use) {
    return (
      <Icon
        name="question"
        size={Math.round(scale * 2.5)}
        color="red"
        style={{
          transform: `translateX(${scale * 2}px) translateY(${scale * 2}px)`,
        }}
      />
    );
  }

  return (
    <DmIcon
      fallback={<Icon name="spinner" spin color="gray" />}
      icon={icon_to_use}
      icon_state={icon_state_to_use}
      style={{
        transform: `scale(${scale}) translateX(${scale * 3}px) translateY(${scale * 3}px)`,
      }}
    />
  );
};

const ItemDisplay = (props: {
  active: boolean;
  item: LoadoutItem | null;
  scale?: number;
}) => {
  const { act } = useBackend<LoadoutItem>();
  const { active, item, scale = 3 } = props;
  if (!item) {
    // This is an error
    return null;
  }

  const box_size = `${scale * 32}px`;

  return (
    <Button
      height={box_size}
      width={box_size}
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
      <Flex vertical>
        <Flex.Item>
          <ItemIcon item={item} scale={scale} />
        </Flex.Item>
        {item.information.length > 0 && (
          <Flex.Item ml={-5.5} style={{ zIndex: '3' }}>
            {item.information.map((info) => (
              <Box
                height="9px"
                key={info}
                fontSize="9px"
                textColor={'darkgray'}
              >
                {info}
              </Box>
            ))}
          </Flex.Item>
        )}
      </Flex>
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
  modifyItemDimmer: boolean;
  setModifyItemDimmer: (dimmer: boolean) => void;
}) => {
  const {
    loadout_tabs,
    currentTab,
    currentSearch,
    modifyItemDimmer,
    setModifyItemDimmer,
  } = props;
  const activeCategory = loadout_tabs.find((curTab) => {
    return curTab.name === currentTab;
  });
  const searching = currentSearch.length > 1;

  return (
    <Stack fill height="550px">
      <Stack.Item align="center" width="250px" height="100%">
        <Stack vertical height="100%">
          <Stack.Item height="60%">
            <LoadoutPreviewSection />
          </Stack.Item>
          <Stack.Item grow>
            <LoadoutSelectedSection
              all_tabs={loadout_tabs}
              modifyItemDimmer={modifyItemDimmer}
              setModifyItemDimmer={setModifyItemDimmer}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        {searching || activeCategory?.contents ? (
          <Section
            title={searching ? 'Searching...' : 'Catalog'}
            fill
            scrollable
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

// Melbert todo : replace this with a hashmap
const TypepathToLoadoutItem = (
  typepath: typePath,
  all_tabs: LoadoutCategory[],
) => {
  for (const tab of all_tabs) {
    for (const item of tab.contents) {
      if (item.path === typepath) {
        return item;
      }
    }
  }
  return null;
};

const LoadoutSelectedItem = (props: {
  key: string;
  path: typePath;
  all_tabs: LoadoutCategory[];
  modifyItemDimmer: boolean;
  setModifyItemDimmer: (dimmer: boolean) => void;
}) => {
  const { all_tabs, path, key, modifyItemDimmer, setModifyItemDimmer } = props;
  const { act } = useBackend<LoadoutManagerData>();

  const item = TypepathToLoadoutItem(path, all_tabs);
  if (!item) {
    return null;
  }

  return (
    <Stack key={key} align={'center'}>
      <Stack.Item>
        <ItemIcon item={item} scale={1} />
      </Stack.Item>
      <Stack.Item width="55%">{item.name}</Stack.Item>
      {item.buttons.length ? (
        <Stack.Item>
          <Button
            color="none"
            width="32px"
            onClick={() => {
              setModifyItemDimmer(true);
            }}
          >
            <Icon size={1.8} name="cogs" color="grey" />
          </Button>
        </Stack.Item>
      ) : (
        <Stack.Item width="32px" />
      )}
      <Stack.Item>
        <Button
          color="none"
          width="32px"
          onClick={() => act('select_item', { path: path, deselect: true })}
        >
          <Icon size={2.4} name="times" color="red" />
        </Button>
      </Stack.Item>
    </Stack>
  );
};

const LoadoutSelectedSection = (props: {
  all_tabs: LoadoutCategory[];
  modifyItemDimmer: boolean;
  setModifyItemDimmer: (dimmer: boolean) => void;
}) => {
  const { act, data } = useBackend<LoadoutManagerData>();
  const { loadout_list } = data.character_preferences.misc;
  const { all_tabs, modifyItemDimmer, setModifyItemDimmer } = props;

  return (
    <Section
      title="Selected"
      scrollable
      fill
      buttons={
        <Button.Confirm
          icon="times"
          color="red"
          align="center"
          disabled={!loadout_list || Object.keys(loadout_list).length === 0}
          tooltip="Clears ALL selected items from all categories."
          onClick={() => act('clear_all_items')}
        >
          Clear All
        </Button.Confirm>
      }
    >
      {loadout_list &&
        Object.entries(loadout_list).map(([path, item]) => (
          <>
            <LoadoutSelectedItem
              key={path}
              path={path}
              all_tabs={all_tabs}
              modifyItemDimmer={modifyItemDimmer}
              setModifyItemDimmer={setModifyItemDimmer}
            />
            <Divider />
          </>
        ))}
    </Section>
  );
};

const LoadoutPreviewSection = () => {
  const { act, data } = useBackend<LoadoutManagerData>();

  return (
    <Section
      fill
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
      <Stack vertical height="100%">
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
