import { Fragment } from 'inferno';
import { act } from '../byond';
import { Box, Button, Section, LabeledList } from '../components';

export const ChemAcclimator = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Fragment>
      <Section title="Acclimator">
        <LabeledList>
          <LabeledList.Item label="Current Temperature">
            {data.chem_temp}
          </LabeledList.Item>
          <LabeledList.Item label="Target Temperature">
            <Button
              icon="thermometer-half"
              content={data.target_temperature}
              onClick={() => act(ref, 'set_target_temperature')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Acceptable Temp. Difference">
            <Button
              icon="thermometer-quarter"
              content={data.allowed_temperature_difference}
              onClick={() => act(ref, 'set_allowed_temperature_difference')}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Status">
        <LabeledList>
          <LabeledList.Item label="Current Operation">
            {data.acclimate_state}
          </LabeledList.Item>
          <LabeledList.Item label="Power">
            <Button
              icon="power-off"
              selected={data.enabled}
              onClick={() => act(ref, 'toggle_power')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Change Volume">
            <Button
              icon="flask"
              content={data.max_volume}
              onClick={() => act(ref, 'change_volume')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Current State">
            {data.emptying ? 'Emptying' : 'Filling'}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  );
};
