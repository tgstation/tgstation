import { BooleanLike } from 'common/react';
import { useState } from 'react';
import { Tooltip } from 'tgui-core/components';

import { useBackend } from '../../backend';
import {
  Box,
  Button,
  DmIcon,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from '../../components';

type GenericUplinkProps = {
  currency?: string | JSX.Element;
  categories: string[];
  items: Item[];
  handleBuy: (item: Item) => void;
};

export const GenericUplink = (props: GenericUplinkProps) => {
  const { act } = useBackend();
  const {
    currency = 'cr',
    categories,

    handleBuy,
  } = props;
  const [searchText, setSearchText] = useState('');
  const [selectedCategory, setSelectedCategory] = useState(categories[0]);
  const [compactMode, setCompactMode] = useState(false);
  let items = props.items.filter((value) => {
    if (searchText.length === 0) {
      return value.category === selectedCategory;
    }
    return value.name.toLowerCase().includes(searchText.toLowerCase());
  });

  return (
    <Stack fill>
      <Stack.Item width="160px">
        <Stack vertical fill>
          <Stack.Item>
            <Stack>
              <Stack.Item grow={1}>
                <Button
                  bold
                  fluid
                  lineHeight={2}
                  style={{
                    overflow: 'hidden',
                    whiteSpace: 'nowrap',
                    textOverflow: 'ellipsis',
                    textAlign: 'center',
                  }}
                  onClick={() => act('buy_raw_tc')}
                >
                  {currency}
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  fluid
                  lineHeight={2}
                  textAlign="center"
                  icon={compactMode ? 'maximize' : 'minimize'}
                  tooltip={compactMode ? 'Detailed view' : 'Compact view'}
                  onClick={() => setCompactMode(!compactMode)}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Input
              autoFocus
              value={searchText}
              placeholder="Search..."
              onInput={(e, value) => setSearchText(value)}
              fluid
            />
          </Stack.Item>
          <Stack.Item grow={1}>
            <Tabs vertical fill>
              {categories.map((category) => (
                <Tabs.Tab
                  py={0.8}
                  key={category}
                  selected={category === selectedCategory}
                  onClick={(e) => {
                    setSelectedCategory(category);
                    if (searchText.length > 0) {
                      setSearchText('');
                    }
                  }}
                >
                  {category}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow={1}>
        <Box height="100%" pr={1} mr={-1} style={{ overflowY: 'auto' }}>
          {items.length === 0 && (
            <NoticeBox>
              {searchText.length === 0
                ? 'No items in this category.'
                : 'No results found.'}
            </NoticeBox>
          )}
          <ItemList
            compactMode={searchText.length > 0 || compactMode}
            items={items}
            handleBuy={handleBuy}
          />
        </Box>
      </Stack.Item>
    </Stack>
  );
};

export type Item = {
  id: string | number;
  name: string;
  icon: string;
  icon_state: string;
  category: string;
  cost: JSX.Element | string;
  desc: JSX.Element | string;
  disabled: BooleanLike;
};

export type ItemListProps = {
  compactMode: BooleanLike;
  items: Item[];

  handleBuy: (item: Item) => void;
};

const ItemList = (props: ItemListProps) => {
  const { compactMode, items, handleBuy } = props;
  const fallback = (
    <Icon m={compactMode ? '10px' : '26px'} name="spinner" spin />
  );
  return (
    <Stack vertical mt={compactMode ? -0.5 : -1}>
      {items.map((item, index) => (
        <Stack.Item key={index} mt={compactMode ? 0.5 : 1}>
          <Section key={item.name} fitted={compactMode ? true : false}>
            <Stack>
              <Stack.Item>
                <Box
                  width={compactMode ? '32px' : '64px'}
                  height={compactMode ? '32px' : '64px'}
                  position="relative"
                  m={compactMode ? '2px' : 0}
                  mr={1}
                >
                  <DmIcon
                    position="absolute"
                    bottom="0"
                    fallback={fallback}
                    icon={item.icon}
                    icon_state={item.icon_state}
                    width={compactMode ? '32px' : '64px'}
                  />
                </Box>
              </Stack.Item>
              <Stack.Item grow={1}>
                {compactMode ? (
                  <Stack>
                    <Stack.Item
                      bold
                      grow={1}
                      lineHeight="36px"
                      style={{
                        overflow: 'hidden',
                        whiteSpace: 'nowrap',
                        textOverflow: 'ellipsis',
                      }}
                    >
                      {item.name}
                    </Stack.Item>
                    <Stack.Item>
                      <Tooltip content={item.desc}>
                        <Icon name="info-circle" lineHeight="36px" />
                      </Tooltip>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        m="8px"
                        disabled={item.disabled}
                        onClick={(e) => handleBuy(item)}
                      >
                        {item.cost}
                      </Button>
                    </Stack.Item>
                  </Stack>
                ) : (
                  <Section
                    title={item.name}
                    buttons={
                      <Button
                        disabled={item.disabled}
                        onClick={(e) => handleBuy(item)}
                      >
                        {item.cost}
                      </Button>
                    }
                  >
                    <Box
                      style={{
                        opacity: '0.75',
                      }}
                    >
                      {item.desc}
                    </Box>
                  </Section>
                )}
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      ))}
    </Stack>
  );
};
