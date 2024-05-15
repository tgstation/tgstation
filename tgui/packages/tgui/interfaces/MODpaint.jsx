import { capitalize } from 'common/string';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  ByondUi,
  Flex,
  Section,
  Slider,
  Stack,
} from '../components';
import { Window } from '../layouts';

const colorToMatrix = (param) => {
  switch (param) {
    case 'red':
      return [
        1, 0, 0, 0, 0.25, 0.5, 0, 0, 0.25, 0, 0.5, 0, 0, 0, 0, 1, 0, 0, 0, 0,
      ];
    case 'yellow':
      return [
        0.5, 0.5, 0, 0, 0.5, 0.5, 0, 0, 0.25, 0.25, 0.5, 0, 0, 0, 0, 1, 0, 0, 0,
        0,
      ];
    case 'green':
      return [
        0.5, 0.25, 0, 0, 0, 1, 0, 0, 0, 0.25, 0.5, 0, 0, 0, 0, 1, 0, 0, 0, 0,
      ];
    case 'teal':
      return [
        0.25, 0.25, 0.25, 0, 0, 0.5, 0.5, 0, 0, 0.5, 0.5, 0, 0, 0, 0, 1, 0, 0,
        0, 0,
      ];
    case 'blue':
      return [
        0.25, 0, 0.25, 0, 0, 0.5, 0.25, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0,
      ];
    case 'purple':
      return [
        0.5, 0, 0.5, 0, 0.25, 0.5, 0.25, 0, 0.5, 0, 0.5, 0, 0, 0, 0, 1, 0, 0, 0,
        0,
      ];
  }
};

const displayText = (param) => {
  switch (param) {
    case 'r':
      return 'Red';
    case 'g':
      return 'Green';
    case 'b':
      return 'Blue';
  }
};

export const MODpaint = (props) => {
  const { act, data } = useBackend();
  const { mapRef, currentColor } = data;
  const [
    [rr, rg, rb, ra],
    [gr, gg, gb, ga],
    [br, bg, bb, ba],
    [ar, ag, ab, aa],
    [cr, cg, cb, ca],
  ] = currentColor;
  const presets = ['red', 'yellow', 'green', 'teal', 'blue', 'purple'];
  const prefixes = ['r', 'g', 'b'];
  return (
    <Window width={600} height={365}>
      <Window.Content>
        <Stack fill>
          <Stack.Item fill width="30%">
            {[0, 1, 2].map((row) => (
              <Section
                key={row}
                title={`${displayText(prefixes[row])} turns to:`}
              >
                {[0, 1, 2].map((col) => (
                  <Flex key={col}>
                    <Flex.Item align="left" width="30%">
                      <Box inline textColor="label">
                        {`${displayText(prefixes[col])}:`}
                      </Box>
                    </Flex.Item>
                    <Flex.Item align="right" width="70%">
                      <Slider
                        inline
                        textAlign="right"
                        value={currentColor[row * 4 + col] * 100}
                        minValue={0}
                        maxValue={125}
                        step={1}
                        stepPixelSize={0.75}
                        format={(value) => `${value}%`}
                        onDrag={(e, value) => {
                          let retColor = currentColor;
                          retColor[row * 4 + col] = value / 100;
                          act('transition_color', { color: retColor });
                        }}
                      />
                    </Flex.Item>
                  </Flex>
                ))}
              </Section>
            ))}
          </Stack.Item>
          <Stack.Item width="25%">
            <Section height="70%" title="Presets">
              <Box textAlign="center">
                {presets.map((preset) => (
                  <Button
                    key={preset}
                    height="50px"
                    width="50px"
                    color={preset}
                    tooltipPosition="top"
                    tooltip={capitalize(preset)}
                    onClick={() =>
                      act('transition_color', { color: colorToMatrix(preset) })
                    }
                  />
                ))}
              </Box>
            </Section>
            <Section textAlign="center" fontSize="28px">
              <Button
                height="50px"
                width="50px"
                icon="question"
                color="average"
                tooltipPosition="top"
                tooltip="This is a color matrix. Think of it as editing the image in 3 layers, red, green, and blue, rather than editing the final image like with RGB."
              />
              <Button
                height="50px"
                width="50px"
                icon="check"
                color="good"
                tooltipPosition="top"
                tooltip="Confirm changes!"
                onClick={() => act('confirm')}
              />
            </Section>
          </Stack.Item>
          <Stack.Item width="45%">
            <Section fill title="Preview">
              <ByondUi
                height="230px"
                params={{
                  id: mapRef,
                  type: 'map',
                }}
              />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
