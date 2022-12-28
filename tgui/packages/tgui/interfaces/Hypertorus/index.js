import { useBackend } from 'tgui/backend';
import { Button, Collapsible, Flex, Section, Stack } from 'tgui/components';
import { Window } from 'tgui/layouts';
import { HypertorusSecondaryControls, HypertorusWasteRemove } from './Controls';
import { HypertorusGases } from './Gases';
import { HypertorusParameters } from './Parameters';
import { HypertorusRecipes } from './Recipes';
import { HypertorusTemperatures } from './Temperatures';

const HypertorusMainControls = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Section title="Startup">
      <Stack>
        <Stack.Item color="label">
          {'Start power: '}
          <Button
            disabled={data.power_level > 0}
            icon={data.start_power ? 'power-off' : 'times'}
            content={data.start_power ? 'On' : 'Off'}
            selected={data.start_power}
            onClick={() => act('start_power')}
          />
        </Stack.Item>
        <Stack.Item color="label">
          {'Start cooling: '}
          <Button
            disabled={
              data.start_fuel === 1 ||
              data.start_moderator === 1 ||
              data.start_power === 0 ||
              (data.start_cooling && data.power_level > 0)
            }
            icon={data.start_cooling ? 'power-off' : 'times'}
            content={data.start_cooling ? 'On' : 'Off'}
            selected={data.start_cooling}
            onClick={() => act('start_cooling')}
          />
        </Stack.Item>
      </Stack>
      <Collapsible title="Recipe selection">
        <HypertorusRecipes
          baseMaximumTemperature={data.base_max_temperature}
          enableRecipeSelection={data.power_level === 0}
          onRecipe={(id) => act('fuel', { mode: id })}
          selectableFuels={data.selectable_fuel}
          selectedFuelID={data.selected}
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
