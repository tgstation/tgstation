import {
  Box,
  Button,
  Flex,
  LabeledList,
  ProgressBar,
  Section,
  Slider,
} from 'tgui-core/components';
import { formatPower } from 'tgui-core/format';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// Common power multiplier
const POWER_MUL = 1e3;

export const Smes = (props) => {
  const { act, data } = useBackend();
  const {
    capacityPercent,
    capacity,
    charge,
    inputAttempt,
    inputting,
    inputLevel,
    inputLevelMax,
    inputAvailable,
    outputAttempt,
    outputting,
    outputLevel,
    outputLevelMax,
    outputUsed,
  } = data;
  const inputState =
    (capacityPercent >= 100 && 'good') || (inputting && 'average') || 'bad';
  const outputState =
    (outputting && 'good') || (charge > 0 && 'average') || 'bad';
  return (
    <Window width={340} height={350}>
      <Window.Content>
        <Section title="Stored Energy">
          <ProgressBar
            value={capacityPercent * 0.01}
            ranges={{
              good: [0.5, Infinity],
              average: [0.15, 0.5],
              bad: [-Infinity, 0.15],
            }}
          />
        </Section>
        <Section
          title="Input"
          buttons={
            <Button
              icon={inputAttempt ? 'sync-alt' : 'times'}
              selected={inputAttempt}
              onClick={() => act('tryinput')}
            >
              {inputAttempt ? 'Auto' : 'Off'}
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Charge Mode">
              <Box color={inputState}>
                {(capacityPercent >= 100 && 'Fully Charged') ||
                  (inputting && 'Charging') ||
                  'Not Charging'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Target Input">
              <Flex width="100%">
                <Flex.Item>
                  <Button
                    icon="fast-backward"
                    disabled={inputLevel === 0}
                    onClick={() =>
                      act('input', {
                        target: 'min',
                      })
                    }
                  />
                  <Button
                    icon="backward"
                    disabled={inputLevel === 0}
                    onClick={() =>
                      act('input', {
                        adjust: -10000,
                      })
                    }
                  />
                </Flex.Item>
                <Flex.Item grow={1} mx={1}>
                  <Slider
                    value={inputLevel / POWER_MUL}
                    fillValue={inputAvailable / POWER_MUL}
                    minValue={0}
                    maxValue={inputLevelMax / POWER_MUL}
                    step={5}
                    stepPixelSize={4}
                    format={(value) => formatPower(value * POWER_MUL, 1)}
                    onChange={(e, value) =>
                      act('input', {
                        target: value * POWER_MUL,
                      })
                    }
                  />
                </Flex.Item>
                <Flex.Item>
                  <Button
                    icon="forward"
                    disabled={inputLevel === inputLevelMax}
                    onClick={() =>
                      act('input', {
                        adjust: 10000,
                      })
                    }
                  />
                  <Button
                    icon="fast-forward"
                    disabled={inputLevel === inputLevelMax}
                    onClick={() =>
                      act('input', {
                        target: 'max',
                      })
                    }
                  />
                </Flex.Item>
              </Flex>
            </LabeledList.Item>
            <LabeledList.Item label="Available">
              {formatPower(inputAvailable)}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Output"
          buttons={
            <Button
              icon={outputAttempt ? 'power-off' : 'times'}
              selected={outputAttempt}
              onClick={() => act('tryoutput')}
            >
              {outputAttempt ? 'On' : 'Off'}
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Output Mode">
              <Box color={outputState}>
                {outputting
                  ? 'Sending'
                  : charge > 0
                    ? 'Not Sending'
                    : 'No Charge'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Target Output">
              <Flex width="100%">
                <Flex.Item>
                  <Button
                    icon="fast-backward"
                    disabled={outputLevel === 0}
                    onClick={() =>
                      act('output', {
                        target: 'min',
                      })
                    }
                  />
                  <Button
                    icon="backward"
                    disabled={outputLevel === 0}
                    onClick={() =>
                      act('output', {
                        adjust: -10000,
                      })
                    }
                  />
                </Flex.Item>
                <Flex.Item grow={1} mx={1}>
                  <Slider
                    value={outputLevel / POWER_MUL}
                    minValue={0}
                    maxValue={outputLevelMax / POWER_MUL}
                    step={5}
                    stepPixelSize={4}
                    format={(value) => formatPower(value * POWER_MUL, 1)}
                    onChange={(e, value) =>
                      act('output', {
                        target: value * POWER_MUL,
                      })
                    }
                  />
                </Flex.Item>
                <Flex.Item>
                  <Button
                    icon="forward"
                    disabled={outputLevel === outputLevelMax}
                    onClick={() =>
                      act('output', {
                        adjust: 10000,
                      })
                    }
                  />
                  <Button
                    icon="fast-forward"
                    disabled={outputLevel === outputLevelMax}
                    onClick={() =>
                      act('output', {
                        target: 'max',
                      })
                    }
                  />
                </Flex.Item>
              </Flex>
            </LabeledList.Item>
            <LabeledList.Item label="Outputting">
              {formatPower(outputUsed)}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
