import { useBackend } from '../backend';
import { Fragment } from 'inferno';
import { Box, Section, LabeledList, Button, AnimatedNumber, NumberInput } from '../components';
import { getGasLabel } from '../constants';

export const PortableBasicInfo = props => {
  const { act, data } = useBackend(props);

  const {
    connected,
    holding,
    on,
    pressure,
  } = data;

  return (
    <Fragment>
      <Section
        title="Status"
        buttons={(
          <Button
            icon={on ? 'power-off' : 'times'}
            content={on ? 'On' : 'Off'}
            selected={on}
            onClick={() => act('power')} />
        )}>
        <LabeledList>
          <LabeledList.Item label="Pressure">
            <AnimatedNumber value={pressure} />
            {' kPa'}
          </LabeledList.Item>
          <LabeledList.Item
            label="Port"
            color={connected ? 'good' : 'average'}>
            {connected ? 'Connected' : 'Not Connected'}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Holding Tank"
        minHeight="82px"
        buttons={(
          <Button
            icon="eject"
            content="Eject"
            disabled={!holding}
            onClick={() => act('eject')} />
        )}>
        {holding ? (
          <LabeledList>
            <LabeledList.Item label="Label">
              {holding.name}
            </LabeledList.Item>
            <LabeledList.Item label="Pressure">
              <AnimatedNumber
                value={holding.pressure} />
              {' kPa'}
            </LabeledList.Item>
          </LabeledList>
        ) : (
          <Box color="average">
            No holding tank
          </Box>
        )}
      </Section>
    </Fragment>
  );
};

export const PortablePump = props => {
  const { act, data } = useBackend(props);

  const {
    direction,
    holding,
    target_pressure,
    default_pressure,
    min_pressure,
    max_pressure,
  } = data;

  return (
    <Fragment>
      <PortableBasicInfo state={props.state} />
      <Section
        title="Pump"
        buttons={(
          <Button
            icon={direction ? 'sign-in-alt' : 'sign-out-alt'}
            content={direction ? 'In' : 'Out'}
            selected={direction}
            onClick={() => act('direction')} />
        )}>
        <LabeledList>
          <LabeledList.Item label="Output">
            <NumberInput
              value={target_pressure}
              unit="kPa"
              width="75px"
              minValue={min_pressure}
              maxValue={max_pressure}
              step={10}
              onChange={(e, value) => act('pressure', {
                pressure: value,
              })} />
          </LabeledList.Item>
          <LabeledList.Item label="Presets">
            <Button
              icon="minus"
              disabled={target_pressure === min_pressure}
              onClick={() => act('pressure', {
                pressure: 'min',
              })} />
            <Button
              icon="sync"
              disabled={target_pressure === default_pressure}
              onClick={() => act('pressure', {
                pressure: 'reset',
              })} />
            <Button
              icon="plus"
              disabled={target_pressure === max_pressure}
              onClick={() => act('pressure', {
                pressure: 'max',
              })} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  );
};

export const PortableScrubber = props => {
  const { act, data } = useBackend(props);

  const filter_types = data.filter_types || [];

  return (
    <Fragment>
      <PortableBasicInfo state={props.state} />
      <Section title="Filters">
        {filter_types.map(filter => (
          <Button
            key={filter.id}
            icon={filter.enabled ? 'check-square-o' : 'square-o'}
            content={getGasLabel(filter.gas_id, filter.gas_name)}
            selected={filter.enabled}
            onClick={() => act('toggle_filter', {
              val: filter.gas_id,
            })} />
        ))}
      </Section>
    </Fragment>
  );
};
