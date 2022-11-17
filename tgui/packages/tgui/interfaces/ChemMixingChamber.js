import { useBackend, useLocalState } from '../backend';
import { AnimatedNumber, Box, Button, Input, NumberInput, Section, Stack } from '../components';
import { Window } from '../layouts';
import { round, toFixed } from 'common/math';

export const ChemMixingChamber = (props, context) => {
  const { act, data } = useBackend(context);

  const [reagentName, setReagentName] = useLocalState(
    context,
    'reagentName',
    ''
  );
  const [reagentQuantity, setReagentQuantity] = useLocalState(
    context,
    'reagentQuantity',
    1
  );

  const { emptying, temperature, ph, targetTemp, isReacting } = data;
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
                      value={round(targetTemp)}
                      minValue={0}
                      maxValue={1000}
                      onDrag={(e, value) =>
                        act('temperature', {
                          target: value,
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
              }>
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
                    color={emptying ? 'bad' : 'good'}>
                    {emptying ? 'Emptying' : 'Filling'}
                  </Box>
                )
              }>
              <Stack vertical fill>
                <Stack.Item>
                  <Stack fill>
                    <Stack.Item grow>
                      <Input
                        fluid
                        value=""
                        placeholder="Reagent Name"
                        onInput={(e, value) => setReagentName(value)}
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
                        onDrag={(e, value) => setReagentQuantity(value)}
                      />
                      <Box inline mr={1} />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="plus"
                        onClick={() =>
                          act('add', {
                            chem: reagentName,
                            amount: reagentQuantity,
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack vertical>
                    {reagents.map((reagent) => (
                      <Stack.Item key={reagent}>
                        <Stack fill>
                          <Stack.Item mt={0.25} textColor="label">
                            {reagent.name + ':'}
                          </Stack.Item>
                          <Stack.Item mt={0.25} grow>
                            {reagent.required_reagent}
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
