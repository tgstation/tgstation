import { toTitleCase } from 'common/string';
import { resolveAsset } from '../assets';
import { useBackend, useLocalState } from '../backend';
import { Flex, Box, Tabs, Stack } from '../components';
import { Window } from '../layouts';

export const BotanicalLexicon = (props) => {
  const { act, data } = useBackend();

  const { plant_list = [] } = data;
  const [selectedPlant] = useLocalState('plant', plant_list[0]);

  return (
    <Window
      title="Botanical Encyclopedia"
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
                <PlantTabs />
              </Stack.Item>
            </Stack>
            <Stack class="page">
              <PlantInfo />
            </Stack>
          </Stack>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const PlantInfo = (props) => {
  const { data } = useBackend();

  const { plant_list = [] } = data;
  const [selectedPlant] = useLocalState('plant', plant_list[0]);
  return (
    <Flex class="chicken-info-container">
      <Flex.Item class="chicken-title">
        {toTitleCase(selectedPlant.name)}
      </Flex.Item>
      <Flex.Item class="chicken-icon-container">
        <Box
          class="chicken_icon"
          as="img"
          src={resolveAsset(selectedPlant.plant_icon)}
          height="96px"
          style={{
            '-ms-interpolation-mode': 'nearest-neighbor',
            'image-rendering': 'pixelated',
          }}
        />
      </Flex.Item>

      <Flex.Item class="chicken-metric">
        {selectedPlant.mutates_from &&
          'Mutates From:' + selectedPlant.mutates_from}
      </Flex.Item>

      <Flex.Item class="chicken-metric">
        {selectedPlant.desc && 'Description:' + selectedPlant.desc}
      </Flex.Item>

      <Flex.Item class="chicken-metric">
        {selectedPlant.potency_high &&
          'Potency Range: ' +
            selectedPlant.potency_low +
            ' to ' +
            selectedPlant.potency_high}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedPlant.yield_low &&
          'Yield Range: ' +
            selectedPlant.yield_low +
            ' to ' +
            selectedPlant.yield_high}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedPlant.production_low &&
          'Production Range: ' +
            selectedPlant.production_low +
            ' to ' +
            selectedPlant.production_high}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedPlant.endurance_low &&
          'Endurance Range: ' +
            selectedPlant.endurance_low +
            ' to ' +
            selectedPlant.endurance_high}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedPlant.lifespan_low &&
          'Lifespan Range: ' +
            selectedPlant.lifespan_low +
            ' to ' +
            selectedPlant.lifespan_high}
      </Flex.Item>
      <Flex.Item class="chicken-metric">
        {selectedPlant.required_reagents &&
          'Required Infusions: ' + selectedPlant.required_reagents}
      </Flex.Item>
    </Flex>
  );
};

const PlantTabs = (props) => {
  const { data } = useBackend();

  const { plant_list = [] } = data;
  const [selectedPlant, setSelectedPlant] = useLocalState(
    'plant',
    plant_list[0]
  );
  return (
    <Tabs vertical>
      {plant_list.map((plant) => (
        <Tabs.Tab
          key={plant}
          selected={plant === selectedPlant}
          onClick={() => setSelectedPlant(plant)}>
          {plant.name}
        </Tabs.Tab>
      ))}
    </Tabs>
  );
};
