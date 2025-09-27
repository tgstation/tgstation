import {
  AnimatedNumber,
  Box,
  Button,
  Flex,
  Icon,
  NumberInput,
  ProgressBar,
  RoundGauge,
  Section,
  Table,
} from 'tgui-core/components';
import { round, toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { COLORS } from '../constants';
import { Window } from '../layouts';
import { type Beaker, BeakerSectionDisplay } from './common/BeakerDisplay';

export type ActiveReaction = {
  name: string;
  danger: BooleanLike;
  overheat: BooleanLike;
  purityAlert: number;
  quality: number;
  inverse: number;
  minPure: number;
  reactedVol: number;
  targetVol: number;
};

type Data = {
  targetTemp: number;
  isActive: BooleanLike;
  upgradeLevel: number;
  beaker: Beaker;
  currentTemp: number;
  activeReactions: ActiveReaction[];
  isFlashing: number;
  acidicBufferVol: number;
  basicBufferVol: number;
  dispenseVolume: number;
};

type ReactionDisplayProps = {
  beaker: Beaker;
  isFlashing: number;
  activeReactions: ActiveReaction[];
  highQualityDisplay: BooleanLike;
  highDangerDisplay: BooleanLike;
};

export const ReactionDisplay = (props: ReactionDisplayProps) => {
  const {
    beaker,
    isFlashing,
    activeReactions,
    highQualityDisplay,
    highDangerDisplay,
  } = props;

  return (
    <Section
      title="Reactions"
      buttons={
        <Flex>
          <Flex.Item color="label">
            <AnimatedNumber
              value={beaker.pH}
              format={(value) => `pH: ${round(value, 3)}`}
            />
          </Flex.Item>
          <Flex.Item>
            <RoundGauge
              size={1.6}
              value={beaker.pH}
              minValue={0}
              maxValue={14}
              alertAfter={isFlashing}
              format={() => ''}
              ranges={{
                red: [-0.22, 1.5],
                orange: [1.5, 3],
                yellow: [3, 4.5],
                olive: [4.5, 5],
                good: [5, 6],
                green: [6, 8.5],
                teal: [8.5, 9.5],
                blue: [9.5, 11],
                purple: [11, 12.5],
                violet: [12.5, 14],
              }}
            />
          </Flex.Item>
        </Flex>
      }
    >
      {(activeReactions.length === 0 && (
        <Box color="label">No active reactions.</Box>
      )) || (
        <Table>
          <Table.Row>
            <Table.Cell bold color="label">
              Reaction
            </Table.Cell>
            <Table.Cell bold color="label">
              {!highQualityDisplay ? 'Status' : 'Reaction quality'}
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
                {!highQualityDisplay ? (
                  <Icon
                    name={reaction.danger ? 'exclamation-triangle' : 'spinner'}
                    color={reaction.danger && 'red'}
                    spin={!reaction.danger}
                    ml={2.5}
                  />
                ) : (
                  <RoundGauge
                    size={1.3}
                    value={reaction.quality}
                    minValue={0}
                    maxValue={1}
                    alertAfter={reaction.purityAlert}
                    format={(value) => ''}
                    ml={5}
                    ranges={{
                      red: [0, reaction.minPure],
                      orange: [reaction.minPure, reaction.inverse],
                      yellow: [reaction.inverse, 0.8],
                      green: [0.8, 1],
                    }}
                  />
                )}
              </Table.Cell>
              <Table.Cell width={'100px'}>
                {highDangerDisplay ? (
                  <>
                    {!!reaction.overheat && (
                      <Icon
                        name="thermometer-full"
                        color="red"
                        style={{ transform: 'scale(1.7)' }}
                        mr="5px"
                      />
                    )}
                    <ProgressBar
                      value={reaction.reactedVol}
                      minValue={0}
                      maxValue={reaction.targetVol}
                      textAlign="center"
                      width={8}
                      color={reaction.overheat ? 'red' : 'label'}
                    >
                      {reaction.targetVol}u
                    </ProgressBar>
                  </>
                ) : (
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
  );
};

export const ChemHeater = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    targetTemp,
    isActive,
    isFlashing,
    beaker,
    currentTemp,
    acidicBufferVol,
    basicBufferVol,
    dispenseVolume,
    upgradeLevel,
    activeReactions = [],
  } = data;
  const isBeakerLoaded = beaker !== null;

  return (
    <Window width={350} height={350}>
      <Window.Content scrollable>
        <Section
          title="Controls"
          buttons={
            <Flex>
              <Button
                icon={isActive ? 'power-off' : 'times'}
                selected={isActive}
                onClick={() => act('power')}
              >
                {isActive ? 'On' : 'Off'}
              </Button>
            </Flex>
          }
        >
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
                  tickWhileDragging
                  width="45px"
                  unit="u"
                  step={1}
                  stepPixelSize={3}
                  value={dispenseVolume}
                  minValue={1}
                  maxValue={10}
                  onChange={(value) =>
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
                  tickWhileDragging
                  width="65px"
                  unit="K"
                  step={10}
                  stepPixelSize={3}
                  value={round(targetTemp, 0.1)}
                  minValue={0}
                  maxValue={1000}
                  onChange={(value) =>
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
                textAlign="center"
              >
                {`${acidicBufferVol}u`}
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
                      format={(value) => `${toFixed(value)} K`}
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
                {`${basicBufferVol}u`}
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
          <ReactionDisplay
            beaker={beaker}
            isFlashing={isFlashing}
            activeReactions={activeReactions}
            highQualityDisplay={upgradeLevel >= 4}
            highDangerDisplay={upgradeLevel >= 2}
          />
        )}
        <BeakerSectionDisplay beaker={beaker} showpH={false} />
      </Window.Content>
    </Window>
  );
};
