import { useBackend, useLocalState } from '../backend';
import { createSearch } from 'common/string';
import { Box, Button, Tabs, Section, Input, Stack, Flex, Divider } from '../components';
import { Window } from '../layouts';
import { flow } from 'common/fp';
import { filter, map, sortBy, uniqBy } from 'common/collections';

export const SelectEquipment = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    name,
    icon64,
  } = data;

  const outfits = [
    ...data.outfits,
    ...data.custom_outfits,
  ];

  // search bar
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');
  const searchFilter = createSearch(searchText, entry =>
    (entry.name + entry.path)
  );
  const searchBar
    = (<Input
      fluid
      autoFocus
      placeholder="Search"
      value={searchText}
      onInput={(e, value) => setSearchText(value)}
      mb={1} />);


  // outfit tabs; mapped and named from the data sent by ui_static_data
  const [
    tabIndex,
    setTabIndex,
  ] = useLocalState(context, 'tab-index', "General");

  const OutfitTab = props => {
    const { name, ...rest } = props;
    return (
      <Tabs.Tab
        selected={tabIndex === name}
        onClick={() => setTabIndex(name)}
        {...rest}>
        {name}
      </Tabs.Tab>
    );
  };

  const outfitCategories = uniqBy(x => x)(outfits.map(entry => entry.category));

  const DisplayTabs = (props, context) => {
    return (
      <Tabs textAlign="center">

        {outfitCategories.map(cat => { return (
          <OutfitTab key={cat} name={cat} />
        ); })}

      </Tabs>
    );
  };


  // outfit selection
  const selectOutfit = outfitPath => {
    setSelectedOutfit(outfitPath);
    act("preview", { path: outfitPath });
  };

  const [
    selectedOutfit,
    setSelectedOutfit,
  ] = useLocalState(context, 'selected-outfit', "/datum/outfit");

  const CurrentlySelectedDisplay = (props, context) => {
    return (
      <Flex direction="column" textAlign="center" align="center">
        Currently selected:<br />{selectedOutfit}
        <Flex.Item>
          <Button selected content="Confirm"
            onClick={() => act("applyoutfit", { path: selectedOutfit })} />
        </Flex.Item>
      </Flex>
    );
  };

  const outfitButton = outfit => {
    return (
      <Stack.Item>
        <Button
          fluid
          ellipsis
          content={outfit.name}
          title={outfit.path}
          selected={outfit.path===selectedOutfit}
          onClick={() => selectOutfit(outfit.path)} />
      </Stack.Item>
    );
  };

  const DisplayedOutfits = (props, context) => {
    return (
      <Stack vertical direction="column">
        {entries}
      </Stack>);
  };

  const entries = flow([
    filter(entry => entry.category === tabIndex),
    filter(searchFilter),
    sortBy(entry => entry.name),
    sortBy(entry => -entry.priority),
    map(outfitButton),
  ])(outfits);

  return (
    <Window
      width={950}
      height={660}>
      <Window.Content>
        <Flex height="100%">

          <Flex.Item grow={1} basis={0}>
            <Section height="15%" mb={0}>
              <DisplayTabs />
              <CurrentlySelectedDisplay />
              <Divider />
            </Section>
            <Section height="85%" fill scrollable>
              {searchBar}
              <DisplayedOutfits />
            </Section>
          </Flex.Item>


          <Flex.Item grow={2} basis={0}>
            <Section fill
              title={name}
              textAlign="center">
              <Box as="img"
                m={1}
                src={`data:image/jpeg;base64,${icon64}`}
                height="100%"
                width="100%"
                style={{
                  '-ms-interpolation-mode': 'nearest-neighbor',
                }} />
            </Section>
          </Flex.Item>

        </Flex>
      </Window.Content>
    </Window>
  );
};
