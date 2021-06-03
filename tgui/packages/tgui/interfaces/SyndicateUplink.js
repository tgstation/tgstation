
import { createSearch, decodeHtmlEntities } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Input, Section, Table, Tabs, NoticeBox, Stack } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

const MAX_SEARCH_RESULTS = 25;

export const SyndicateUplink = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    red_telecrystals,
    black_telecrystals,
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
      theme="syndicate">
      <Window.Content
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
              <Stack.Item>
                <Section>
                  <Stack fill>
                    <Stack.Item grow>
                      <Button
                        fluid
                        icon={compactMode ? 'list' : 'info'}
                        content={compactMode ? 'Compact' : 'Detailed'}
                        onClick={() => act('compact_toggle')} />
                    </Stack.Item>
                    <Stack.Item>
                      {!!lockable && (
                        <Button
                          fluid
                          icon="lock"
                          content="Lock"
                          onClick={() => act('lock')} />
                      )}
                    </Stack.Item>
                  </Stack>
                </Section>
                <Section
                  minWidth="154px"
                  textAlign="center">
                  Search For an Item...<br />
                  <Input
                    autoFocus
                    value={searchText}
                    onInput={(e, value) => setSearchText(value)}
                    mx={1} />
                </Section>
                {!searchText&& (
                  <Section>
                    {filteredCategories.map(category => (
                      <Button
                        key={category.name}
                        fluid
                        color={
                          selectedCategory === category.name
                          && "black"
                        }
                        onClick={() => setSelectedCategory(category.name)}>
                        {category.name}
                      </Button>
                    ))}
                  </Section>
                )}
              </Stack.Item>
              <Stack.Item>
                {!!items.length && (
                  <Section
                    mt={!compactMode && "-2px" || undefined}
                    overflowY="scroll"
                    overflowX="hidden"
                    maxHeight="496px"
                    backgroundColor={
                      !compactMode
                      && "rgba(0, 0, 0, 0)"
                      || "rgba(0, 0, 0, 0.7)"
                    }>
                    <ItemList sortedItems={items} />
                  </Section>
                )}
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ItemList = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    red_telecrystals,
    black_telecrystals,
    compactMode,
  } = data;
  const [
    hoveredItem,
    setHoveredItem,
  ] = useLocalState(context, 'hoveredItem', {});
  const hoveredCost = hoveredItem && hoveredItem.cost || 0;
  // Append extra hover data to items
  return props.sortedItems.map(item => (
    <Section
      width="420px"
      backgroundColor={!compactMode && "rgba(0, 0, 0, 0.7)" || undefined}
      key={item.name}
      title={item.name}
      buttons={(
        <>
          {!!item.red_cost && (
            <Button
              disabled={item.red_cost > red_telecrystals}
              color="red"
              onmouseover={() => setHoveredItem(item)}
              onmouseout={() => setHoveredItem({})}
              onClick={() => act('buy', {
                name: item.name,
                tc: "red",
              })} >
              {item.red_cost + ' Red TC'}
            </Button>
          )}
          {!!item.black_cost && (
            <Button
              disabled={item.black_cost > black_telecrystals}
              color={item.black_cost > black_telecrystals && "average" || "white"}
              onmouseover={() => setHoveredItem(item)}
              onmouseout={() => setHoveredItem({})}
              onClick={() => act('buy', {
                name: item.name,
                tc: "black",
              })} >
              {item.black_cost + ' Black TC'}
            </Button>
          )}
        </>
      )}>
      {!compactMode && (
        decodeHtmlEntities(item.desc)
      )}
    </Section>
  ));
};
