import { useState } from 'react';
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
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';

type GenericUplinkProps = {
  currency?: string | React.JSX.Element;
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
  const items = props.items.filter((value) => {
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
              <Stack.Item grow>
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
              onChange={setSearchText}
              fluid
            />
          </Stack.Item>
          <Stack.Item grow>
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
      <Stack.Item grow>
        <Box height="100%" pr={1} mr={-1}>
          {items.length === 0 ? (
            <NoticeBox>
              {searchText.length === 0
                ? 'No items in this category.'
                : 'No results found.'}
            </NoticeBox>
          ) : (
            <ItemList
              compactMode={searchText.length > 0 || compactMode}
              items={items}
              handleBuy={handleBuy}
            />
          )}
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
  cost: React.JSX.Element | string;
  desc: React.JSX.Element | string;
  population_tooltip: string;
  insufficient_population: BooleanLike;
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
    <Section fill scrollable>
      <Stack vertical mt={compactMode ? -0.5 : -1}>
        {items.map((item, index) => (
          <Stack.Item key={index} mt={compactMode ? 0.5 : 1}>
            <Section key={item.name} fitted={!!compactMode}>
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
                <Stack.Item grow>
                  {compactMode ? (
                    <Stack>
                      <Stack.Item
                        bold
                        grow
                        lineHeight="36px"
                        style={{
                          overflow: 'hidden',
                          whiteSpace: 'nowrap',
                          textOverflow: 'ellipsis',
                          opacity: item.insufficient_population ? '0.5' : '1',
                        }}
                      >
                        {item.insufficient_population ? (
                          <Tooltip content={item.population_tooltip}>
                            <Box>
                              <Icon mr="8px" name="lock" lineHeight="36px" />
                              {item.name}
                            </Box>
                          </Tooltip>
                        ) : (
                          item.name
                        )}
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
                      {item.insufficient_population ? (
                        <Box
                          mt="-12px"
                          mb="-6px"
                          style={{
                            opacity: '0.5',
                          }}
                        >
                          <Icon name="lock" lineHeight="36px" />{' '}
                          {item.population_tooltip}
                        </Box>
                      ) : (
                        ''
                      )}

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
    </Section>
  );
};
