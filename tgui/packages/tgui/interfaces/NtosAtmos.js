import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { LabeledList, ProgressBar, Section } from '../components';
import { getGasColor, getGasLabel } from '../constants';
import { NtosWindow } from '../layouts';

export const NtosAtmos = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    AirTemp,
    AirPressure,
  } = data;
  const gases = flow([
    filter(gas => gas.percentage >= 0.01),
    sortBy(gas => -gas.percentage),
  ])(data.AirData || []);
  const gasMaxPercentage = Math.max(1, ...gases.map(gas => gas.percentage));
  return (
    <NtosWindow resizable>
      <NtosWindow.Content scrollable>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Temperature">
              {AirTemp}°C
            </LabeledList.Item>
            <LabeledList.Item label="Pressure">
              {AirPressure} kPa
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section>
          <LabeledList>
            {gases.map(gas => (
              <LabeledList.Item
                key={gas.name}
                label={getGasLabel(gas.name)}>
                <ProgressBar
                  color={getGasColor(gas.name)}
                  value={gas.percentage}
                  minValue={0}
                  maxValue={gasMaxPercentage}>
                  {toFixed(gas.percentage, 2) + '%'}
                </ProgressBar>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
