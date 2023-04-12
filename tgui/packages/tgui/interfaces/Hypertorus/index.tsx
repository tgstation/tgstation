import { Button, Collapsible, Flex, Section, Stack } from 'tgui/components';
import { HypertorusSecondaryControls, HypertorusWasteRemove } from './Controls';

import { HypertorusGases } from './Gases';
import { HypertorusParameters } from './Parameters';
import { HypertorusRecipes } from './Recipes';
import { HypertorusTemperatures } from './Temperatures';
import { Window } from 'tgui/layouts';
import { useBackend } from 'tgui/backend';

type Data = {
  start_power: number;
  start_cooling: number;
  start_fuel: number;
  start_moderator: number;
  power_level: number;
  selected: string;
  selectable_fuel: HypertorusFuel[];
  base_max_temperature: number;
};

export type HypertorusGas = {
  id: string;
  amount: number;
};

export type HypertorusFuel = {
  id: string;
  requirements: string[];
  temperature_multiplier: number;
  fusion_byproducts: string[];
  product_gases: string[];
};

const HypertorusMainControls = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const {
    start_power,
    start_cooling,
    start_fuel,
    start_moderator,
    power_level,
    selected,
    selectable_fuel,
    base_max_temperature,
  } = data;

  return (
    <Section title="Startup">
      <Stack>
        <Stack.Item color="label">
          {'Start power: '}
          <Button
            disabled={power_level > 0}
            icon={start_power ? 'power-off' : 'times'}
            content={start_power ? 'On' : 'Off'}
            selected={start_power}
            onClick={() => act('start_power')}
          />
        </Stack.Item>
        <Stack.Item color="label">
          {'Start cooling: '}
          <Button
            disabled={
              start_fuel === 1 ||
              start_moderator === 1 ||
              start_power === 0 ||
              (start_cooling && power_level > 0)
            }
            icon={start_cooling ? 'power-off' : 'times'}
            content={start_cooling ? 'On' : 'Off'}
            selected={start_cooling}
            onClick={() => act('start_cooling')}
          />
        </Stack.Item>
      </Stack>
      <Collapsible title="Recipe selection">
        <HypertorusRecipes
          baseMaxTemperature={base_max_temperature}
          enableRecipeSelection={power_level === 0}
          onRecipe={(id) => act('fuel', { mode: id })}
          selectableFuels={selectable_fuel}
          selectedFuelId={selected}
        />
      </Collapsible>
    </Section>
  );
};

const HypertorusLayout = () => {
  return (
    <Flex className="hypertorus-layout" wrap>
      <Flex.Item grow width="100%">
        <HypertorusMainControls />
      </Flex.Item>
      <Flex.Item grow="20" width="350px" minWidth="280px">
        <HypertorusGases />
      </Flex.Item>
      <Flex.Item grow width="420px" overflowX="auto">
        <HypertorusTemperatures />
      </Flex.Item>
      <Flex.Item grow="4" width="580px">
        <Flex className="hypertorus-layout" wrap>
          <Flex.Item grow width="860px">
            <HypertorusParameters />
          </Flex.Item>
          <Flex.Item grow width="580px">
            <HypertorusSecondaryControls />
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item grow width="100%">
        <HypertorusWasteRemove />
      </Flex.Item>
    </Flex>
  );
};

export const Hypertorus = (props, context) => {
  // The HFR has a ridiculous amount of knobs and information.
  // Ideally we'd display a large window for it all...
  const idealWidth = 850,
    idealHeight = 980;

  // ...but we should check for small screens, to play nicely with eg laptops.
  const winWidth = window.screen.availWidth;
  const winHeight = window.screen.availHeight;

  // Make sure we don't start larger than 50%/80% of screen width/height.
  const width = Math.min(idealWidth, winWidth * 0.5);
  const height = Math.min(idealHeight, winHeight * 0.8);

  return (
    <Window
      title="Hypertorus Fusion Reactor control panel"
      width={width}
      height={height}>
      <Window.Content scrollable>
        <HypertorusLayout />
      </Window.Content>
    </Window>
  );
};
