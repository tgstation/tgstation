import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const GulagTeleporterConsole = (props) => {
  const { act, data } = useBackend();
  const {
    teleporter,
    teleporter_lock,
    teleporter_state_open,
    teleporter_location,
    beacon,
    beacon_location,
    id,
    id_name,
    can_teleport,
    goal = 0,
    prisoner = {},
  } = data;
  return (
    <Window width={350} height={295}>
      <Window.Content>
        <Section
          title="Teleporter Console"
          buttons={
            <>
              <Button
                content={teleporter_state_open ? 'Open' : 'Closed'}
                disabled={teleporter_lock}
                selected={teleporter_state_open}
                onClick={() => act('toggle_open')}
              />
              <Button
                icon={teleporter_lock ? 'lock' : 'unlock'}
                content={teleporter_lock ? 'Locked' : 'Unlocked'}
                selected={teleporter_lock}
                disabled={teleporter_state_open}
                onClick={() => act('teleporter_lock')}
              />
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item
              label="Teleporter Unit"
              color={teleporter ? 'good' : 'bad'}
              buttons={
                !teleporter && (
                  <Button
                    content="Reconnect"
                    onClick={() => act('scan_teleporter')}
                  />
                )
              }
            >
              {teleporter ? teleporter_location : 'Not Connected'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Receiver Beacon"
              color={beacon ? 'good' : 'bad'}
              buttons={
                !beacon && (
                  <Button
                    content="Reconnect"
                    onClick={() => act('scan_beacon')}
                  />
                )
              }
            >
              {beacon ? beacon_location : 'Not Connected'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Prisoner Details">
          <LabeledList>
            <LabeledList.Item label="Prisoner ID">
              <Button
                fluid
                content={id ? id_name : 'No ID'}
                onClick={() => act('handle_id')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Point Goal">
              <NumberInput
                value={goal}
                step={1}
                width="48px"
                minValue={1}
                maxValue={1000}
                onChange={(value) => act('set_goal', { value })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Occupant">
              {prisoner.name || 'No Occupant'}
            </LabeledList.Item>
            <LabeledList.Item label="Criminal Status">
              {prisoner.crimstat || 'No Status'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Button
          fluid
          content="Process Prisoner"
          disabled={!can_teleport}
          textAlign="center"
          color="bad"
          onClick={() => act('teleport')}
        />
      </Window.Content>
    </Window>
  );
};
