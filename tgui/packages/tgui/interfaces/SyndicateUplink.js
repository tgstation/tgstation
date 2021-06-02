
import { createSearch, decodeHtmlEntities } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Input, Section, Table, Tabs, NoticeBox, Stack } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

const MAX_SEARCH_RESULTS = 25;

export const SyndicateUplink = (props, context) => {
  const { data } = useBackend(context);
  const {
    red_telecrystals,
    black_telecrystals,
    theme,
  } = data;
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
  ] = useLocalState(context, 'category', "Stealth Gadgets");
  const [
    market,
    setMarket,
  ] = useLocalState(context, 'market', 0);
  const testSearch = createSearch(searchText, item => {
    return item.name + item.desc;
  });
  const items = searchText.length > 0
    // Flatten all categories and apply search to it
    && categories
      .flatMap(category => category.items || [])
      .filter(testSearch)
      .filter((item, i) => i < MAX_SEARCH_RESULTS)
    // Select a category and show all items in it (from the correct market)
    || categories
      .find(category => category.name === selectedCategory)
      ?.items
      .filter(item => (
        market === 0
        && item.red_cost > 0
      ) || (
        market === 1
        && item.black_cost > 0
      ))
    // If none of that results in a list, return an empty list
    || [];
  const filteredCategories = categories.filter(category => (
    searchText.length === 0
    && category.items?.filter(item => (
      market === 0
      && item.red_cost > 0
    ) || (
      market === 1
      && item.black_cost > 0
    )).length > 0
  ));
  return (
    <Window
      width={620}
      height={580}
      theme={theme}>
      <Window.Content
        scrollable
        backgroundColor={market === 1 && "#595959"}>
        <Stack vertical fill>
          <Stack.Item>
            <Section backgroundColor="rgba(20, 20, 20, 0.7)">
              <Stack justify="center" fill align="baseline">
                <Stack.Item textColor="red">
                  {red_telecrystals} Red TC
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    color={market === 0 && "black" || "bad"}
                    icon={market === 0 && "door-open" || "door-closed"}
                    onClick={() => setMarket(0)}>
                    Enter Red Market
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    color={market === 1 && "black" || "white"}
                    icon={market === 0 && "door-closed" || "door-open"}
                    onClick={() => setMarket(1)}>
                    Enter Black Market
                  </Button>
                </Stack.Item>
                <Stack.Item textAlign="right">
                  {black_telecrystals} Black TC
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item grow>
                <Section fill>
                  {filteredCategories.map(category => (
                    <Button
                      key={category.name}
                      fluid
                      onClick={() => setSelectedCategory(category.name)}>
                      {category.name}
                    </Button>
                  ))}
                </Section>
              </Stack.Item>
              <Stack.Item grow={3}>
                <Section fill>
                  <ItemList sortedItems={items} />
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ItemList = (props, context) => {
  const { act } = useBackend(context);
  const [
    hoveredItem,
    setHoveredItem,
  ] = useLocalState(context, 'hoveredItem', {});
  const hoveredCost = hoveredItem && hoveredItem.cost || 0;
  // Append extra hover data to items
  return props.sortedItems.map(item => (
    <Section
      key={item.name}
      title={item.name}
      level={2}
      buttons={(
        <Button
          content={item.cost + ' TC'}
          disabled={false}
          onmouseover={() => setHoveredItem(item)}
          onmouseout={() => setHoveredItem({})}
          onClick={() => act('buy', {
            name: item.name,
          })} />
      )}>
      {decodeHtmlEntities(item.desc)}
    </Section>
  ));
};
