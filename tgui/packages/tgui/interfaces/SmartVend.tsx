import { BooleanLike } from 'common/react';
import { createSearch } from 'common/string';
import { useState } from 'react';
import { DmIcon, Icon } from 'tgui-core/components';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Input,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type Item = {
  path: string;
  name: string;
  amount: number;
  icon: string;
  icon_state: string;
};

type Data = {
  contents: Record<string, Item>;
  name: string;
  isdryer: BooleanLike;
  drying: BooleanLike;
  default_list_view: BooleanLike;
};

enum MODE {
  tile,
  list,
}

export const SmartVend = (props) => {
  const { act, data } = useBackend<Data>();
  const [searchText, setSearchText] = useState('');
  const [displayMode, setDisplayMode] = useState(
    data.default_list_view ? MODE.list : MODE.tile,
  );
  const search = createSearch(searchText, (item: Item) => item.name);
  const contents =
    searchText.length > 0
      ? Object.values(data.contents).filter(search)
      : Object.values(data.contents);
  return (
    <Window width={498} height={550}>
      <Window.Content>
        <Section
          fill
          scrollable
          title="Storage"
          buttons={
            data.isdryer ? (
              <Button
                icon={data.drying ? 'stop' : 'tint'}
                onClick={() => act('Dry')}
              >
                {data.drying ? 'Stop drying' : 'Dry'}
              </Button>
            ) : (
              <>
                <Input
                  autoFocus
                  placeholder={'Search...'}
                  value={searchText}
                  onInput={(e, value) => setSearchText(value)}
                />
                <Button
                  icon={displayMode === MODE.tile ? 'list' : 'border-all'}
                  tooltip={
                    displayMode === MODE.tile
                      ? 'Display as a list'
                      : 'Display as a grid'
                  }
                  tooltipPosition="bottom"
                  onClick={() =>
                    setDisplayMode(
                      displayMode === MODE.tile ? MODE.list : MODE.tile,
                    )
                  }
                />
              </>
            )
          }
        >
          {!contents.length ? (
            <NoticeBox>Nothing found.</NoticeBox>
          ) : (
            contents.map((item) =>
              displayMode === MODE.tile ? (
                <ItemTile key={item.path} item={item} />
              ) : (
                <ItemList key={item.path} item={item} />
              ),
            )
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

const ItemTile = ({ item }) => {
  const { act } = useBackend<Data>();
  const fallback = (
    <Icon name="spinner" lineHeight="64px" size={3} spin color="gray" />
  );
  return (
    <Box m={1} p={0} inline width="64px">
      <Button
        p={0}
        height="64px"
        width="64px"
        tooltip={item.name}
        tooltipPosition="bottom"
        textAlign="right"
        disabled={item.amount < 1}
        onClick={() =>
          act('Release', {
            path: item.path,
            amount: 1,
          })
        }
      >
        <DmIcon
          fallback={fallback}
          icon={item.icon}
          icon_state={item.icon_state}
          height="64px"
          width="64px"
        />
        {item.amount > 1 && (
          <Button
            color="transparent"
            minWidth="24px"
            height="24px"
            lineHeight="24px"
            textAlign="center"
            position="absolute"
            left="0"
            bottom="0"
            fontWeight="bold"
            fontSize="14px"
            onClick={(e) => {
              act('Release', {
                path: item.path,
                amount: item.amount,
              });
              e.stopPropagation();
            }}
          >
            {item.amount}
          </Button>
        )}
      </Button>
      <Box
        style={{
          overflow: 'hidden',
          whiteSpace: 'nowrap',
          textOverflow: 'ellipsis',
          textAlign: 'center',
        }}
      >
        {item.name}
      </Box>
    </Box>
  ) as any;
};

const ItemList = ({ item }) => {
  const { act } = useBackend<Data>();
  const fallback = (
    <Icon name="spinner" lineHeight="32px" size={3} spin color="gray" />
  );
  const [itemCount, setItemCount] = useState(1);
  return (
    <Stack>
      <Stack.Item>
        <Button
          p={0}
          m={0}
          color="transparent"
          width="32px"
          height="32px"
          onClick={() =>
            act('Release', {
              path: item.path,
              amount: 1,
            })
          }
        >
          <DmIcon
            fallback={fallback}
            icon={item.icon}
            icon_state={item.icon_state}
          />
        </Button>
      </Stack.Item>
      <Stack.Item
        style={{
          overflow: 'hidden',
          whiteSpace: 'nowrap',
          textOverflow: 'ellipsis',
          lineHeight: '32px',
        }}
      >
        {item.name}
      </Stack.Item>
      <Stack.Item
        grow
        style={{
          overflow: 'hidden',
          whiteSpace: 'nowrap',
          textOverflow: 'ellipsis',
          lineHeight: '32px',
        }}
      >
        <Box
          style={{
            marginTop: '20px',
            borderBottom: '1px dotted gray',
          }}
        />
      </Stack.Item>
      {item.amount > 1 && (
        <Stack.Item
          style={{
            lineHeight: '32px',
          }}
        >
          {`x${item.amount}`}
        </Stack.Item>
      )}
      <Stack.Item>
        <Button
          py="4px"
          mt="4px"
          height="24px"
          lineHeight="16px"
          onClick={() =>
            act('Release', {
              path: item.path,
              amount: itemCount,
            })
          }
        >
          Vend
        </Button>
        <NumberInput
          width="25px"
          minValue={1}
          maxValue={item.amount}
          step={1}
          value={itemCount}
          onChange={(value) => setItemCount(value)}
        />
      </Stack.Item>
    </Stack>
  ) as any;
};
