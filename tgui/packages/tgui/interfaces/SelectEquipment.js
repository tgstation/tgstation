import { useBackend, useLocalState } from '../backend';
import { createSearch } from 'common/string';
import { Box, Button, Tabs, Section, Input, Stack, Flex, Divider } from '../components';
import { Window } from '../layouts';

export const SelectEquipment = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    name,
    outfits,
    icon64,
  } = data;


  // search bar
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');
  const searchFilter = createSearch(searchText, entry =>
    (entry[0] + entry[1])
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

  const outfitCategories = Object.keys(outfits);
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
          content={outfit[1]}
          title={outfit[0]}
          selected={outfit[0]===selectedOutfit}
          onClick={() => selectOutfit(outfit[0])} />
      </Stack.Item>
    );
  };

  const DisplayedOutfits = (props, context) => {
    return (
      <Stack vertical direction="column">
        {Object.entries(outfits[tabIndex])
          ?.filter(searchFilter)
          ?.map(outfitButton)}
      </Stack>);
  };


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
