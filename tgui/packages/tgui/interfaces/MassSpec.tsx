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

const GRAPH_MAX_WIDTH = 1060;
const GRAPH_MAX_HEIGHT = 250;

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
    <Window width={1050} height={650}>
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
          />
        </Section>
      </Window.Content>
    </Window>
  );
};

type ProfileProps = {
  lowerRange: number;
  upperRange: number;
  beaker: Beaker;
};

const BeakerMassProfile = (props: ProfileProps) => {
  const { lowerRange, upperRange, beaker } = props;

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
                Mass
              </Table.Cell>
              <Table.Cell bold collapsing color="label">
                Volume
              </Table.Cell>
              <Table.Cell bold collapsing color="label">
                Purity
              </Table.Cell>
              <Table.Cell bold collapsing color="label">
                Type
              </Table.Cell>
              <Table.Cell bold collapsing color="label">
                Results
              </Table.Cell>
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
                    {reagent.mass}
                  </Table.Cell>
                  <Table.Cell collapsing color={selected ? 'green' : 'default'}>
                    {reagent.volume}
                  </Table.Cell>
                  <Table.Cell collapsing color={selected ? 'green' : 'default'}>
                    {`${reagent.purity}%`}
                  </Table.Cell>
                  <Table.Cell collapsing color={color}>
                    ▮{reagent.type}
                  </Table.Cell>
                  {<Table.Cell>{reagent.log}</Table.Cell>}
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

  const base_line = GRAPH_MAX_HEIGHT * 0.85;
  const base_width = GRAPH_MAX_WIDTH - 123;
  const scale = base_width / GRAPH_MAX_WIDTH;

  return (
    <Box
      style={{
        width: `${GRAPH_MAX_WIDTH}px`,
        height: `${GRAPH_MAX_HEIGHT}px`,
      }}
    >
      <svg
        style={{
          position: 'absolute',
          width: `${GRAPH_MAX_WIDTH}px`,
          height: `${GRAPH_MAX_HEIGHT}px`,
        }}
      >
        {/* x axis*/}
        <text text-anchor="middle" fill="white">
          <tspan
            x="40%"
            y={`${base_line + 35}px`}
            font-weight="bold"
            font-size="16"
          >
            Mass (G)
          </tspan>
          <tspan x="0%" y={`${base_line + 20}px`}>
            {graphLowerRange}
          </tspan>
          <tspan x="16%" y={`${base_line + 20}px`}>
            {round(graphLowerRange + graphIncrement, 1)}
          </tspan>
          <tspan x="32%" y={`${base_line + 20}px`}>
            {round(graphLowerRange + graphIncrement * 2, 1)}
          </tspan>
          <tspan x="48%" y={`${base_line + 20}px`}>
            {round(graphLowerRange + graphIncrement * 3, 1)}
          </tspan>
          <tspan x="64%" y={`${base_line + 20}px`}>
            {round(graphLowerRange + graphIncrement * 4, 1)}
          </tspan>
          <tspan x="80%" y={`${base_line + 20}px`}>
            {graphUpperRange}
          </tspan>
        </text>
        <line
          x1={0}
          y1={base_line}
          x2={base_width}
          y2={base_line}
          stroke={'white'}
          stroke-width={3}
        />

        {/* y axis*/}
        <text text-anchor="middle" fill="white">
          <tspan x={`${base_width + 20}px`} y="80%">
            0
          </tspan>
          <tspan x={`${base_width + 20}px`} y="65%">
            {round(maxAbsorbance * 0.2, 1)}
          </tspan>
          <tspan x={`${base_width + 20}px`} y="50%">
            {round(maxAbsorbance * 0.4, 1)}
          </tspan>
          <tspan x={`${base_width + 20}px`} y="35%">
            {round(maxAbsorbance * 0.6, 1)}
          </tspan>
          <tspan x={`${base_width + 20}px`} y="20%">
            {round(maxAbsorbance * 0.8, 1)}
          </tspan>
          <tspan x={`${base_width + 20}px`} y="5%">
            {round(maxAbsorbance, 1)}
          </tspan>
        </text>
        <text
          text-anchor="middle"
          transform={`translate(${base_width + 35},${
            GRAPH_MAX_HEIGHT * 0.4
          }) rotate(90) scale(1, 1.2)`}
          fill="white"
          font-size="17"
          font-weight="bold"
        >
          <tspan>Absorbance (AU)</tspan>
        </text>
        <line
          x1={base_width}
          y1={base_line}
          x2={base_width}
          y2={0}
          stroke={'white'}
          stroke-width={3}
        />

        {/* Graph */}
        <g transform={`translate(0 0) scale(${scale} 1)`}>
          {reagentPeaks.map((peak) => (
            // Triangle peak
            <polygon
              key={peak.name}
              points={`${
                ((peak.mass - 5) / graphUpperRange) * base_width
              },${base_line}
                ${(peak.mass / graphUpperRange) * base_width},${
                  base_line +
                  50 -
                  (peak.volume / maxAbsorbance) * (base_line + 50)
                }
                ${
                  ((peak.mass + 5) / graphUpperRange) * base_width
                }, ${base_line}`}
              opacity="0.6"
              style={{
                fill: peak.type === 'Inverted' ? '#b60046' : '#3cf096',
              }}
            />
          ))}
        </g>

        {/* Background */}
        <polygon
          points={`${
            (lowerRange / deltaRange) * base_width * scale
          },${base_line} ${(lowerRange / deltaRange) * base_width * scale},0 ${
            (upperRange / deltaRange) * base_width * scale
          },0 ${(upperRange / deltaRange) * base_width * scale},${base_line}`}
          opacity="0.2"
          style={{ fill: 'blue' }}
        />
      </svg>

      {/* Sliders */}
      <Slider
        name={'Left slider'}
        step={graphUpperRange / base_width}
        suppressFlicker
        height={17.2}
        format={(value: number) => round(value, 2)}
        width={(centerValue / graphUpperRange) * base_width + 'px'}
        value={lowerRange}
        minValue={graphLowerRange / scale}
        maxValue={centerValue / scale}
        color={'invisible'}
        onDrag={(e, value) =>
          act('leftSlider', {
            value: value,
          })
        }
      />
      <Slider
        name={'Right slider'}
        height={17.2}
        suppressFlicker
        format={(value: number) => round(value, 2)}
        step={graphUpperRange / base_width}
        width={base_width - (centerValue / graphUpperRange) * base_width + 'px'}
        value={upperRange}
        minValue={centerValue / scale}
        maxValue={graphUpperRange / scale}
        color={'invisible'}
        onDrag={(e, value) =>
          act('rightSlider', {
            value: value,
          })
        }
      />
      <Slider
        name={'Center slider'}
        step={graphUpperRange / base_width}
        suppressFlicker
        mt={1.2}
        value={centerValue}
        height={1.9}
        format={(value: number) => round(value, 2)}
        width={base_width + 'px'}
        minValue={(graphLowerRange + 1) / scale}
        maxValue={(graphUpperRange - 1) / scale}
        color={'invisible'}
        onDrag={(e, value) =>
          act('centerSlider', {
            value: value,
          })
        }
      />
    </Box>
  );
};
