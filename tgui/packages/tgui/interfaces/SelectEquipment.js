import { useBackend, useLocalState } from '../backend';
import { createSearch } from 'common/string';
import { Box, Button, Tabs, Section, Input, Stack } from '../components';
import { Window } from '../layouts';
import { flow } from 'common/fp';
import { filter, sortBy, uniq } from 'common/collections';

// custom outfits give a ref keyword instead of path
const getOutfitKey = outfit => outfit.path || outfit.ref;

const CurrentlySelectedDisplay = (props, context) => {
  const { act, data } = useBackend(context);
  const { current_outfit } = data;

  const outfits = [
    ...data.outfits,
    ...data.custom_outfits,
  ];

  const currentOutfitEntry = outfits.find(outfit =>
    getOutfitKey(outfit) === current_outfit);

  return (
    <Stack align="center">
      <Stack.Item basis={0} grow={1}>
        <Box color="label">
          Currently selected:
        </Box>
        <Box
          title={currentOutfitEntry?.path}
          style={{
            'overflow': 'hidden',
            'white-space': 'nowrap',
            'text-overflow': 'ellipsis',
          }}>
          {currentOutfitEntry?.name}
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
  const searchFilter = createSearch(searchText, entry =>
    (entry.name + entry.path)
  );

  const entries = flow([
    filter(entry => entry.category === tabIndex),
    filter(searchFilter),
    sortBy(entry => -entry.priority, entry => entry.name),
  ])(outfits);

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
                  <CurrentlySelectedDisplay />
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
                    <Button
                      key={getOutfitKey(entry)}
                      fluid
                      ellipsis
                      content={entry.name}
                      title={entry.path||entry.name}
                      selected={getOutfitKey(entry) === current_outfit}
                      onClick={() => act("preview", { path: getOutfitKey(entry) })} />
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
              textAlign="center">
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
