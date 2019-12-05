import { map } from 'common/collections';
import { toFixed } from 'common/math';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, Section } from '../components';

export const AtmosControlConsole = props => {
  const { act, data } = useBackend(props);
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
                {map((gasPercent, gasId) => {
                  return (
                    <LabeledList.Item label={gasId}>
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
              onClick={() => act('reconnect')} />
          )}>
          <LabeledList>
            <LabeledList.Item label="Input Injector">
              <Button
                icon={data.inputting ? 'power-off' : 'times'}
                content={data.inputting ? 'Injecting' : 'Off'}
                selected={data.inputting}
                onClick={() => act('input')} />
            </LabeledList.Item>
            <LabeledList.Item label="Input Rate">
              <NumberInput
                value={data.inputRate}
                unit="L/s"
                width="63px"
                minValue={0}
                maxValue={200}
                // This takes an exceptionally long time to update
                // due to being an async signal
                suppressFlicker={2000}
                onChange={(e, value) => act('rate', {
                  rate: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Output Regulator">
              <Button
                icon={data.outputting ? 'power-off' : 'times'}
                content={data.outputting ? 'Open' : 'Closed'}
                selected={data.outputting}
                onClick={() => act('output')} />
            </LabeledList.Item>
            <LabeledList.Item label="Output Pressure">
              <NumberInput
                value={parseFloat(data.outputPressure)}
                unit="kPa"
                width="75px"
                minValue={0}
                maxValue={4500}
                step={10}
                // This takes an exceptionally long time to update
                // due to being an async signal
                suppressFlicker={2000}
                onChange={(e, value) => act('pressure', {
                  pressure: value,
                })} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      )}
    </Fragment>
  );
};
