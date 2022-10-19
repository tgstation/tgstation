import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const Teleporter = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    calibrated,
    calibrating,
    power_station,
    regime_set,
    teleporter_hub,
    target,
  } = data;
  return (
    <Window width={360} height={130}>
      <Window.Content>
        <Section>
          {(!power_station && (
            <Box color="bad" textAlign="center">
              No power station linked.
            </Box>
          )) ||
            (!teleporter_hub && (
              <Box color="bad" textAlign="center">
                No hub linked.
              </Box>
            )) || (
              <LabeledList>
                <LabeledList.Item label="Regime">
                  <Button
                    content={regime_set}
                    onClick={() => act('regimeset')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Target">
                  <Button
                    icon="edit"
                    content={target}
                    onClick={() => act('settarget')}
                  />
                </LabeledList.Item>
                <LabeledList.Item
                  label="Calibration"
                  buttons={
                    <Button
                      icon="tools"
                      content="Calibrate"
                      onClick={() => act('calibrate')}
                    />
                  }>
                  {(calibrating && <Box color="average">In Progress</Box>) ||
                    (calibrated && <Box color="good">Optimal</Box>) || (
                      <Box color="bad">Sub-Optimal</Box>
                    )}
                </LabeledList.Item>
              </LabeledList>
            )}
        </Section>
      </Window.Content>
    </Window>
  );
};
