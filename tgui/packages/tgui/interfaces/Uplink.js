import { decodeHtmlEntities, createSearch } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Input, Section, Table, Tabs } from '../components';
import { Window } from '../layouts';
import { useGlobal } from '../store';

const MAX_SEARCH_RESULTS = 25;

// It's a class because we need to store state in the form of the current
// hovered item, and current search terms
export const Uplink = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    compact_mode,
    lockable,
    telecrystals,
    categories = [],
  } = data;
  const [
    hoveredItem,
    setHoveredItem,
  ] = useGlobal(context, 'hoveredItem', {});
  const [
    searchText,
    setSearchText,
  ] = useGlobal(context, 'searchText', '');
  const testSearch = createSearch(searchText, item => {
    return item.name + item.desc;
  });
  return (
    <Window
      theme="syndicate"
      resizable>
      <Window.Content scrollable>
        <Section
          title={(
            <Box
              inline
              color={telecrystals > 0 ? 'good' : 'bad'}>
              {telecrystals} TC
            </Box>
          )}
          buttons={(
            <Fragment>
              Search
              <Input
                value={searchText}
                onInput={(e, value) => setSearchText(value)}
                ml={1}
                mr={1} />
              <Button
                icon={compact_mode ? 'list' : 'info'}
                content={compact_mode ? 'Compact' : 'Detailed'}
                onClick={() => act('compact_toggle')} />
              {!!lockable && (
                <Button
                  icon="lock"
                  content="Lock"
                  onClick={() => act('lock')} />
              )}
            </Fragment>
          )}>
          {searchText.length > 0 ? (
            <ItemList
              compact
              items={categories
                .flatMap(category => category.items || [])
                .filter(testSearch)
                .filter((item, i) => i < MAX_SEARCH_RESULTS)}
              hoveredItem={hoveredItem}
              onBuyMouseOver={item => setHoveredItem(item)}
              onBuyMouseOut={item => setHoveredItem({})}
              onBuy={item => act('buy', {
                item: item.name,
              })} />
          ) : (
            <Tabs vertical>
              {categories.map(category => {
                const { name, items } = category;
                if (items === null) {
                  return;
                }
                return (
                  <Tabs.Tab
                    key={name}
                    label={`${name} (${items.length})`}>
                    {() => (
                      <ItemList
                        compact={compact_mode}
                        items={items}
                        hoveredItem={hoveredItem}
                        telecrystals={telecrystals}
                        onBuyMouseOver={item => setHoveredItem(item)}
                        onBuyMouseOut={item => setHoveredItem({})}
                        onBuy={item => act('buy', {
                          item: item.name,
                        })} />
                    )}
                  </Tabs.Tab>
                );
              })}
            </Tabs>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

const ItemList = props => {
  const {
    items,
    hoveredItem,
    telecrystals,
    compact,
    onBuy,
    onBuyMouseOver,
    onBuyMouseOut,
  } = props;
  const hoveredCost = hoveredItem && hoveredItem.cost || 0;
  if (compact) {
    return (
      <Table>
        {items.map(item => {
          const notSameItem = hoveredItem && hoveredItem.name !== item.name;
          const notEnoughHovered = telecrystals - hoveredCost < item.cost;
          const disabledDueToHovered = notSameItem && notEnoughHovered;
          return (
            <Table.Row
              key={item.name}
              className="candystripe">
              <Table.Cell bold>
                {decodeHtmlEntities(item.name)}
              </Table.Cell>
              <Table.Cell collapsing textAlign="right">
                <Button
                  fluid
                  content={item.cost + " TC"}
                  disabled={telecrystals < item.cost || disabledDueToHovered}
                  tooltip={item.desc}
                  tooltipPosition="left"
                  onmouseover={() => onBuyMouseOver(item)}
                  onmouseout={() => onBuyMouseOut(item)}
                  onClick={() => onBuy(item)} />
              </Table.Cell>
            </Table.Row>
          );
        })}
      </Table>
    );
  }
  return items.map(item => {
    const notSameItem = hoveredItem && hoveredItem.name !== item.name;
    const notEnoughHovered = telecrystals - hoveredCost < item.cost;
    const disabledDueToHovered = notSameItem && notEnoughHovered;
    return (
      <Section
        key={item.name}
        title={item.name}
        level={2}
        buttons={(
          <Button
            content={item.cost + ' TC'}
            disabled={telecrystals < item.cost || disabledDueToHovered}
            onmouseover={() => onBuyMouseOver(item)}
            onmouseout={() => onBuyMouseOut(item)}
            onClick={() => onBuy(item)} />
        )}>
        {decodeHtmlEntities(item.desc)}
      </Section>
    );
  });
};
