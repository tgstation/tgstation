import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';

export const Teleporter = props => {
  const { act, data } = useBackend(props);
  const {
    calibrated,
    calibrating,
    power_station,
    regime_set,
    teleporter_hub,
    target,
  } = data;
  return (
    <Section>
      {!power_station && (
        <Box color="bad" textAlign="center">
          No power station linked.
        </Box>
      ) || (!teleporter_hub && (
        <Box color="bad" textAlign="center">
          No hub linked.
        </Box>
      )) || (
        <LabeledList>
          <LabeledList.Item label="Current Regime"
            buttons={(
              <Button
                icon="tools"
                content="Change Regime"
                onClick={() => act('regimeset')} />
            )}>
            {regime_set}
          </LabeledList.Item>
          <LabeledList.Item label="Current Target"
            buttons={(
              <Button
                icon="tools"
                content={"Set Target"}
                onClick={() => act('settarget')} />
            )}>
            {target}
          </LabeledList.Item>
          <LabeledList.Item label="Calibration"
            buttons={(
              <Button
                icon="tools"
                content={"Calibrate Hub"}
                onClick={() => act('calibrate')} />
            )}>
            {calibrating && (
              <Box color="average">
                In Progress
              </Box>
            ) || (calibrated && (
              <Box color="good">
                Optimal
              </Box>
            ) || (
              <Box color="bad">
                Sub-Optimal
              </Box>
            ))}
          </LabeledList.Item>
        </LabeledList>
      )}
    </Section>
  );
};
