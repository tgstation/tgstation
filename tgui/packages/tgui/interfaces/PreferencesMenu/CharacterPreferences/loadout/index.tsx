import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { CharacterPreview } from 'tgui/interfaces/common/CharacterPreview';
import {
  Box,
  Button,
  Icon,
  ImageButton,
  Input,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useServerPrefs } from '../../useServerPrefs';
import type {
  LoadoutCategory,
  LoadoutItem,
  LoadoutManagerData,
  typePath,
} from './base';
import { LoadoutTabDisplay, SearchDisplay } from './ItemDisplay';
import { LoadoutModifyDimmer } from './ModifyPanel';

export function LoadoutPage(props) {
  const serverData = useServerPrefs();
  const loadout_tabs = serverData?.loadout.loadout_tabs || [];

  const [searchLoadout, setSearchLoadout] = useState('');
  const [selectedTabName, setSelectedTab] = useState(
    loadout_tabs?.[0].name || '',
  );
  const [modifyItemDimmer, setModifyItemDimmer] = useState<LoadoutItem | null>(
    null,
  );

  if (!serverData) {
    return <NoticeBox>Загрузка...</NoticeBox>;
  }

  return (
    <Stack vertical fill>
      <Stack.Item>
        {!!modifyItemDimmer && (
          <LoadoutModifyDimmer
            modifyItemDimmer={modifyItemDimmer}
            setModifyItemDimmer={setModifyItemDimmer}
          />
        )}
        <Section
          fitted
          title="Категории"
          buttons={
            <Input
              width="200px"
              onChange={setSearchLoadout}
              placeholder="Поиск по названию..."
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
                <Stack g={0} vertical textAlign="center">
                  {curTab.category_icon && (
                    <Stack.Item>
                      <Icon name={curTab.category_icon} />
                    </Stack.Item>
                  )}
                  <Stack.Item>{curTab.name}</Stack.Item>
                </Stack>
              </Tabs.Tab>
            ))}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
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
}

type LoadoutTabsProps = {
  loadout_tabs: LoadoutCategory[];
  currentTab: string;
  currentSearch: string;
  modifyItemDimmer: LoadoutItem | null;
  setModifyItemDimmer: (dimmer: LoadoutItem | null) => void;
};

function LoadoutTabs(props: LoadoutTabsProps) {
  const { data } = useBackend<LoadoutManagerData>();
  const { loadout_leftpoints, loadout_maxpoints } = data;
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
  const leftPoints = loadout_leftpoints || 0;

  return (
    <Stack fill>
      <Stack.Item width="calc(220px + 1rem)" height="100%" align="center">
        <Stack vertical fill>
          <Stack.Item height="calc(220px + 5rem)">
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
            title={searching ? 'Результаты поиска' : 'Каталог'}
            fill
            scrollable
            buttons={
              <Stack align="center">
                {activeCategory?.category_info && (
                  <Stack.Item italic>{activeCategory.category_info}</Stack.Item>
                )}
                <Stack.Item>
                  <ProgressBar
                    width={15}
                    minValue={0}
                    value={leftPoints}
                    maxValue={loadout_maxpoints}
                    ranges={{
                      good: [0.5 * loadout_maxpoints, 1 * loadout_maxpoints],
                      average: [
                        0.25 * loadout_maxpoints,
                        0.5 * loadout_maxpoints,
                      ],
                      bad: [0, 0.25 * loadout_maxpoints],
                    }}
                  >
                    Осталось очков: {leftPoints} / {loadout_maxpoints}
                  </ProgressBar>
                </Stack.Item>
              </Stack>
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
            <Box>Нет содержимого для данной категории.</Box>
          </Section>
        )}
      </Stack.Item>
    </Stack>
  );
}

function typepathToLoadoutItem(
  typepath: typePath,
  all_tabs: LoadoutCategory[],
) {
  // Maybe a bit inefficient, could be replaced with a hashmap?
  for (const tab of all_tabs) {
    for (const item of tab.contents) {
      if (item.path === typepath) {
        return item;
      }
    }
  }
  return null;
}

type LoadoutSelectedItemProps = {
  path: typePath;
  all_tabs: LoadoutCategory[];
  setModifyItemDimmer: (dimmer: LoadoutItem | null) => void;
};

function LoadoutSelectedItem(props: LoadoutSelectedItemProps) {
  const { all_tabs, path, setModifyItemDimmer } = props;
  const { act } = useBackend();

  const item = typepathToLoadoutItem(path, all_tabs);
  if (!item) {
    return null;
  }

  return (
    <ImageButton
      fluid
      textAlign="left"
      imageSize={32}
      dmIcon={item.icon}
      dmIconState={item.icon_state}
      buttonsAlt={
        <>
          {!!item.buttons.length && (
            <Button
              icon="cogs"
              color="transparent"
              onClick={() => {
                setModifyItemDimmer(item);
              }}
            />
          )}
          <Button
            icon="times"
            color="transparent"
            textColor="red"
            onClick={() => act('select_item', { path: path, deselect: true })}
          />
        </>
      }
    >
      {item.name}
    </ImageButton>
  );
}

type LoadoutSelectedSectionProps = {
  all_tabs: LoadoutCategory[];
  modifyItemDimmer: LoadoutItem | null;
  setModifyItemDimmer: (dimmer: LoadoutItem | null) => void;
};

function LoadoutSelectedSection(props: LoadoutSelectedSectionProps) {
  const { act, data } = useBackend<LoadoutManagerData>();
  const { loadout_list } = data.character_preferences.misc;
  const { all_tabs, modifyItemDimmer, setModifyItemDimmer } = props;
  return (
    <Section
      title="Выбранные предметы"
      scrollable
      fill
      buttons={
        <Button.Confirm
          color="red"
          icon="trash-can"
          disabled={!loadout_list || Object.keys(loadout_list).length === 0}
          tooltip="Очистить выбранные предметы."
          tooltipPosition="bottom-end"
          onClick={() => act('clear_all_items')}
        />
      }
    >
      {loadout_list &&
        Object.entries(loadout_list).map(([path, item]) => (
          <LoadoutSelectedItem
            key={path}
            path={path}
            all_tabs={all_tabs}
            setModifyItemDimmer={setModifyItemDimmer}
          />
        ))}
    </Section>
  );
}

function LoadoutPreviewSection() {
  const { act, data } = useBackend<LoadoutManagerData>();

  return (
    <Section
      fill
      title="Превью"
      buttons={
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
          <Stack.Item>
            <Button
              align="center"
              selected={data.job_clothes}
              color="transparent"
              icon="user-tie"
              tooltip="Показывать профессию"
              tooltipPosition="left"
              onClick={() => act('toggle_job_clothes')}
            />
          </Stack.Item>
        </Stack>
      }
    >
      <Stack vertical fill>
        <Stack.Item grow align="center">
          <CharacterPreview height="100%" id={data.character_preview_view} />
        </Stack.Item>
      </Stack>
    </Section>
  );
}
