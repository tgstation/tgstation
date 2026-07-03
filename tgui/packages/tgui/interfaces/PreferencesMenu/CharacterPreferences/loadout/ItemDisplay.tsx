import { useBackend } from 'tgui/backend';
import {
  Button,
  DmIcon,
  Icon,
  ImageButton,
  NoticeBox,
  Stack,
} from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import type { LoadoutCategory, LoadoutItem, LoadoutManagerData } from './base';

type Props = {
  item: LoadoutItem;
  scale?: number;
};

export function ItemIcon(props: Props) {
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
        transform: `scale(${scale}) translateX(${scale * 3}px) translateY(${
          scale * 3
        }px)`,
      }}
    />
  );
}

type DisplayProps = {
  active: boolean;
  item: LoadoutItem;
};

export function ItemDisplay(props: DisplayProps) {
  const { act, data } = useBackend<LoadoutManagerData>();
  const { donator_level, loadout_leftpoints } = data;
  const { active, item } = props;

  const costText =
    item.cost === 1
      ? `${item.cost} очко`
      : item.cost < 4
        ? `${item.cost} очка`
        : `${item.cost} очков`;

  const textInfo = (
    <Stack fill fontSize={1.2} textAlign="left">
      <Stack.Item
        grow
        fontSize={1}
        color="gold"
        opacity={0.75}
        style={{ textIndent: '0.25rem' }}
      >
        {item.tier > 0 && `Тир ${item.tier}`}
      </Stack.Item>
      <Stack.Item fontSize={0.75} opacity={0.66}>
        {costText}
      </Stack.Item>
    </Stack>
  );

  function tooltipInfo() {
    const disabledInfo: string[] = [];
    if (!active && loadout_leftpoints === 0) {
      disabledInfo.push('Недостаточно очков.');
    }

    if (item.tier > donator_level) {
      disabledInfo.push(
        'Этот предмет доступен на более высоком уровне подписки чем у вас.',
      );
    }

    return (
      <Stack fill vertical g={0.5}>
        <Stack.Item mb={disabledInfo.length > 0 && 2}>{item.name}</Stack.Item>
        {disabledInfo.length > 0 &&
          disabledInfo.map((info, index) => (
            <>
              {index > 0 && <Stack.Divider />}
              <Stack.Item key={index} color="bad">
                {info}
              </Stack.Item>
            </>
          ))}
      </Stack>
    );
  }

  return (
    <ImageButton
      m={0}
      imageSize={90}
      tooltip={tooltipInfo()}
      tooltipPosition={'bottom-start'}
      dmIcon={item.icon}
      dmIconState={item.icon_state}
      buttons={item.information.map((info) => (
        <Button
          key={info.icon}
          icon={info.icon}
          tooltip={info.tooltip}
          tooltipPosition="top-start"
          color="unset"
          textColor="lightgray"
          fontSize={1.2}
        />
      ))}
      buttonsAlt={textInfo}
      selected={active}
      disabled={
        !active && (loadout_leftpoints === 0 || item.tier > donator_level)
      }
      onClick={() =>
        act('select_item', {
          path: item.path,
          deselect: active,
        })
      }
    >
      <span style={{ textTransform: 'capitalize' }}>{item.name}</span>
    </ImageButton>
  );
}

type ListProps = {
  items: LoadoutItem[];
};

type LoadoutGroup = {
  items: LoadoutItem[];
  title: string;
};

function sortByGroup(items: LoadoutItem[]): LoadoutGroup[] {
  const groups: LoadoutGroup[] = [];

  for (let i = 0; i < items.length; i++) {
    const item: LoadoutItem = items[i];
    let usedGroup: LoadoutGroup | undefined = groups.find(
      (group) => group.title === item.group,
    );
    if (usedGroup === undefined) {
      usedGroup = { items: [], title: item.group };
      groups.push(usedGroup);
    }
    usedGroup.items.push(item);
  }

  return groups;
}

export function ItemListDisplay(props: ListProps) {
  const { data } = useBackend<LoadoutManagerData>();
  const { loadout_list } = data.character_preferences.misc;
  const itemGroups = sortByGroup(props.items);

  return (
    <Stack vertical g={3}>
      {itemGroups.map((group) => (
        <Stack.Item key={group.title}>
          <Stack vertical>
            {itemGroups.length > 1 && (
              <>
                <Stack.Item bold fontSize={1.25} px={1}>
                  {group.title}
                </Stack.Item>
                <Stack.Divider
                  style={{ borderColor: 'var(--color-primary)' }}
                />
              </>
            )}
            <Stack.Item>
              <Stack wrap>
                {group.items
                  .sort((a, b) =>
                    a.tier === b.tier
                      ? a.name.localeCompare(b.name)
                      : a.tier - b.tier,
                  )
                  .map((item) => (
                    <Stack.Item key={item.name}>
                      <ItemDisplay
                        item={item}
                        active={
                          loadout_list && loadout_list[item.path] !== undefined
                        }
                      />
                    </Stack.Item>
                  ))}
              </Stack>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ))}
    </Stack>
  );
}

type TabProps = {
  category: LoadoutCategory | undefined;
};

export function LoadoutTabDisplay(props: TabProps) {
  const { category } = props;
  if (!category) {
    return (
      <NoticeBox>
        Erroneous category detected! This is a bug, please report it.
      </NoticeBox>
    );
  }

  return <ItemListDisplay items={category.contents} />;
}

type SearchProps = {
  loadout_tabs: LoadoutCategory[];
  currentSearch: string;
};

export function SearchDisplay(props: SearchProps) {
  const { loadout_tabs, currentSearch } = props;

  const search = createSearch(
    currentSearch,
    (loadout_item: LoadoutItem) => loadout_item.name,
  );

  const validLoadoutItems = loadout_tabs
    .flatMap((tab) => tab.contents)
    .filter(search)
    .sort((a, b) =>
      a.tier === b.tier ? a.name.localeCompare(b.name) : a.tier - b.tier,
    );

  if (validLoadoutItems.length === 0) {
    return <NoticeBox>No items found!</NoticeBox>;
  }

  return <ItemListDisplay items={validLoadoutItems} />;
}
