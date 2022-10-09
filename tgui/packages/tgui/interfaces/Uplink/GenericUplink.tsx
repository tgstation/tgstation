import { BooleanLike } from 'common/react';
import { useLocalState, useSharedState } from '../../backend';
import { Box, Button, Input, Section, Tabs, NoticeBox, Stack } from '../../components';

type GenericUplinkProps = {
  currency?: string | JSX.Element;
  categories: string[];
  items: Item[];

  handleBuy: (item: Item) => void;
};

export const GenericUplink = (props: GenericUplinkProps, context) => {
  const {
    currency = 'cr',
    categories,

    handleBuy,
  } = props;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [selectedCategory, setSelectedCategory] = useLocalState(
    context,
    'category',
    categories[0]
  );
  const [compactMode, setCompactMode] = useSharedState(
    context,
    'compactModeUplink',
    false
  );
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
            content={compactMode ? 'Compact' : 'Detailed'}
            onClick={() => setCompactMode(!compactMode)}
          />
        </>
      }>
      <Stack>
        {searchText.length === 0 && (
          <Stack.Item mr={1}>
            <Tabs vertical>
              {categories.map((category) => (
                <Tabs.Tab
                  key={category}
                  selected={category === selectedCategory}
                  onClick={() => setSelectedCategory(category)}>
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

export type Item<ItemData = {}> = {
  id: string | number;
  name: string;
  category: string;
  cost: JSX.Element | string;
  desc: JSX.Element | string;
  disabled: BooleanLike;
  extraData?: ItemData;
};

export type ItemListProps = {
  compactMode: BooleanLike;
  items: Item[];

  handleBuy: (item: Item) => void;
};

const ItemList = (props: ItemListProps, context: any) => {
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
            }>
            {compactMode ? null : item.desc}
          </Section>
        </Stack.Item>
      ))}
    </Stack>
  );
};
