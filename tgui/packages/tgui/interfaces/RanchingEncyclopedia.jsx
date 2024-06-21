import { toTitleCase } from 'common/string';
import { resolveAsset } from '../assets';
import { useBackend, useLocalState } from '../backend';
import { Flex, Box, Tabs, Stack } from '../components';
import { Window } from '../layouts';

export const RanchingEncyclopedia = (props) => {
  const { act, data } = useBackend();

  const { chicken_list = [] } = data;
  const [selectedChicken] = useLocalState('chicken', chicken_list[0]);

  return (
    <Window
      title="Ranching Encyclopedia"
      theme="chicken_book"
      width={600}
      height={450}>
      <Window.Content>
        <Stack class="content">
          <Stack class="book">
            <div class="spine" />
            <Stack class="page">
              <Stack.Item class="TOC">Table of Contents</Stack.Item>
              <Stack.Item class="chicken_tab_list">
                <ChickenTabs />
              </Stack.Item>
            </Stack>
            <Stack class="page">
              <ChickenInfo />
            </Stack>
          </Stack>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ChickenInfo = (props) => {
  const { data } = useBackend();

  const { chicken_list = [] } = data;
  const [selectedChicken] = useLocalState('chicken', chicken_list[0]);
  return (
    <Flex class="chicken-info-container">
      <Flex.Item class="chicken-title">
        {toTitleCase(selectedChicken.name)}
      </Flex.Item>
      <Flex.Item class="chicken-icon-container">
        <Box
          class="chicken_icon"
          as="img"
          src={resolveAsset(selectedChicken.chicken_icon)}
          height="96px"
          style={{
            '-ms-interpolation-mode': 'nearest-neighbor',
            'image-rendering': 'pixelated',
          }}
        />
      </Flex.Item>

      <Flex.Item class="chicken-metric">
        {selectedChicken.comes_from &&
          'Mutates from: ' + selectedChicken.comes_from}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {'Maximum Living Age:' + selectedChicken.max_age}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.desc && 'Description:' + selectedChicken.desc}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.happiness &&
          'Required Happiness:' + selectedChicken.happiness}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.temperature &&
          'Requires temperatures within ' +
            selectedChicken.temperature_variance +
            'K of ' +
            selectedChicken.temperature +
            'K'}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.needed_pressure &&
          'Requires pressure within ' +
            selectedChicken.pressure_variance +
            ' of ' +
            selectedChicken.needed_pressure}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.food_requirements &&
          'Chicken needs to have eaten:' + selectedChicken.food_requirements}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.reagent_requirements &&
          'Chicken needs to have consumed:' +
            selectedChicken.reagent_requirements}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.player_job &&
          'A ' +
            selectedChicken.player_job +
            " needs to be present for this chicken's birth."}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.required_species &&
          'A ' +
            selectedChicken.required_species +
            " needs to be present for this chicken's birth."}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.player_health &&
          'A crew member that has been injured by atleast ' +
            selectedChicken.player_health +
            ' points.'}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.required_atmos &&
          'Chicken needs to be an environment with: ' +
            selectedChicken.required_atmos +
            ' present.'}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.required_rooster &&
          'A ' +
            selectedChicken.required_rooster +
            ' needs to be around for the egg to hatch.'}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.liquid_depth &&
          'Their needs to be a pool of liquid atleast' +
            selectedChicken.liquid_depth +
            ' deep for the egg to hatch.'}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.needed_turfs &&
          'Their needs to be ' +
            selectedChicken.needed_turfs +
            ' around for the egg to hatch.'}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedChicken.nearby_items &&
          'The Chicken needs to be given ' +
            selectedChicken.nearby_items +
            ' to mutate.'}
      </Flex.Item>
    </Flex>
  );
};

const ChickenTabs = (props) => {
  const { data } = useBackend();

  const { chicken_list = [] } = data;
  const [selectedChicken, setSelectedChicken] = useLocalState(
    'chicken',
    chicken_list[0]
  );
  return (
    <Tabs vertical>
      {chicken_list.map((chicken) => (
        <Tabs.Tab
          key={chicken}
          selected={chicken === selectedChicken}
          onClick={() => setSelectedChicken(chicken)}>
          {chicken.name}
        </Tabs.Tab>
      ))}
    </Tabs>
  );
};
