import { filter, map, sortBy, uniq } from 'common/collections';
import { flow } from 'common/fp';
import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Icon, Input, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';

// here's an important mental define:
// custom outfits give a ref keyword instead of path
const getOutfitKey = (outfit) => outfit.path || outfit.ref;

const useOutfitTabs = (context, categories) => {
  return useLocalState(context, 'selected-tab', categories[0]);
};

export const SelectEquipment = (props, context) => {
  const { act, data } = useBackend(context);
  const { name, icon64, current_outfit, favorites } = data;

  const isFavorited = (entry) => favorites?.includes(entry.path);

  const outfits = map((entry) => ({
    ...entry,
    favorite: isFavorited(entry),
  }))([...data.outfits, ...data.custom_outfits]);

  // even if no custom outfits were sent, we still want to make sure there's
  // at least a 'Custom' tab so the button to create a new one pops up
  const categories = uniq([
    ...outfits.map((entry) => entry.category),
    'Custom',
  ]);
  const [tab] = useOutfitTabs(context, categories);

  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const searchFilter = createSearch(
    searchText,
    (entry) => entry.name + entry.path
  );

  const visibleOutfits = flow([
    filter((entry) => entry.category === tab),
    filter(searchFilter),
    sortBy(
      (entry) => !entry.favorite,
      (entry) => !entry.priority,
      (entry) => entry.name
    ),
  ])(outfits);

  const getOutfitEntry = (current_outfit) =>
    outfits.find((outfit) => getOutfitKey(outfit) === current_outfit);

  const currentOutfitEntry = getOutfitEntry(current_outfit);

  return (
    <Window width={650} height={415} theme="admin">
      <Window.Content>
        <Stack fill>
          <Stack.Item>
            <Stack fill vertical>
              <Stack.Item>
                <Input
                  fluid
                  autoFocus
                  placeholder="Search"
                  value={searchText}
                  onInput={(e, value) => setSearchText(value)}
                />
              </Stack.Item>
              <Stack.Item>
                <DisplayTabs categories={categories} />
              </Stack.Item>
              <Stack.Item mt={0} grow={1} basis={0}>
                <OutfitDisplay entries={visibleOutfits} currentTab={tab} />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow={1} basis={0}>
            <Stack fill vertical>
              <Stack.Item>
                <Section>
                  <CurrentlySelectedDisplay entry={currentOutfitEntry} />
                </Section>
              </Stack.Item>
              <Stack.Item grow={1}>
                <Section fill title={name} textAlign="center">
                  <Box
                    as="img"
                    m={0}
                    src={`data:image/jpeg;base64,${icon64}`}
                    height="100%"
                    style={{
                      '-ms-interpolation-mode': 'nearest-neighbor',
                    }}
                  />
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const DisplayTabs = (props, context) => {
  const { categories } = props;
  const [tab, setTab] = useOutfitTabs(context, categories);
  return (
    <Tabs textAlign="center">
      {categories.map((category) => (
        <Tabs.Tab
          key={category}
          selected={tab === category}
          onClick={() => setTab(category)}>
          {category}
        </Tabs.Tab>
      ))}
    </Tabs>
  );
};

const OutfitDisplay = (props, context) => {
  const { act, data } = useBackend(context);
  const { current_outfit } = data;
  const { entries, currentTab } = props;
  return (
    <Section fill scrollable>
      {entries.map((entry) => (
        <Button
          key={getOutfitKey(entry)}
          fluid
          ellipsis
          icon={entry.favorite && 'star'}
          iconColor="gold"
          content={entry.name}
          title={entry.path || entry.name}
          selected={getOutfitKey(entry) === current_outfit}
          onClick={() =>
            act('preview', {
              path: getOutfitKey(entry),
            })
          }
          onDblClick={() =>
            act('applyoutfit', {
              path: getOutfitKey(entry),
            })
          }
        />
      ))}
      {currentTab === 'Custom' && (
        <Button
          color="transparent"
          icon="plus"
          fluid
          onClick={() => act('customoutfit')}>
          Create a custom outfit...
        </Button>
      )}
    </Section>
  );
};

const CurrentlySelectedDisplay = (props, context) => {
  const { act, data } = useBackend(context);
  const { current_outfit } = data;
  const { entry } = props;
  return (
    <Stack align="center">
      {entry?.path && (
        <Stack.Item>
          <Icon
            size={1.6}
            name={entry.favorite ? 'star' : 'star-o'}
            color="gold"
            style={{ cursor: 'pointer' }}
            onClick={() =>
              act('togglefavorite', {
                path: entry.path,
              })
            }
          />
        </Stack.Item>
      )}
      <Stack.Item grow={1} basis={0}>
        <Box color="label">Currently selected:</Box>
        <Box
          title={entry?.path}
          style={{
            'overflow': 'hidden',
            'white-space': 'nowrap',
            'text-overflow': 'ellipsis',
          }}>
          {entry?.name}
        </Box>
      </Stack.Item>
      <Stack.Item>
        <Button
          mr={0.8}
          lineHeight={2}
          color="green"
          onClick={() =>
            act('applyoutfit', {
              path: current_outfit,
            })
          }>
          Confirm
        </Button>
      </Stack.Item>
    </Stack>
  );
};
