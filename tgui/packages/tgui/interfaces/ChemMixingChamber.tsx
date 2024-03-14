import { round, toFixed } from 'common/math';
import { BooleanLike } from 'common/react';
import { useState } from 'react';

import { useBackend } from '../backend';
import {
  AnimatedNumber,
  Box,
  Button,
  NumberInput,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type Reagent = {
  name: string;
  volume: number;
};

export type MixingData = {
  reagents: Reagent[];
  emptying: BooleanLike;
  temperature: number;
  targetTemp: number;
  isReacting: BooleanLike;
};

export const ChemMixingChamber = (props) => {
  const { act, data } = useBackend<MixingData>();

  const [reagentQuantity, setReagentQuantity] = useState(1);

  const { emptying, temperature, targetTemp, isReacting } = data;
  const reagents = data.reagents || [];

  return (
    <Window width={290} height={400}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section
              title="Conditions"
              buttons={
                <Stack>
                  <Stack.Item mt={0.3}>{'Target:'}</Stack.Item>
                  <Stack.Item>
                    <NumberInput
                      width="65px"
                      unit="K"
                      step={10}
                      stepPixelSize={3}
                      value={round(targetTemp, 0.1)}
                      minValue={0}
                      maxValue={1000}
                      onDrag={(value) =>
                        act('temperature', {
                          target: value,
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
              }
            >
              <Stack vertical>
                <Stack.Item>
                  <Stack fill>
                    <Stack.Item textColor="label">
                      Current Temperature:
                    </Stack.Item>
                    <Stack.Item grow>
                      <AnimatedNumber
                        value={temperature}
                        format={(value) => toFixed(value) + ' K'}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              title="Settings"
              fill
              scrollable
              buttons={
                (isReacting && (
                  <Box inline bold color={'purple'}>
                    {'Reacting'}
                  </Box>
                )) || (
                  <Box
                    fontSize="16px"
                    inline
                    bold
                    color={emptying ? 'bad' : 'good'}
                  >
                    {emptying ? 'Emptying' : 'Filling'}
                  </Box>
                )
              }
            >
              <Stack vertical fill>
                <Stack.Item>
                  <Stack fill>
                    <Stack.Item grow>
                      <Button
                        content="Add Reagent"
                        color="good"
                        icon="plus"
                        onClick={() =>
                          act('add', {
                            amount: reagentQuantity,
                          })
                        }
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <NumberInput
                        value={reagentQuantity}
                        minValue={1}
                        maxValue={100}
                        step={1}
                        stepPixelSize={3}
                        width="39px"
                        onDrag={(value) => setReagentQuantity(value)}
                      />
                      <Box inline mr={1} />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack vertical>
                    {reagents.map((reagent) => (
                      <Stack.Item key={reagent.name}>
                        <Stack fill>
                          <Stack.Item mt={0.25} textColor="label">
                            {reagent.name + ':'}
                          </Stack.Item>
                          <Stack.Item mt={0.25} grow>
                            {reagent.volume}
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              icon="minus"
                              color="bad"
                              onClick={() =>
                                act('remove', {
                                  chem: reagent.name,
                                })
                              }
                            />
                          </Stack.Item>
                        </Stack>
                      </Stack.Item>
                    ))}
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
