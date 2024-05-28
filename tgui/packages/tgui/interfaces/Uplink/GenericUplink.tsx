import { BooleanLike } from 'common/react';
import { useState } from 'react';

import {
  Box,
  Button,
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
    <Section
      title={<Box inline>{currency}</Box>}
      buttons={
        <>
          Search
          <Input
            autoFocus
            value={searchText}
            onInput={(e, value) => setSearchText(value)}
            mx={1}
          />
          <Button
            icon={compactMode ? 'list' : 'info'}
            onClick={() => setCompactMode(!compactMode)}
          >
            {compactMode ? 'Compact' : 'Detailed'}
          </Button>
        </>
      }
    >
      <Stack>
        {searchText.length === 0 && (
          <Stack.Item mr={1}>
            <Tabs vertical>
              {categories.map((category) => (
                <Tabs.Tab
                  key={category}
                  selected={category === selectedCategory}
                  onClick={() => setSelectedCategory(category)}
                >
                  {category}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
        )}
        <Stack.Item grow={1}>
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
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export type Item = {
  id: string | number;
  name: string;
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
  return (
    <Stack vertical>
      {items.map((item, index) => (
        <Stack.Item key={index}>
          <Section
            key={item.name}
            title={item.name}
            buttons={
              <Button
                content={item.cost}
                disabled={item.disabled}
                onClick={(e) => handleBuy(item)}
              />
            }
          >
            {compactMode ? null : item.desc}
          </Section>
        </Stack.Item>
      ))}
    </Stack>
  );
};
