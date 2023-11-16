import { useBackend, useLocalState } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, NumberInput, Section, RoundGauge, Stack } from '../components';
import { Window } from '../layouts';
import { round, toFixed } from 'common/math';
import { MixingData } from './ChemMixingChamber';

type ReactingData = MixingData & {
  ph: number;
  reagentAcidic: number;
  reagentAlkaline: number;
};

export const ChemReactionChamber = (props, context) => {
  const { act, data } = useBackend<ReactingData>(context);

  const [reagentQuantity, setReagentQuantity] = useLocalState(
    context,
    'reagentQuantity',
    1
  );

  const {
    emptying,
    temperature,
    ph,
    targetTemp,
    isReacting,
    reagentAcidic,
    reagentAlkaline,
  } = data;
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
                    <Stack.Item grow>
                      <RoundGauge
                        value={ph}
                        minValue={0}
                        maxValue={14}
                        format={() => null}
                        position="absolute"
                        size={1.5}
                        top={0.5}
                        right={0.5}
                        ranges={{
                          'red': [-0.22, 1.5],
                          'orange': [1.5, 3],
                          'yellow': [3, 4.5],
                          'olive': [4.5, 5],
                          'good': [5, 6],
                          'green': [6, 8.5],
                          'teal': [8.5, 9.5],
                          'blue': [9.5, 11],
                          'purple': [11, 12.5],
                          'violet': [12.5, 14],
                        }}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack fill>
                    <Stack.Item textColor="label">{'ph:'}</Stack.Item>
                    <Stack.Item grow={15}>{ph}</Stack.Item>
                    <Stack.Item grow mt={1} mb={-0.5}>
                      <Button
                        color="transparent"
                        icon="question"
                        tooltip={`
                        In chemistry, pH is a scale used to specify
                        the acidity or basicity of an aqueous solution.
                        Acidic solutions are measured to have lower
                        pH values than basic or alkaline solutions.
                        The pH scale is logarithmic and inversely
                        indicates the concentration of hydrogen ions
                        in the solution.`}
                        tooltipPosition="bottom-start"
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
                  <LabeledList>
                    <LabeledList.Item label="Acidic pH limit">
                      <NumberInput
                        value={reagentAcidic}
                        minValue={0}
                        maxValue={14}
                        step={1}
                        stepPixelSize={3}
                        width="39px"
                        onDrag={(e, value) =>
                          act('acidic', {
                            target: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Alkaline pH limit">
                      <NumberInput
                        value={reagentAlkaline}
                        minValue={0}
                        maxValue={14}
                        step={1}
                        stepPixelSize={3}
                        width="39px"
                        onDrag={(e, value) =>
                          act('alkaline', {
                            target: value,
                          })
                        }
                      />
                      <Box inline mr={1} />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
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
                        onDrag={(e, value) => setReagentQuantity(value)}
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
