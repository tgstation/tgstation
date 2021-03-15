import { useBackend, useLocalState } from '../backend';
import { createSearch } from 'common/string';
import { Box, Button, Icon, Input, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { flow } from 'common/fp';
import { filter, sortBy, uniq } from 'common/collections';

// here's an important mental define:
// custom outfits give a ref keyword instead of path
const getOutfitKey = outfit => outfit.path || outfit.ref;

const getOutfitEntry = (current_outfit, outfits) => outfits.find(outfit =>
  getOutfitKey(outfit) === current_outfit);

const CurrentlySelectedDisplay = (props, context) => {
  const { act, data } = useBackend(context);
  const { current_outfit } = data;
  const { entry } = props;

  return (
    <Stack align="center">
      <Stack.Item basis={0} grow={1}>
        <Box color="label">
          Currently selected:
        </Box>
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
        <Button lineHeight={2} selected content="Confirm"
          onClick={() => act("applyoutfit", { path: current_outfit })} />
      </Stack.Item>
    </Stack>
  );
};


const useOutfitTabs = (context, outfitCategories) => {
  return useLocalState(context, 'selected-tab', outfitCategories[0]);
};

const DisplayTabs = (props, context) => {
  const { categories } = props;

  const [tabIndex, setTabIndex] = useOutfitTabs(context, categories);
  return (
    <Tabs textAlign="center">
      {categories.map(cat => (
        <Tabs.Tab
          key={cat}
          selected={tabIndex === cat}
          onClick={() => setTabIndex(cat)}>
          {cat}
        </Tabs.Tab>
      ))}
    </Tabs>
  );
};


export const SelectEquipment = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    name,
    icon64,
    current_outfit,
    favorites,
  } = data;

  const outfits = [
    ...data.outfits,
    ...data.custom_outfits,
  ];

  // even if no custom outfits were sent, we still want to make sure there's
  // at least a 'Custom' tab so the button to create a new one pops up
  const outfitCategories = uniq([...outfits.map(entry => entry.category), 'Custom']);
  const [tabIndex, setTabIndex] = useOutfitTabs(context, outfitCategories);

  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');
  const searchFilter = createSearch(searchText, entry => (
    entry.name + entry.path
  ));

  const isFavorited = entry => favorites?.includes(entry.path);

  const entries = flow([
    filter(entry => entry.category === tabIndex),
    filter(searchFilter),
    sortBy(
      entry => isFavorited(entry)?0:1,
      entry => !entry.priority,
      entry => entry.name
    ),
  ])(outfits);

  const currentOutfitEntry = getOutfitEntry(current_outfit, outfits);

  return (
    <Window
      width={950}
      height={660}>
      <Window.Content>
        <Stack fill>
          <Stack.Item>

            <Stack fill vertical>
              <Stack.Item>
                <DisplayTabs categories={outfitCategories} />
              </Stack.Item>
              <Stack.Item>
                <Section>
                  <CurrentlySelectedDisplay entry={currentOutfitEntry} />
                </Section>
              </Stack.Item>
              <Stack.Item height="20px">
                <Input
                  fluid
                  autoFocus
                  placeholder="Search"
                  value={searchText}
                  onInput={(e, value) => setSearchText(value)} />
              </Stack.Item>
              <Stack.Item grow={1} basis={0}>
                <Section fill scrollable>
                  {entries.map(entry => (
                    <Stack mb={0.5} align="center" key={getOutfitKey(entry)}>
                      <Stack.Item grow={1}>
                        <Button
                          fluid
                          ellipsis
                          content={entry.name}
                          title={entry.path||entry.name}
                          selected={getOutfitKey(entry) === current_outfit}
                          onClick={() => act("preview", { path: getOutfitKey(entry) })} />
                      </Stack.Item>
                      {entry.path && (
                        <Stack.Item>
                          <Icon
                            size={1.1}
                            name={isFavorited(entry)?"star":"star-o"}
                            color="gold"
                            style={{ cursor: 'pointer' }}
                            onClick={() => act("togglefavorite",
                              { path: entry.path })} />
                        </Stack.Item>)}
                    </Stack>
                  ))}
                  {tabIndex === "Custom" && (
                    <Button
                      color="transparent"
                      icon="plus"
                      fluid
                      onClick={() => act("customoutfit")}>
                      Create a custom outfit...
                    </Button>)}
                </Section>
              </Stack.Item>
            </Stack>

          </Stack.Item>


          <Stack.Item grow={2} basis={0}>
            <Section fill
              title={name}
              textAlign="center"
              buttons={
                currentOutfitEntry.path && (
                  // custom outfits aren't even persistent between rounds,
                  // so no favorites for these
                  <Icon
                    name={isFavorited(currentOutfitEntry)?"star":"star-o"}
                    color="gold"
                    style={{ cursor: 'pointer' }}
                    onClick={() => act("togglefavorite",
                      { path: currentOutfitEntry.path })} />)
              }
            >

              <Box as="img"
                m={0}
                src={`data:image/jpeg;base64,${icon64}`}
                height="100%"
                style={{
                  '-ms-interpolation-mode': 'nearest-neighbor',
                }} />
            </Section>
          </Stack.Item>

        </Stack>
      </Window.Content>
    </Window>
  );
};
