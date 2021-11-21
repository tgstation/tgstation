import { BooleanLike } from 'common/react';
import { decodeHtmlEntities } from 'common/string';
import { useLocalState, useSharedState } from '../../backend';
import { Box, Button, Flex, Input, Section, Tabs, NoticeBox, Stack } from '../../components';
import { formatMoney } from '../../format';

type Item = {
  name
}

type GenericUplinkProps = {
  currencyAmount: number,
  currencySymbol: string,
  categories: string[],
  items: Item[],
  lockable: BooleanLike,

  handleLock: (key: MouseEvent) => void;
}

export const GenericUplink = (props: GenericUplinkProps, context) => {
  const {
    currencyAmount = 0,
    currencySymbol = 'cr',
    categories,
    lockable,

    handleLock,
  } = props;
  const [
    searchText, setSearchText,
  ] = useLocalState(context, 'searchText', '');
  const [
    selectedCategory, setSelectedCategory,
  ] = useLocalState(context, 'category', categories[0]);
  const [
    compactMode, setCompactMode,
  ] = useSharedState(context, 'compactModeUplink', false);
  let items = props.items;
  return (
    <Section
      title={(
        <Box
          inline
          color={currencyAmount > 0 ? 'good' : 'bad'}>
          {formatMoney(currencyAmount)} {currencySymbol}
        </Box>
      )}
      buttons={(
        <>
          Search
          <Input
            autoFocus
            value={searchText}
            onInput={(e, value) => setSearchText(value)}
            mx={1} />
          <Button
            icon={compactMode ? 'list' : 'info'}
            content={compactMode ? 'Compact' : 'Detailed'}
            onClick={() => setCompactMode(!compactMode)} />
          {!!lockable && (
            <Button
              icon="lock"
              content="Lock"
              onClick={handleLock} />
          )}
        </>
      )}>
      <Flex>
        {searchText.length === 0 && (
          <Flex.Item>
            <Tabs vertical>
              {categories.map(category => (
                <Tabs.Tab
                  key={category}
                  selected={category === selectedCategory}
                  onClick={() => setSelectedCategory(category)}>
                  {category}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Flex.Item>
        )}
        <Flex.Item grow={1} basis={0}>
          {items.length === 0 && (
            <NoticeBox>
              {searchText.length === 0
                ? 'No items in this category.'
                : 'No results found.'}
            </NoticeBox>
          )}
          <ItemList
            compactMode={searchText.length > 0 || compactMode}
            currencyAmount={currencyAmount}
            currencySymbol={currencySymbol}
            items={items} />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

type Item = {
  cost: number,
  disabled:
}

type ItemListProps = {
  compactMode: BooleanLike,
  currencyAmount: number,
  currencySymbol: string,
  items: Item[],

  handleBuy: (key: MouseEvent) => void;
}

const ItemList = (props: ItemListProps, context) => {
  const {
    compactMode,
    currencyAmount,
    currencySymbol,
    items,
  } = props;
  return (
    <Stack>
      {items.map(item => (
        <Stack.Item>
          <Section
            key={item.name}
            title={item.name}
            buttons={(
              <Button
                content={item.cost + ' ' + currencySymbol}
                disabled={item.disabled}
                onClick={() => handleBuy(item)} />
            )}>
            {compactMode? null : decodeHtmlEntities(item.desc)}
          </Section>
        </Stack.Item>
      ))
    )}
  </Stack>
};
