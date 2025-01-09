import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  DmIcon,
  Flex,
  Icon,
  NoticeBox,
} from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { LoadoutCategory, LoadoutItem, LoadoutManagerData } from './base';

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
  scale?: number;
};

export function ItemDisplay(props: DisplayProps) {
  const { act } = useBackend();
  const { active, item, scale = 3 } = props;

  const boxSize = `${scale * 32}px`;

  return (
    <Button
      height={boxSize}
      width={boxSize}
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
                bold
              >
                {info}
              </Box>
            ))}
          </Flex.Item>
        )}
      </Flex>
    </Button>
  );
}

type ListProps = {
  items: LoadoutItem[];
};

export function ItemListDisplay(props: ListProps) {
  const { data } = useBackend<LoadoutManagerData>();
  const { loadout_list } = data.character_preferences.misc;

  return (
    <Flex wrap>
      {props.items.map((item) => (
        <Flex.Item key={item.name} mr={2} mb={2}>
          <ItemDisplay
            item={item}
            active={loadout_list && loadout_list[item.path] !== undefined}
          />
        </Flex.Item>
      ))}
    </Flex>
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
    .sort((a, b) => (a.name > b.name ? 1 : -1));

  if (validLoadoutItems.length === 0) {
    return <NoticeBox>No items found!</NoticeBox>;
  }

  return <ItemListDisplay items={validLoadoutItems} />;
}
