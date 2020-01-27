import { toFixed } from 'common/math';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, LabeledList, NumberInput, Section } from '../components';
import { getGasLabel, getGasColor } from '../constants';

export const AtmosVentCap = props => {
  const { act, data } = useBackend(props);
  const mineTypes = data.mine_types || [];
  return (
    <Fragment>
      <Section title="Status">
        <LabeledList>
          <LabeledList.Item label="Gas Type">
            <Box
              color={getGasColor(gas)}
              fontSize="10px">
              {data.gas}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Pressure">
            <ProgressBar
              color={data.pressurecolor}
              value={data.pressure}
              minValue={0}
              maxValue={data.max_pressure}>
              {toFixed(gas.amount, 2) + '%'}
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item label="Volumetric Rate">
            <AnimatedNumber
              value={data.moles}
              format={value => toFixed(value, 2)} />
            {' mol'}
          </LabeledList.Item>
          <LabeledList.Item label="Operating Status">
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
        <LabeledList.Item label="Pressure Limit">
          <NumberInput
            animated
            value={parseFloat(data.kpa_limit)}
            width="63px"
            unit="kpa"
            minValue={0}
            maxValue={data.max_kpa}
            onDrag={(e, value) => act('limit', {
              rate: value,
            })} />
          <Button
            ml={1}
            icon="plus"
            content="Max"
            disabled={data.kpa_limit === data.max_kpa}
            onClick={() => act('limit', {
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