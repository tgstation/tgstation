import { useBackend, useLocalState } from '../backend';
import { Section, Stack, Input, Button, Table, LabeledList, NoticeBox } from '../components';
import { Window } from '../layouts';

enum Screen {
  Main,
  Machine,
}

type Data = {
  screen: Screen;
  network: string;
  error_message: string;
  machinery: Machine[];
  machine: Machine;
};

type Machine = {
  ref: string;
  id: string;
  name: string;
  linked_machinery: LinkedMachinery[];
};

type LinkedMachinery = {
  ref: string;
  id: string;
  name: string;
};

const MachineScreen = (props) => {
  const { act, data } = useBackend<Data>();
  const { network, machine } = data;
  const { linked_machinery = [] } = machine;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section
          title="Entity Information"
          buttons={
            <Button
              content="Main Menu"
              icon="home"
              onClick={() => act('return_home')}
            />
          }>
          <LabeledList>
            <LabeledList.Item label="Network">{network}</LabeledList.Item>
            <LabeledList.Item label="Network Entity">
              {machine.name}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title="Linked Entities">
          <Table>
            <Table.Row header>
              <Table.Cell>Address</Table.Cell>
              <Table.Cell>Name</Table.Cell>
              <Table.Cell>Machine</Table.Cell>
            </Table.Row>
            {linked_machinery?.map((lm) => (
              <Table.Row key={lm.ref} className="candystripe">
                <Table.Cell>{lm.ref}</Table.Cell>
                <Table.Cell>{lm.id}</Table.Cell>
                <Table.Cell>
                  <Button
                    content={lm.name}
                    onClick={() => act('view_machine', { id: lm.id })}
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const MainScreen = (props) => {
  const { act, data } = useBackend<Data>();
  const { machinery = [], network } = data;
  const [networkId, setNetworkId] = useLocalState('networkId', network);

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section>
          <Input
            value={networkId}
            onInput={(e, value) => setNetworkId(value)}
            placeholder="Network ID"
          />
          <Button
            content="Probe Network"
            onClick={() => act('probe_network', { network_id: networkId })}
          />
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title="Detected Network Entities"
          buttons={
            <Button
              content="Flush Buffer"
              icon="trash"
              color="red"
              disabled={machinery.length === 0}
              onClick={() => act('flush_buffer')}
            />
          }>
          <Table>
            <Table.Row header>
              <Table.Cell>Address</Table.Cell>
              <Table.Cell>Name</Table.Cell>
              <Table.Cell>Machine</Table.Cell>
            </Table.Row>
            {machinery?.map((machine) => (
              <Table.Row key={machine.ref} className="candystripe">
                <Table.Cell>{machine.ref}</Table.Cell>
                <Table.Cell>{machine.id}</Table.Cell>
                <Table.Cell>
                  <Button
                    content={machine.name}
                    onClick={() => act('view_machine', { id: machine.id })}
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const TelecommsMonitor = (props) => {
  const { act, data } = useBackend<Data>();
  const { screen, error_message } = data;
  return (
    <Window width={575} height={400}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            {!!error_message && <NoticeBox>{error_message}</NoticeBox>}
          </Stack.Item>
          <Stack.Item grow>
            {(screen === Screen.Main && <MainScreen />) ||
              (screen === Screen.Machine && <MachineScreen />)}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
