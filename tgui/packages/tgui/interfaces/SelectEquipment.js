import { useBackend, useLocalState } from '../backend';
import { createSearch } from 'common/string';
import { Box, Button, ByondUi, Tabs, Section, Input, Stack, Flex, Divider } from '../components';
import { Window } from '../layouts';

export const SelectEquipment = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    name,
    outfits,
    icon64,
  } = data;
  const {
    base,
    jobs,
    plasmaman,
    custom,
  } = outfits;
  const outfitCategories = Object.keys(outfits);

  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');
  const searchFilter = createSearch(searchText, entry =>
    (entry[0] + entry[1])
  );
  const searchBar
    = (<Input
      autoFocus
      placeholder="Search"
      value={searchText}
      onInput={(e, value) => setSearchText(value)}
      mx={1} />);

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

  const displayTabs
    = (
      <Tabs textAlign="center">

        <OutfitTab name="General" />
        <OutfitTab name="Jobs" />
        <OutfitTab name="Plasmamen Outfits" />
        <OutfitTab name="Custom" />

      </Tabs>
    );

  // the fact that this is needed at all is wack and I'll make it proper later
  const outfitCategory = () => {
    switch (tabIndex) {
      case "General":
        return (base);

      case "Jobs":
        return (jobs);

      case "Plasmamen Outfits":
        return (plasmaman);

      case "Custom":
        return (custom);

      default:
        return ([]);
    } };

  const makeOutfit = outfit => {
    return (
      <Stack.Item>
        <Button
          fluid
          content={outfit[1]}
          title={outfit[0]} />
      </Stack.Item>
    );
  };

  const displayedOutfits
    = Object.entries(outfitCategory())
      ?.filter(searchFilter)
      ?.map(makeOutfit);

  return (
    <Window
      width={950}
      height={660}>
      <Window.Content>
        <Flex height="100%">
          <Flex.Item grow={1} basis={0}>
            <Section fill scrollable>
              {displayTabs}
              <Stack vertical direction="column">
                {displayedOutfits}
              </Stack>
            </Section>
          </Flex.Item>

          <Flex.Item grow={2} basis={0}>
            <Section fill
              title={name}
              textAlign="center"
              buttons={searchBar}>
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
