import { map } from 'common/fp';
import { round, toFixed } from 'common/math';
import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, LabeledList, Section } from '../components';
import { NumberInput } from '../components/NumberInput';

export const AtmosControlConsole = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const sensors = data.sensors || [];
  return (
    <Fragment>
      <Section
        title={!!data.tank && sensors[0].long_name}>
        {sensors.map(sensor => {
          const gases = sensor.gases || {};
          return (
            <Section
              key={sensor.id_tag}
              title={!data.tank && sensor.long_name}
              level={2}>
              <LabeledList>
                <LabeledList.Item label="Pressure">
                  {toFixed(sensor.pressure, 2) + ' kPa'}
                </LabeledList.Item>
                {!!sensor.temperature && (
                  <LabeledList.Item label="Temperature">
                    {toFixed(sensor.temperature, 2) + ' K'}
                  </LabeledList.Item>
                )}
                {map((gasPercent, gasID) => {
                  return (
                    <LabeledList.Item label={gasID}>
                      {toFixed(gasPercent, 2) + '%'}
                    </LabeledList.Item>
                  );
                })(gases)}
              </LabeledList>
            </Section>
          );
        })}
      </Section>
      {data.tank && (
        <Section
          title="Controls"
          buttons={(
            <Button
              icon="undo"
              content="Reconnect"
              onClick={() => act(ref, 'reconnect')} />
          )}>
          <LabeledList>
            <LabeledList.Item label="Input Injector">
              <Button
                icon={data.inputting ? 'power-off' : 'times'}
                content={data.inputting ? 'Injecting' : 'Off'}
                selected={data.inputting}
                onClick={() => act(ref, 'input')} />
            </LabeledList.Item>
            <LabeledList.Item label="Input Rate">
              <NumberInput
                value={data.inputRate}
                unit="L/s"
                width="62px"
                minValue={0}
                maxValue={200}
                onChange={(e, value) => act(ref, 'rate', {rate: value})}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Output Regulator">
              <Button
                icon={data.outputting ? 'power-off' : 'times'}
                content={data.outputting ? 'Open' : 'Closed'}
                selected={data.outputting}
                onClick={() => act(ref, 'output')} />
            </LabeledList.Item>
            <LabeledList.Item label="Output Pressure">
              <NumberInput
                value={parseFloat(data.outputPressure)}
                unit="kPa"
                width="73px"
                minValue={0}
                maxValue={4500}
                step={10}
                onChange={(e, value) => act(ref, 'pressure', {pressure: value})}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      )}
    </Fragment>
  );
};
