import { createSearch, decodeHtmlEntities } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Input, Section, Table, Tabs, NoticeBox, LabeledList } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

const MAX_SEARCH_RESULTS = 25;

export const Biogenerator = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    biomass,
    beaker,
    processing,
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section
          title="Container"
          buttons={
            <Button
              icon="times"
              content="Activate"
              disabled={!beaker || processing}
              onClick={() => act('activate')} />
          }>
          <LabeledList label="Container">
            <Button
              icon="eject"
              content="Eject"
              disabled={!beaker || processing}
              onClick={() => act('detach')} />
          </LabeledList>
        </Section>
        <GenericMachine
          currencyAmount={biomass}
          currencySymbol="BIO" />
      </Window.Content>
    </Window>
  );
};

export const GenericMachine = (props, context) => {
  const {
    currencyAmount = 0,
    currencySymbol = 'cr',
  } = props;
  const { act, data } = useBackend(context);
  const {
    compactMode,
    lockable,
    categories = [],
  } = data;
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');
  const [
    selectedCategory,
    setSelectedCategory,
  ] = useLocalState(context, 'category', categories[0]?.name);
  const testSearch = createSearch(searchText, item => {
    return item.name;
  });
  const items = searchText.length > 0
    // Flatten all categories and apply search to it
    && categories
      .flatMap(category => category.items || [])
      .filter(testSearch)
      .filter((item, i) => i < MAX_SEARCH_RESULTS)
    // Select a category and show all items in it
    || categories
      .find(category => category.name === selectedCategory)
      ?.items
    // If none of that results in a list, return an empty list
    || [];
  return (
    <Section
      title={(
        <Box
          inline
          color={currencyAmount > 0 ? 'good' : 'bad'}>
          {formatMoney(currencyAmount)} Biomass
        </Box>
      )}
      buttons={(
        <Fragment>
          Search
          <Input
            value={searchText}
            onInput={(e, value) => setSearchText(value)}
            mx={1} />
          <Button
            icon={compactMode ? 'list' : 'info'}
            content={compactMode ? 'Compact' : 'Detailed'}
            onClick={() => act('compact_toggle')} />
          {!!lockable && (
            <Button
              icon="lock"
              content="Lock"
              onClick={() => act('lock')} />
          )}
        </Fragment>
      )}>
      <Flex>
        {searchText.length === 0 && (
          <Flex.Item>
            <Tabs vertical>
              {categories.map(category => (
                <Tabs.Tab
                  key={category.name}
                  selected={category.name === selectedCategory}
                  onClick={() => setSelectedCategory(category.name)}>
                  {category.name} ({category.items?.length || 0})
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

const ItemList = (props, context) => {
  const {
    compactMode,
    currencyAmount,
    currencySymbol,
  } = props;
  const { act } = useBackend(context);
  const [
    hoveredItem,
    setHoveredItem,
  ] = useLocalState(context, 'hoveredItem', {});
  const hoveredCost = hoveredItem && hoveredItem.cost || 0;
  // Append extra hover data to items
  const items = props.items.map(item => {
    const notSameItem = hoveredItem && hoveredItem.name !== item.name;
    const notEnoughHovered = currencyAmount - hoveredCost < item.cost;
    const disabledDueToHovered = notSameItem && notEnoughHovered;
    const disabled = currencyAmount < item.cost || disabledDueToHovered;
    return {
      ...item,
      disabled,
    };
  });
  if (compactMode) {
    return (
      <Table>
        {items.map(item => (
          <Table.Row
            key={item.name}
            className="candystripe">
            <Table.Cell bold>
              {decodeHtmlEntities(item.name)}
            </Table.Cell>
            <Table.Cell collapsing textAlign="right">
              <Button
                fluid
                content={formatMoney(item.cost) + ' ' + currencySymbol}
                disabled={item.disabled}
                tooltipPosition="left"
                onmouseover={() => setHoveredItem(item)}
                onmouseout={() => setHoveredItem({})}
                onClick={() => act('buy', {
                  name: item.name,
                })} />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    );
  }
  return items.map(item => (
    <LabeledList key={item.name}>
      <LabeledList.Item
        buttons={(
          <Button
            content={item.cost + ' ' + currencySymbol}
            disabled={item.disabled}
            onmouseover={() => setHoveredItem(item)}
            onmouseout={() => setHoveredItem({})}
            onClick={() => act('buy', {
              create: item.name,
              amount: 1,
            })} />
        )}>
        {item.name}
      </LabeledList.Item>
    </LabeledList>
  ));
};
