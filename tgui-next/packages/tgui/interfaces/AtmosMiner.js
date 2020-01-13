import { toFixed } from 'common/math';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, NumberInput, Section } from '../components';
import { getGasLabel } from '../constants';

export const AtmosMiner = props => {
  const { act, data } = useBackend(props);
  const mineTypes = data.mine_types || [];
  return (
    <Fragment>
      <Section title="Status">
        <LabeledList>
          <LabeledList.Item label="Pressure">
            <AnimatedNumber
              value={data.pressure}
              format={value => toFixed(value, 2)} />
            {' kPa'}
          </LabeledList.Item>
          <LabeledList.Item label="Moles">
            <AnimatedNumber
              value={data.moles}
              format={value => toFixed(value, 2)} />
            {' mol'}
          </LabeledList.Item>
          <LabeledList.Item label="Operating Status:">
            <Box
              color={data.broken ? 'red' : 'green'}
              fontSize="10px">
              {data.state}
            </Box>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Controls"
        buttons={(
          <Button
            icon={data.on ? 'power-off' : 'times'}
            content={data.on ? 'On' : 'Off'}
            selected={data.on}
            onClick={() => act('power')} />
        )}>
        <LabeledList.Item label="Generation Rate">
          <NumberInput
            animated
            value={parseFloat(data.rate)}
            width="63px"
            unit="mol/s"
            minValue={0}
            maxValue={data.max_rate}
            onDrag={(e, value) => act('rate', {
              rate: value,
            })} />
          <Button
            ml={1}
            icon="plus"
            content="Max"
            disabled={data.rate === data.max_rate}
            onClick={() => act('rate', {
              rate: 'max',
            })} />
        </LabeledList.Item>
        <LabeledList.Item label="Gas Type">
          {mineTypes.map(mine => (
            <Button
              key={mine.id}
              selected={mine.selected}
              content={getGasLabel(mine.id, mine.name)}
              onClick={() => act('mine', {
                mode: mine.id,
              })} />
          ))}
        </LabeledList.Item>
      </Section>
    </Fragment>
  );
};