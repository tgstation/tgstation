import { Fragment } from 'inferno';
import { act } from '../byond';
import { Box, Button, Section } from '../components';

export const Acclimator = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Fragment>
      <Section title="Acclimator">
        Current Temperature - {data.chem_temp}
        <Box mt={1} />
        Target Temperature -
        <Button
          icon="thermometer-half"
          content={data.target_temperature}
          onClick={() => act(ref, 'set_target_temperature')} />
        <Box mt={1} />
        Acceptable Temperature Difference -
        <Button
          icon="thermometer-quarter"
          content={data.allowed_temperature_difference}
          onClick={() => act(ref, 'set_allowed_temperature_difference')} />
      </Section>
      <Section title="Status">
        Current Operation - {data.acclimate_state}
        <Box mt={1} />
        <Button
          icon="power-off"
          content={data.enabled ? 'On' : 'Off'}
          selected={data.enabled}
          onClick={() => act(ref, 'toggle_power')} />
        <Box mt={1} />
        Change Volume
        <Button
          icon="flask"
          content={data.max_volume}
          onClick={() => act(ref, 'change_volume')} />
        <Box mt={1} />
        Current State - {data.emptying ? "Emptying" : "Filling"}
      </Section>
    </Fragment>
  );
};
