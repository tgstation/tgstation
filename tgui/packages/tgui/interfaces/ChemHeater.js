import { round, toFixed } from 'common/math';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';
import { BeakerContents } from './common/BeakerContents';

export const ChemHeater = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    targetTemp,
    isActive,
    isBeakerLoaded,
    currentTemp,
    beakerCurrentVolume,
    beakerMaxVolume,
    beakerContents = [],
  } = data;
  return (
    <Window
      width={275}
      height={320}>
      <Window.Content scrollable>
        <Section
          title="Thermostat"
          buttons={(
            <Button
              icon={isActive ? 'power-off' : 'times'}
              selected={isActive}
              content={isActive ? 'On' : 'Off'}
              onClick={() => act('power')} />
          )}>
          <LabeledList>
            <LabeledList.Item label="Target">
              <NumberInput
                width="65px"
                unit="K"
                step={10}
                stepPixelSize={3}
                value={round(targetTemp)}
                minValue={0}
                maxValue={1000}
                onDrag={(e, value) => act('temperature', {
                  target: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Reading">
              <Box
                width="60px"
                textAlign="right">
                {isBeakerLoaded && (
                  <AnimatedNumber
                    value={currentTemp}
                    format={value => toFixed(value) + ' K'} />
                ) || '—'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Beaker"
          buttons={!!isBeakerLoaded && (
            <>
              <Box inline color="label" mr={2}>
                {beakerCurrentVolume} / {beakerMaxVolume} units
              </Box>
              <Button
                icon="eject"
                content="Eject"
                onClick={() => act('eject')} />
            </>
          )}>
          <BeakerContents
            beakerLoaded={isBeakerLoaded}
            beakerContents={beakerContents} />
        </Section>
      </Window.Content>
    </Window>
  );
};
