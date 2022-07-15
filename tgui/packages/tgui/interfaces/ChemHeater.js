import { round, toFixed } from 'common/math';
import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Flex, Icon, NumberInput, ProgressBar, RoundGauge, Section, Table } from '../components';
import { COLORS } from '../constants';
import { Window } from '../layouts';
import { BeakerContents } from './common/BeakerContents';

export const ChemHeater = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    targetTemp,
    isActive,
    isFlashing,
    currentpH,
    isBeakerLoaded,
    currentTemp,
    beakerCurrentVolume,
    beakerMaxVolume,
    acidicBufferVol,
    basicBufferVol,
    dispenseVolume,
    upgradeLevel,
    tutorialMessage,
    beakerContents = [],
    activeReactions = [],
  } = data;
  return (
    <Window width={330} height={tutorialMessage ? 680 : 350}>
      <Window.Content scrollable>
        <Section
          title="Controls"
          buttons={
            <Flex>
              <Button
                icon={'question'}
                selected={tutorialMessage}
                content={'Help'}
                left={-2}
                tooltip={'Guides you through a tutorial reaction!'}
                onClick={() => act('help')}
              />
              <Button
                icon={isActive ? 'power-off' : 'times'}
                selected={isActive}
                content={isActive ? 'On' : 'Off'}
                onClick={() => act('power')}
              />
            </Flex>
          }>
          <Table>
            <Table.Row>
              <Table.Cell bold collapsing color="label">
                Heat
              </Table.Cell>
              <Table.Cell />
              <Table.Cell bold collapsing color="label">
                Buffers
              </Table.Cell>
              <Table.Cell />
              <Table.Cell>
                <NumberInput
                  width="45px"
                  unit="u"
                  step={1}
                  stepPixelSize={3}
                  value={dispenseVolume}
                  minValue={1}
                  maxValue={10}
                  onDrag={(e, value) =>
                    act('disp_vol', {
                      target: value,
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell collapsing color="label">
                Target:
              </Table.Cell>
              <Table.Cell>
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
              </Table.Cell>
              <Table.Cell collapsing color="label">
                Acidic:
              </Table.Cell>
              <Table.Cell>
                <Button
                  icon={'syringe'}
                  disabled={!acidicBufferVol}
                  tooltip={'Inject'}
                  tooltipPosition={'left'}
                  onClick={() =>
                    act('acidBuffer', {
                      target: 1,
                    })
                  }
                />
              </Table.Cell>
              <Table.Cell
                color={COLORS.reagent.acidicbuffer}
                textAlign="center">
                {acidicBufferVol + 'u'}
              </Table.Cell>
              <Table.Cell>
                <Button
                  icon={'upload'}
                  tooltip={'Draw all'}
                  tooltipPosition={'top'}
                  disabled={acidicBufferVol === 100}
                  onClick={() =>
                    act('acidBuffer', {
                      target: -100,
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell collapsing color="label">
                Reading:
              </Table.Cell>
              <Table.Cell collapsing color="default">
                <Box width="60px" textAlign="right">
                  {(isBeakerLoaded && (
                    <AnimatedNumber
                      value={currentTemp}
                      format={(value) => toFixed(value) + ' K'}
                    />
                  )) ||
                    '—'}
                </Box>
              </Table.Cell>
              <Table.Cell collapsing color="label">
                Basic:
              </Table.Cell>
              <Table.Cell>
                <Button
                  icon={'syringe'}
                  tooltip={'Inject'}
                  tooltipPosition={'left'}
                  disabled={!basicBufferVol}
                  onClick={() =>
                    act('basicBuffer', {
                      target: 1,
                    })
                  }
                />
              </Table.Cell>
              <Table.Cell color={COLORS.reagent.basicbuffer} textAlign="center">
                {basicBufferVol + 'u'}
              </Table.Cell>
              <Table.Cell>
                <Button
                  icon={'upload'}
                  tooltip={'Draw all'}
                  disabled={basicBufferVol === 100}
                  onClick={() =>
                    act('basicBuffer', {
                      target: -100,
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
          </Table>
        </Section>
        {!!isBeakerLoaded && (
          <Section
            title="Reactions"
            buttons={
              <Flex>
                <Flex.Item color="label">
                  <AnimatedNumber
                    value={currentpH}
                    format={(value) => 'pH: ' + round(value, 3)}
                  />
                </Flex.Item>
                <Flex.Item>
                  <AnimatedNumber value={currentpH}>
                    {(_, value) => (
                      <RoundGauge
                        size={1.6}
                        value={value}
                        minValue={0}
                        maxValue={14}
                        alertAfter={isFlashing}
                        content={'test'}
                        format={(value) => null}
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
                    )}
                  </AnimatedNumber>
                </Flex.Item>
              </Flex>
            }>
            {(activeReactions.length === 0 && (
              <Box color="label">No active reactions.</Box>
            )) || (
              <Table>
                <Table.Row>
                  <Table.Cell bold color="label">
                    Reaction
                  </Table.Cell>
                  <Table.Cell bold color="label">
                    {upgradeLevel < 4 ? 'Status' : 'Reaction quality'}
                  </Table.Cell>
                  <Table.Cell bold color="label">
                    Target
                  </Table.Cell>
                </Table.Row>
                {activeReactions.map((reaction) => (
                  <Table.Row key="reactions">
                    <Table.Cell width={'60px'} color={reaction.danger && 'red'}>
                      {reaction.name}
                    </Table.Cell>
                    <Table.Cell width={'100px'} pr={'10px'}>
                      {(upgradeLevel < 4 && (
                        <Icon
                          name={
                            reaction.danger ? 'exclamation-triangle' : 'spinner'
                          }
                          color={reaction.danger && 'red'}
                          spin={!reaction.danger}
                          ml={2.5}
                        />
                      )) || (
                        <AnimatedNumber value={reaction.quality}>
                          {(_, value) => (
                            <RoundGauge
                              size={1.3}
                              value={value}
                              minValue={0}
                              maxValue={1}
                              alertAfter={reaction.purityAlert}
                              content={'test'}
                              format={(value) => null}
                              ml={5}
                              ranges={{
                                'red': [0, reaction.minPure],
                                'orange': [reaction.minPure, reaction.inverse],
                                'yellow': [reaction.inverse, 0.8],
                                'green': [0.8, 1],
                              }}
                            />
                          )}
                        </AnimatedNumber>
                      )}
                    </Table.Cell>
                    <Table.Cell width={'70px'}>
                      {(upgradeLevel > 2 && (
                        <ProgressBar
                          value={reaction.reactedVol}
                          minValue={0}
                          maxValue={reaction.targetVol}
                          textAlign={'center'}
                          icon={reaction.overheat && 'thermometer-full'}
                          width={7}
                          color={reaction.overheat ? 'red' : 'label'}>
                          {reaction.targetVol}u
                        </ProgressBar>
                      )) || (
                        <Box color={reaction.danger && 'red'} ml={2}>
                          {reaction.targetVol}u
                        </Box>
                      )}
                    </Table.Cell>
                  </Table.Row>
                ))}
                <Table.Row />
              </Table>
            )}
          </Section>
        )}
        {tutorialMessage && (
          <Section title="Tutorial" preserveWhitespace>
            <img src={resolveAsset('chem_help_advisor.gif')} width="30px" />
            {tutorialMessage}
          </Section>
        )}
        <Section
          title="Beaker"
          buttons={
            !!isBeakerLoaded && (
              <>
                <Box inline color="label" mr={2}>
                  {beakerCurrentVolume} / {beakerMaxVolume} units
                </Box>
                <Button
                  icon="eject"
                  content="Eject"
                  onClick={() => act('eject')}
                />
              </>
            )
          }>
          <BeakerContents
            beakerLoaded={isBeakerLoaded}
            beakerContents={beakerContents}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
