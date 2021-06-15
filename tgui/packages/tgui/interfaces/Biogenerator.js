import { classes } from 'common/react';
import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dimmer, Flex, Icon, Input, NoticeBox, NumberInput, Section, Table, Tabs } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

const MAX_SEARCH_RESULTS = 25;

export const Biogenerator = (props, context) => {
  const { data } = useBackend(context);
  const {
    beaker,
    processing,
  } = data;
  return (
    <Window
      width={550}
      height={420}>
      {!!processing && (
        <Dimmer fontSize="32px">
          <Icon name="cog" spin={1} />
          {' Processing...'}
        </Dimmer>
      )}
      <Window.Content scrollable>
        {!beaker && (
          <NoticeBox>No Container</NoticeBox>
        )}
        {!!beaker && (
          <BiogeneratorContent />
        )}
      </Window.Content>
    </Window>
  );
};

export const BiogeneratorContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    biomass,
    can_process,
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
          color={biomass > 0 ? 'good' : 'bad'}>
          {formatMoney(biomass)} Biomass
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
            icon="eject"
            content="Eject"
            onClick={() => act('eject')} />
          <Button
            icon="cog"
            content="Activate"
            disabled={!can_process}
            onClick={() => act('activate')} />
        </>
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
          <Table>
            <ItemList
              biomass={biomass}
              items={items} />
          </Table>
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const ItemList = (props, context) => {
  const { act } = useBackend(context);
  const [
    hoveredItem,
    setHoveredItem,
  ] = useLocalState(context, 'hoveredItem', {});
  const hoveredCost = hoveredItem.cost || 0;
  // Append extra hover data to items
  const items = props.items.map(item => {
    const [
      amount,
      setAmount,
    ] = useLocalState(context, "amount" + item.name, 1);
    const notSameItem = hoveredItem.name !== item.name;
    const notEnoughHovered = props.biomass - hoveredCost
      * hoveredItem.amount < item.cost * amount;
    const disabledDueToHovered = notSameItem && notEnoughHovered;
    const disabled = props.biomass < item.cost * amount || disabledDueToHovered;
    return {
      ...item,
      disabled,
      amount,
      setAmount,
    };
  });
  return items.map(item => (
    <Table.Row key={item.id}>
      <Table.Cell>
        <span
          className={classes(['design32x32', item.id])}
          style={{
            'vertical-align': 'middle',
          }} />
        {' '}<b>{item.name}</b>
      </Table.Cell>
      <Table.Cell collapsing>
        <NumberInput
          value={Math.round(item.amount)}
          width="35px"
          minValue={1}
          maxValue={10}
          onChange={(e, value) => item.setAmount(value)} />
      </Table.Cell>
      <Table.Cell collapsing>
        <Button
          style={{
            'text-align': 'right',
          }}
          fluid
          content={item.cost * item.amount + ' ' + "BIO"}
          disabled={item.disabled}
          onmouseover={() => setHoveredItem(item)}
          onmouseout={() => setHoveredItem({})}
          onClick={() => act('create', {
            id: item.id,
            amount: item.amount,
          })} />
      </Table.Cell>
    </Table.Row>
  ));
};
