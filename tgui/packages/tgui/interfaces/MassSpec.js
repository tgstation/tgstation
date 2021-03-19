import { useBackend } from '../backend';
import { Box, Button, Section, Slider, Stack, Dimmer, Icon } from '../components';
import { Window } from '../layouts';
import { BeakerContents } from './common/BeakerContents';

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
    peakHeight,
    beaker1,
    beaker2,
    beaker1Contents = [],
    beaker2Contents = [],
  } = data;

  const centerValue = (lowerRange + upperRange) / 2;

  return (
    <Window
      width={490}
      height={650}>
      <Window.Content scrollable>
        {!!processing && (
          <Dimmer fontSize="32px">
            <Icon name="cog" spin={1} />
            {' Purifying...'}
          </Dimmer>
        )}
        <Section
          title="Mass Spectroscopy"
          buttons={
            <Button
                    icon="power-off"
                    content="Start"
                    disabled={!!processing || !beaker1Contents.length || !beaker2}
                    tooltip={!beaker1Contents.length ? "Missing input reagents!" : !beaker2 ? "Missing an output beaker!" : "Begin purifying"}
                    tooltipPosition="left"
                    onClick={() => act('activate')} />
          }>
            {beaker1Contents.length && (
              <>
                  <MassSpectroscopy
                    lowerRange={lowerRange}
                    centerValue={centerValue}
                    upperRange={upperRange}
                    graphLowerRange={graphLowerRange}
                    graphUpperRange={graphUpperRange}
                    maxAbsorbance={peakHeight}
                    reagentPeaks={beaker1Contents} />

              </>
            ) || (
              <Box>
                Please insert an input beaker with reagents!
              </Box>
            )}
            <Box>
              {log}
            </Box>
        </Section>

        <Section
          title="Input beaker"
          buttons={!!beaker1Contents && (
            <Button
              icon="eject"
              content="Eject"
              disabled={!beaker1}
              onClick={() => act('eject1')} />
          )}>
          <BeakerContents
            beakerLoaded={!!beaker1}
            beakerContents={beaker1Contents} />
        </Section>
        <Section
          title="Output beaker"
          buttons={!!beaker2Contents && (
            <Button
              icon="eject"
              content="Eject"
              disabled={!beaker2}
              onClick={() => act('eject2')} />
          )}>
          <BeakerContents
            beakerLoaded={!!beaker2}
            beakerContents={beaker2Contents} />
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
  } = props;

  const deltaRange = graphUpperRange - graphLowerRange;

  const graphIncrement = deltaRange * 0.2;

  return (
    <>
    <Box position="absolute" x="200" transform="translate(30,30)">
      <svg background-size="200px" width="200" height="400">
        <text x="0" y="250" text-anchor="middle" fill="white" font-size="16" transform="translate(0,0) scale(0.8 0.8)">
          {/* x axis*/}
          <tspan x="250" y="318" font-weight="bold" font-size="1.4em">Mass (g)</tspan>
          <tspan x="0" y="283">{graphLowerRange}</tspan>
          <tspan x="100" y="283">{graphLowerRange + (graphIncrement)}</tspan>
          <tspan x="200" y="283">{graphLowerRange + (graphIncrement * 2)}</tspan>
          <tspan x="300" y="283">{graphLowerRange + (graphIncrement * 3)}</tspan>
          <tspan x="400" y="283">{graphLowerRange + (graphIncrement * 4)}</tspan>
          <tspan x="500" y="283">{graphUpperRange}</tspan>
          {/* y axis*/}
          <tspan x="520" y="0" dy="6">{maxAbsorbance}</tspan>
          <tspan x="520" y="50" dy="6">{maxAbsorbance * 0.8}</tspan>
          <tspan x="520" y="100" dy="6">{maxAbsorbance * 0.6}</tspan>
          <tspan x="520" y="150" dy="6">{maxAbsorbance * 0.4}</tspan>
          <tspan x="520" y="200" dy="6">{maxAbsorbance * 0.2}</tspan>
          <tspan x="520" y="250" dy="6">0</tspan>
        </text>
        <text text-anchor="middle" transform="translate(430,100) rotate(90) scale(0.8 0.8)" fill="white" font-size="16">
          <tspan font-weight="bold" font-size="1.4em">Absorbance (AU)</tspan>
        </text>
        <g transform="translate(0, 0) scale(0.8 0.8)">
          {reagentPeaks.map(peak => (
            <polygon key={peak.name} points={`${((peak.mass - 10) / graphUpperRange) * 500},265 ${((peak.mass) / graphUpperRange) * 500},${250 - ((peak.volume / maxAbsorbance) * 250)} ${((peak.mass + 10) / graphUpperRange) * 500},265 `} opacity="1" style={`fill:${peak.color}`} />
          ))}
          <polygon points={`${(lowerRange/deltaRange)*500},265 ${(lowerRange/deltaRange)*500},0 ${(upperRange/deltaRange)*500},0 ${(upperRange/deltaRange)*500},265`} opacity="0.25" style={`fill:blue`} />
          <line x1={0} y1={263} x2={507} y2={263} stroke={"white"} stroke-width={3}/>
          <line x1={505} y1={264} x2={505} y2={0} stroke={"white"} stroke-width={3}/>
        </g>
      </svg>
      </Box>
      <Box>
      <Slider
        name={"Left slider"}
        position="relative"
        step={1}
        height={17.2}
        animated={true}
        stepPixelSize={1}
        width={(centerValue/graphUpperRange)*400+"px"}
        value={lowerRange}
        minValue={graphLowerRange}
        maxValue={centerValue}
        color={"#ffffff"}
        ranges={{
          good: [-Infinity, Infinity]
        }}
        onDrag={(e, value) => act('leftSlider', {
          value: value,
        })} >
        {" "}
      </Slider>
      <Slider
        name={"Right slider"}
        position="absolute"
        //x={(centerValue/deltaRange)*100}
        //y={100}
        height={17.2}
        step={1}
        animated={true}
        stepPixelSize={1}
        width={400-((centerValue/graphUpperRange)*400)+"px"}
        //width={((((500*0.7)/graphUpperRange))-(centerValue/graphUpperRange))+"px"}
        //width={(500-centerValue-lowerRange)*0.7+"px"}
        value={upperRange}
        minValue={centerValue}
        maxValue={graphUpperRange}
        color={"#ffffff"}
        ranges={{
          bad: [-Infinity, Infinity]
        }}
        onDrag={(e, value) => act('rightSlider', {
          value: value,
        })} >
        {" "}
      </Slider>
        <Box mt="5" mb="5">
        <Slider
          name={"Center slider"}
          position="relative"
          //y={20}
          step={1}
          mt={0.1}
          mb={5}
          stepPixelSize={1}
          value={centerValue}
          height={1.9}
          format={value => ""}
          width={400+"px"}
          minValue={graphLowerRange + 1}
          maxValue={graphUpperRange - 1}
          color={"#ffffff"}
          //fillValue={500}
          ranges={{
            average: [-Infinity, Infinity]
          }}
          onDrag={(e, value) => act('centerSlider', {
            value: value,
          })} >
        </Slider>
        </Box>
    </Box>
    </>
  );
};
