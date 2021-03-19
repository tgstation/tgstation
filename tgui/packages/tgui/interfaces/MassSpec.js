import { useBackend, useSharedState } from '../backend';
import { AnimatedNumber, Box, Button, ColorBox, LabeledList, NumberInput, Section, Table, Chart, Slider } from '../components';
import { Window } from '../layouts';


export const MassSpec = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    processing,
    lowerRange,
    upperRange,
    graphUpperRange,
    graphLowerRange,
    log,
    eta,
    beaker1Vol,
    beaker1pH,
    peakHeight,
    beaker1Contents = [],
    beaker2Contents = [],
  } = data;

  const centerValue = (lowerRange + upperRange) /2;

  return (
    <Window
      width={565}
      height={620}>
      <Window.Content scrollable>
        <Section
          title="Mass spectroscopy">
          <MassSpectroscopy
            lowerRange={lowerRange}
            centerValue={centerValue}
            upperRange={upperRange}
            graphLowerRange={graphLowerRange}
            graphUpperRange={graphUpperRange}
            maxAbsorbance={peakHeight}
            reagentPeaks={beaker1Contents} />
        </Section>
      </Window.Content>
    </Window>
  );
};

const MassSpectroscopy = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    lowerRange,
    centerValue,
    upperRange,
    graphUpperRange,
    graphLowerRange,
    maxAbsorbance,
    reagentPeaks = [],
  } = data;

  const graphIncrement = (graphUpperRange - graphLowerRange) * 0.2;

  return (
    <Box>
      <Section
        title="Mass Spectroscopy"
        position="relative" />
      <svg background-size="20px" width="100" height="150" >
        <defs>
          <clipPath id="cut-off-excess">
            <rect x="0" y="0" width="500" height="250" />
          </clipPath>
        </defs>
        <text transform="scale(0.5 0.5)" x="0" y="250" text-anchor="middle" fill="white" font-size="16">
          {/* x axis*/}
          <tspan x="250" y="290" font-weight="bold" font-size="1.4em">Mass (g)</tspan>
          <tspan x="0" y="270">{graphLowerRange}</tspan>
          <tspan x="100" y="270">{graphLowerRange + (graphIncrement)}</tspan>
          <tspan x="200" y="270">{graphLowerRange + (graphIncrement * 2)}</tspan>
          <tspan x="300" y="270">{graphLowerRange + (graphIncrement * 3)}</tspan>
          <tspan x="400" y="270">{graphLowerRange + (graphIncrement * 4)}</tspan>
          <tspan x="500" y="270">{graphUpperRange}</tspan>
          {/* y axis*/}
          <tspan x="-20" y="0" dy="6">{maxAbsorbance}</tspan>
          <tspan x="-20" y="50" dy="6">{maxAbsorbance * 0.8}</tspan>
          <tspan x="-20" y="100" dy="6">{maxAbsorbance * 0.6}</tspan>
          <tspan x="-20" y="150" dy="6">{maxAbsorbance * 0.4}</tspan>
          <tspan x="-20" y="200" dy="6">{maxAbsorbance * 0.2}</tspan>
          <tspan x="-20" y="250" dy="6">0</tspan>
        </text>
        <text transform="scale(0.5 0.5)" x="0" y="0" text-anchor="middle" transform="rotate(90) scale(0.5 0.5)" fill="white" font-size="16" >
          <tspan x="120" y="60" font-weight="bold" font-size="1.4em">Absorbance (AU)</tspan>
        </text>
        <g transform="scale(0.5 0.5)">
          {reagentPeaks.map(peak => (
            <polygon key={peak.name} points={`${((peak.mass-10)/graphUpperRange)*500},250 ${((peak.mass)/graphUpperRange)*500},${250-((peak.volume/maxAbsorbance)*250)} ${((peak.mass+10)/graphUpperRange)*500},0 `} opacity="1" style={`fill:${phase.color}`} />
          ))}
          <polygon points={`${lowerRange*5},250 ${lowerRange*5},0 ${upperRange*5},0 ${upperRange*5},250`} opacity="0.5" style={`fill:blue`} />
        </g>
      </svg>

      <Slider
        name={"Left slider"}
        position="relative"
        y={80}
        step={0.1}
        height={0.5}
        stepPixelSize={1}
        width={centerValue+"%"}
        value={lowerRange}
        minValue={graphLowerRange}
        maxValue={centerValue}
        color="#333333"
        onDrag={(e, value) => act('leftSlider', {
          target: value,
        })} >
        {" "}
      </Slider>
      <Slider
        name={"Right slider"}
        position="absolute"
        x={centerValue}
        y={100}
        height={1}
        step={0.1}
        stepPixelSize={1}
        width={(100 - centerValue) + "%"}
        value={upperRange}
        minValue={centerValue}
        maxValue={graphUpperRange}
        color="#00bb00"
        onDrag={(e, value) => act('rightSlider', {
          target: value,
        })} >
        {" "}
      </Slider>
      <Section position="relative" height="100px">
        <Slider
          name={"Center slider"}
          position="relative"
          step={0.1}
          stepPixelSize={1}
          value={centerValue}
          height={0.1}
          minValue={graphLowerRange+1}
          maxValue={graphUpperRange-1}
          color="#eeeeee"
          onDrag={(e, value) => act('centerSlider', {
            target: value,
          })} >
          <text>Test2</text>
        </Slider>
        <text>Test2</text>
      </Section>
    </Box>
  );
};
