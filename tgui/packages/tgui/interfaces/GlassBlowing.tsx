// THIS IS A SKYRAT UI FILE
import { toFixed } from 'common/math';
import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Flex, ProgressBar, Section, Stack, Table } from '../components';
import { Window } from '../layouts';

type GlassData = {
  hasGlass: BooleanLike;
  inUse: BooleanLike;
  glass: Glass;
};

type Glass = {
  chosenItem: CraftItem;
  stepsRemaining: RemainingSteps;
  timeLeft: number;
  totalTime: number;
  isFinished: BooleanLike;
};

type CraftItem = {
  name: string;
  type: string;
};

type RemainingSteps = {
  blow: number;
  spin: number;
  paddle: number;
  shear: number;
  jacks: number;
};

export const GlassBlowing = (_: any, context: any) => {
  const { act, data } = useBackend<GlassData>();
  const { glass, inUse } = data;

  return (
    <Window width={335} height={325}>
      <Window.Content scrollable>
        <Section
          title={glass && glass.timeLeft ? 'Molten Glass' : 'Cooled Glass'}
          buttons={
            <Button
              icon={
                glass && glass.isFinished
                  ? 'check'
                  : glass && glass.timeLeft
                    ? 'triangle-exclamation'
                    : 'arrow-right'
              }
              color={
                glass && glass.isFinished
                  ? 'good'
                  : glass && glass.timeLeft
                    ? 'red'
                    : 'default'
              }
              tooltipPosition="bottom"
              tooltip={
                glass && glass.timeLeft
                  ? 'You may want to think twice about touching this right now...'
                  : 'It has cooled and is safe to handle.'
              }
              content={glass && glass.isFinished ? 'Complete Craft' : 'Remove'}
              disabled={!glass || inUse}
              onClick={() => act('Remove')}
            />
          }
        />
        {glass && !glass.chosenItem && (
          <Section title="Pick a craft">
            <Stack fill vertical>
              <Stack.Item>
                <Box>What will you craft?</Box>
              </Stack.Item>

              <Stack.Item>
                <Button
                  content="Plate"
                  disabled={inUse}
                  onClick={() => act('Plate')}
                />
                <Button
                  content="Bowl"
                  tooltipPosition="bottom"
                  disabled={inUse}
                  onClick={() => act('Bowl')}
                />
                <Button
                  content="Globe"
                  disabled={inUse}
                  onClick={() => act('Globe')}
                />
                <Button
                  content="Cup"
                  disabled={inUse}
                  onClick={() => act('Cup')}
                />
                <Button
                  content="Lens"
                  tooltipPosition="bottom"
                  disabled={inUse}
                  onClick={() => act('Lens')}
                />
                <Button
                  content="Bottle"
                  disabled={inUse}
                  onClick={() => act('Bottle')}
                />
              </Stack.Item>
            </Stack>
          </Section>
        )}
        {glass && glass.chosenItem && (
          <>
            <Section title="Steps Remaining:">
              <Stack fill vertical>
                <Stack.Item>
                  <Box>
                    You are crafting a {glass.chosenItem.name}.
                    <br />
                    <br />
                  </Box>
                </Stack.Item>
                <Table>
                  <Stack.Item>
                    {glass.stepsRemaining.blow !== 0 && (
                      <Table.Cell>
                        <Button
                          content="Blow"
                          icon="fire"
                          color="orange"
                          disabled={inUse || !glass.timeLeft}
                          tooltipPosition="bottom"
                          tooltip={
                            glass.timeLeft === 0
                              ? 'Needs to be glowing hot.'
                              : ''
                          }
                          onClick={() => act('Blow')}
                        />
                        &nbsp;x{glass.stepsRemaining.blow}
                      </Table.Cell>
                    )}
                    {glass.stepsRemaining.spin !== 0 && (
                      <Table.Cell>
                        <Button
                          content="Spin"
                          icon="fire"
                          color="orange"
                          disabled={inUse || !glass.timeLeft}
                          tooltipPosition="bottom"
                          tooltip={
                            glass.timeLeft === 0
                              ? 'Needs to be glowing hot.'
                              : ''
                          }
                          onClick={() => act('Spin')}
                        />
                        &nbsp;x{glass.stepsRemaining.spin}
                      </Table.Cell>
                    )}
                    {glass.stepsRemaining.paddle !== 0 && (
                      <Table.Cell>
                        <Button
                          content="Paddle"
                          disabled={inUse}
                          tooltipPosition="bottom"
                          tooltip={'You need to use a paddle.'}
                          onClick={() => act('Paddle')}
                        />
                        &nbsp;x{glass.stepsRemaining.paddle}
                      </Table.Cell>
                    )}
                    {glass.stepsRemaining.shear !== 0 && (
                      <Table.Cell>
                        <Button
                          content="Shears"
                          disabled={inUse}
                          tooltipPosition="bottom"
                          tooltip={'You need to use shears.'}
                          onClick={() => act('Shear')}
                        />
                        &nbsp;x{glass.stepsRemaining.shear}
                      </Table.Cell>
                    )}
                    {glass.stepsRemaining.jacks !== 0 && (
                      <Table.Cell>
                        <Button
                          content="Jacks"
                          disabled={inUse}
                          tooltipPosition="bottom"
                          tooltip={'You need to use jacks.'}
                          onClick={() => act('Jacks')}
                        />
                        &nbsp;x{glass.stepsRemaining.jacks}
                      </Table.Cell>
                    )}
                  </Stack.Item>
                </Table>
              </Stack>
            </Section>
            <Section title>
              <Flex direction="row-reverse">
                <Flex.Item>
                  <Button
                    icon="times"
                    color={glass.timeLeft ? 'orange' : 'default'}
                    content="Cancel craft"
                    disabled={inUse}
                    onClick={() => act('Cancel')}
                  />
                </Flex.Item>
              </Flex>
            </Section>
          </>
        )}
        {glass && glass.timeLeft !== 0 && (
          <Section title="Heat level">
            <ProgressBar
              value={glass.timeLeft / glass.totalTime}
              ranges={{
                red: [0.8, Infinity],
                orange: [0.65, 0.8],
                yellow: [0.3, 0.65],
                blue: [0.05, 0.3],
                black: [-Infinity, 0.05],
              }}
              style={{
                backgroundImage: 'linear-gradient(to right, blue, yellow, red)',
              }}>
              <AnimatedNumber
                value={glass.timeLeft}
                format={(value) => toFixed(value, 1)}
              />
              {'/' + glass.totalTime.toFixed(1)}
            </ProgressBar>
          </Section>
        )}
        {glass && glass.timeLeft === 0 && (
          <Section title="Heat level">
            <ProgressBar
              value={0 / 0}
              ranges={{}}
              style={{
                backgroundImage: 'grey',
              }}>
              <AnimatedNumber value={0} />
            </ProgressBar>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
