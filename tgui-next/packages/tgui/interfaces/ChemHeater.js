import { round, toFixed } from 'common/math';
import { Fragment } from 'inferno';
import { act } from '../byond';
import { AnimatedNumber, Box, Button, LabeledList, NumberInput, Section } from '../components';
import { BeakerContents } from './common/BeakerContents';

export const ChemHeater = props => {
  const { state } = props;
  const { ref } = state.config;
  const {
    targetTemp,
    isActive,
    isBeakerLoaded,
    currentTemp,
    beakerCurrentVolume,
    beakerMaxVolume,
    beakerContents = [],
  } = state.data;
  return (
    <Fragment>
      <Section
        title="Thermostat"
        buttons={(
          <Button
            icon={isActive ? 'power-off' : 'times'}
            selected={isActive}
            content={isActive ? 'On' : 'Off'}
            onClick={() => act(ref, 'power')} />
        )}>
        <LabeledList>
          <LabeledList.Item label="Target">
            <NumberInput
              width="65px"
              unit="K"
              step={2}
              stepPixelSize={1}
              value={round(targetTemp)}
              minValue={0}
              maxValue={1000}
              onDrag={(e, value) => act(ref, 'temperature', {
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
          <Fragment>
            <Box inline color="label" mr={2}>
              {beakerCurrentVolume} / {beakerMaxVolume} units
            </Box>
            <Button
              icon="eject"
              content="Eject"
              onClick={() => act(ref, 'eject')} />
          </Fragment>
        )}>
        <BeakerContents
          beakerLoaded={isBeakerLoaded}
          beakerContents={beakerContents} />
      </Section>
    </Fragment>
  );
};
