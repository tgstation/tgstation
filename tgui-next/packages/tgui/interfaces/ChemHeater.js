import { Fragment } from 'inferno';
import { AnimatedNumber, Button, LabeledList, Section, Box } from '../components';
import { act } from '../byond';
import { toFixed, round } from 'common/math';
import { NumberInput } from '../components/NumberInput';

export const ChemHeater = props => {
  const { state, dispatch } = props;
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
        {!isBeakerLoaded && (
          <Box color="label" content="No beaker loaded." />
        ) || beakerContents.length === 0 && (
          <Box color="label" content="Beaker is empty." />
        )}
        {beakerContents.map(chemical => (
          <Box key={chemical.name} color="label">
            {chemical.volume} units of {chemical.name}
          </Box>
        ))}
      </Section>
    </Fragment>
  );
};
