import { useBackend } from '../backend';
import { Button, LabeledList, Section, Box, Modal, ProgressBar, NumberInput } from '../components';
import { Window } from '../layouts';

export const TurbineComputer = (props, context) => {
  const { act, data } = useBackend(context);
  const parts_not_connected = !data.parts_linked && (
    <Modal>
      <Box
        style={{ margin: 'auto' }}
        width="200px"
        textAlign="center"
        minHeight="39px">
        {
          'Parts not connected, use a multitool on the core rotor before trying again'
        }
      </Box>
    </Modal>
  );
  const parts_not_ready = data.parts_linked && !data.parts_ready && (
    <Modal>
      <Box
        style={{ margin: 'auto' }}
        width="200px"
        textAlign="center"
        minHeight="39px">
        {
          'Some parts have open maintenance hatchet, please close them before starting'
        }
      </Box>
    </Modal>
  );
  return (
    <Window width={310} height={240}>
      <Window.Content>
        <Section
          title="Status"
          buttons={
            <Button
              icon={data.active ? 'power-off' : 'times'}
              content={data.active ? 'Online' : 'Offline'}
              selected={data.active}
              disabled={!data.can_turn_off || !data.parts_linked}
              onClick={() => act('toggle_power')}
            />
          }>
          {parts_not_connected}
          {parts_not_ready}
          <LabeledList>
            <LabeledList.Item label="Intake Regulator">
              <NumberInput
                animated
                value={parseFloat(data.regulator * 100)}
                unit="%"
                minValue={1}
                maxValue={100}
                onDrag={(e, value) =>
                  act('regulate', {
                    regulate: value * 0.01,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Turbine Integrity">
              <ProgressBar
                value={data.integrity}
                minValue={0}
                maxValue={100}
                ranges={{
                  good: [60, 100],
                  average: [40, 59],
                  bad: [0, 39],
                }}>
                {data.integrity + ' %'}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Turbine Speed">
              {data.rpm} RPM
            </LabeledList.Item>
            <LabeledList.Item label="Max Turbine Speed">
              {data.max_rpm} RPM
            </LabeledList.Item>
            <LabeledList.Item label="Input Temperature">
              {data.temp} K
            </LabeledList.Item>
            <LabeledList.Item label="Max Temperature">
              {data.max_temperature} K
            </LabeledList.Item>
            <LabeledList.Item label="Generated Power">
              {data.power * 4 * 0.001} kW
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
