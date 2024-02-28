import { round } from 'common/math';
import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Dimmer,
  Icon,
  Section,
  Slider,
  Table,
} from '../components';
import { Window } from '../layouts';

type Reagent = {
  name: string;
  volume: number;
  mass: number;
  purity: number;
  type: string;
  log: string;
};

type Beaker = {
  currentVolume: number;
  maxVolume: number;
  contents: Reagent[];
};

type Data = {
  lowerRange: number;
  upperRange: number;
  processing: BooleanLike;
  eta: number;
  graphUpperRange: number;
  peakHeight: number;
  beaker1: Beaker;
  beaker2: Beaker;
};

export const MassSpec = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    processing,
    lowerRange,
    upperRange,
    graphUpperRange,
    eta,
    peakHeight,
    beaker1,
    beaker2,
  } = data;

  const centerValue = (lowerRange + upperRange) / 2;
  const beaker_1_has_contents = beaker1?.contents?.length > 0;

  return (
    <Window width={490} height={650}>
      <Window.Content scrollable>
        {!!processing && (
          <Dimmer fontSize="32px">
            <Icon name="cog" spin={1} />
            {' Purifying... ' + round(eta, 0) + 's'}
          </Dimmer>
        )}
        <Section
          title="Mass Spectroscopy"
          buttons={
            <Button
              icon="power-off"
              disabled={
                !!processing || eta <= 0 || !beaker_1_has_contents || !beaker2
              }
              tooltip={
                !beaker_1_has_contents
                  ? 'Missing input reagents!'
                  : !beaker2
                    ? 'Missing an output beaker!'
                    : eta <= 0
                      ? 'Already at max purity'
                      : 'Begin purifying'
              }
              tooltipPosition="left"
              onClick={() => act('activate')}
            >
              Start
            </Button>
          }
        >
          {(beaker_1_has_contents && (
            <MassSpectroscopy
              lowerRange={lowerRange}
              centerValue={centerValue}
              upperRange={upperRange}
              graphUpperRange={graphUpperRange}
              maxAbsorbance={peakHeight}
              reagentPeaks={beaker1.contents}
            />
          )) || <Box>Please insert an input beaker with reagents!</Box>}
        </Section>

        <Section
          title="Input beaker"
          buttons={
            !!beaker1 && (
              <>
                {
                  <Box inline color="label" mr={2}>
                    {beaker1.currentVolume} / {beaker1.maxVolume} units
                  </Box>
                }
                <Button icon="eject" onClick={() => act('eject1')}>
                  Eject
                </Button>
              </>
            )
          }
        >
          <BeakerMassProfile
            lowerRange={lowerRange}
            upperRange={upperRange}
            beaker={beaker1}
          />
          {!!beaker_1_has_contents && (
            <Box>{'Eta of selection: ' + round(eta, 0) + ' seconds'}</Box>
          )}
        </Section>
        <Section
          title="Output beaker"
          buttons={
            !!beaker2 && (
              <>
                {
                  <Box inline color="label" mr={2}>
                    {beaker2.currentVolume} / {beaker2.maxVolume} units
                  </Box>
                }
                <Button icon="eject" onClick={() => act('eject2')}>
                  Eject
                </Button>
              </>
            )
          }
        >
          <BeakerMassProfile
            lowerRange={lowerRange}
            upperRange={upperRange}
            beaker={beaker2}
            details
          />
        </Section>
      </Window.Content>
    </Window>
  );
};

type ProfileProps = {
  lowerRange: number;
  upperRange: number;
  details?: BooleanLike;
  beaker: Beaker;
};

const BeakerMassProfile = (props: ProfileProps) => {
  const { lowerRange, upperRange, details, beaker } = props;

  return (
    <Box>
      {(!beaker && <Box color="label">No beaker loaded.</Box>) ||
        (beaker.contents.length === 0 && (
          <Box color="label">Beaker is empty.</Box>
        )) || (
          <Table className="candystripe">
            <Table.Row>
              <Table.Cell bold collapsing color="label">
                Reagent
              </Table.Cell>
              <Table.Cell bold collapsing color="label">
                Volume
              </Table.Cell>
              <Table.Cell bold collapsing color="label">
                Mass
              </Table.Cell>
              <Table.Cell bold collapsing color="label">
                Purity
              </Table.Cell>
              <Table.Cell bold collapsing color="label">
                Type
              </Table.Cell>
              {!!details && (
                <Table.Cell bold collapsing color="label">
                  Results
                </Table.Cell>
              )}
            </Table.Row>
            {beaker.contents.map((reagent) => {
              const selected =
                reagent.mass >= lowerRange && reagent.mass <= upperRange;
              const color = reagent.type === 'Inverted' ? '#b60046' : '#3cf096';

              return (
                <Table.Row key={reagent.name}>
                  <Table.Cell collapsing color={selected ? 'green' : 'default'}>
                    {reagent.name}
                  </Table.Cell>
                  <Table.Cell collapsing color={selected ? 'green' : 'default'}>
                    {reagent.volume}
                  </Table.Cell>
                  <Table.Cell collapsing color={selected ? 'green' : 'default'}>
                    {reagent.mass}
                  </Table.Cell>
                  <Table.Cell collapsing color={selected ? 'green' : 'default'}>
                    {`${reagent.purity}%`}
                  </Table.Cell>
                  <Table.Cell collapsing color={color}>
                    ▮{reagent.type}
                  </Table.Cell>
                  {details && <Table.Cell>{reagent.log}</Table.Cell>}
                </Table.Row>
              );
            })}
          </Table>
        )}
    </Box>
  );
};

type SpectroscopyProps = {
  lowerRange: number;
  centerValue: number;
  upperRange: number;
  graphUpperRange: number;
  maxAbsorbance: number;
  reagentPeaks: Reagent[];
};

const MassSpectroscopy = (props: SpectroscopyProps) => {
  const { act } = useBackend();
  const {
    lowerRange,
    centerValue,
    upperRange,
    graphUpperRange,
    maxAbsorbance,
    reagentPeaks = [],
  } = props;

  const graphLowerRange = 0;
  const deltaRange = graphUpperRange - graphLowerRange;
  const graphIncrement = deltaRange * 0.2;

  return (
    <>
      <Box
        style={{
          position: 'absolute',
          right: '255px',
          top: '25px',
        }}
      >
        <svg background-size="200px" width="200" height="400">
          <text
            x="0"
            y="250"
            text-anchor="middle"
            fill="white"
            font-size="16"
            transform="translate(0,0) scale(0.8 0.8)"
          >
            {/* x axis*/}
            <tspan x="250" y="318" font-weight="bold" font-size="1.4em">
              Mass (g)
            </tspan>
            <tspan x="0" y="283">
              {graphLowerRange}
            </tspan>
            <tspan x="100" y="283">
              {round(graphLowerRange + graphIncrement, 1)}
            </tspan>
            <tspan x="200" y="283">
              {round(graphLowerRange + graphIncrement * 2, 1)}
            </tspan>
            <tspan x="300" y="283">
              {round(graphLowerRange + graphIncrement * 3, 1)}
            </tspan>
            <tspan x="400" y="283">
              {round(graphLowerRange + graphIncrement * 4, 1)}
            </tspan>
            <tspan x="500" y="283">
              {graphUpperRange}
            </tspan>
            {/* y axis*/}
            <tspan x="520" y="0" dy="6">
              {round(maxAbsorbance, 1)}
            </tspan>
            <tspan x="520" y="50" dy="6">
              {round(maxAbsorbance * 0.8, 1)}
            </tspan>
            <tspan x="520" y="100" dy="6">
              {round(maxAbsorbance * 0.6, 1)}
            </tspan>
            <tspan x="520" y="150" dy="6">
              {round(maxAbsorbance * 0.4, 1)}
            </tspan>
            <tspan x="520" y="200" dy="6">
              {round(maxAbsorbance * 0.2, 1)}
            </tspan>
            <tspan x="520" y="250" dy="6">
              0
            </tspan>
          </text>
          <text
            text-anchor="middle"
            transform="translate(430,100) rotate(90) scale(0.8 0.8)"
            fill="white"
            font-size="16"
          >
            <tspan font-weight="bold" font-size="1.4em">
              Absorbance (AU)
            </tspan>
          </text>
          <g transform="translate(0, 0) scale(0.8 0.8)">
            {reagentPeaks.map((peak) => (
              // Triangle peak
              <polygon
                key={peak.name}
                points={`${((peak.mass - 10) / graphUpperRange) * 500},265 ${
                  (peak.mass / graphUpperRange) * 500
                },${250 - (peak.volume / maxAbsorbance) * 250} ${
                  ((peak.mass + 10) / graphUpperRange) * 500
                },265 `}
                opacity="0.6"
                style={{
                  fill: peak.type === 'Inverted' ? '#b60046' : '#3cf096',
                }}
              />
            ))}
            <polygon
              points={`${(lowerRange / deltaRange) * 500},265 ${
                (lowerRange / deltaRange) * 500
              },0 ${(upperRange / deltaRange) * 500},0 ${
                (upperRange / deltaRange) * 500
              },265`}
              opacity="0.2"
              style={{ fill: 'blue' }}
            />
            <line
              x1={0}
              y1={265}
              x2={502}
              y2={264}
              stroke={'white'}
              stroke-width={3}
            />
            <line
              x1={501}
              y1={264}
              x2={501}
              y2={0}
              stroke={'white'}
              stroke-width={3}
            />
          </g>
        </svg>
      </Box>
      <Box>
        <Slider
          name={'Left slider'}
          position="relative"
          step={graphUpperRange / 400}
          height={17.2}
          format={(value: number) => round(value, 2)}
          width={(centerValue / graphUpperRange) * 400 + 'px'}
          value={lowerRange}
          minValue={graphLowerRange}
          maxValue={centerValue}
          color={'invisible'}
          onDrag={(e, value) =>
            act('leftSlider', {
              value: value,
            })
          }
        />
        <Slider
          name={'Right slider'}
          position="absolute"
          height={17.2}
          format={(value: number) => round(value, 2)}
          step={graphUpperRange / 400}
          width={400 - (centerValue / graphUpperRange) * 400 + 'px'}
          value={upperRange}
          minValue={centerValue}
          maxValue={graphUpperRange}
          color={'invisible'}
          onDrag={(e, value) =>
            act('rightSlider', {
              value: value,
            })
          }
        />
        <Box>
          <Slider
            name={'Center slider'}
            position="relative"
            step={graphUpperRange / 400}
            mt={0.3}
            mb={5}
            value={centerValue}
            height={1.9}
            format={(value: number) => round(value, 2)}
            width={400 + 'px'}
            minValue={graphLowerRange + 1}
            maxValue={graphUpperRange - 1}
            color={'invisible'}
            onDrag={(e, value) =>
              act('centerSlider', {
                value: value,
              })
            }
          />
        </Box>
      </Box>
    </>
  );
};
