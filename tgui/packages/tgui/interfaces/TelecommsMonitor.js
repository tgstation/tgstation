import { useBackend, useLocalState } from '../backend';
import { Section, Stack, Input, Button, Table, LabeledList, NoticeBox } from '../components';
import { Window } from '../layouts';

const MachineScreen = (props, context) => {
  const { act, data } = useBackend(context);
  const { network, machine } = data;
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
            {machine.machinery?.map((m) => (
              <Table.Row key={m.ref}>
                <Table.Cell>{m.ref}</Table.Cell>
                <Table.Cell>{m.id}</Table.Cell>
                <Table.Cell>
                  <Button
                    content={m.name}
                    onClick={() => act('view_machine', { id: m.id })}
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

const MainScreen = (props, context) => {
  const { act, data } = useBackend(context);
  const { machinery, network } = data;
  const [networkId, setNetworkId] = useLocalState(
    context,
    'networkId',
    network
  );

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
            {machinery?.map((m) => (
              <Table.Row key={m.ref}>
                <Table.Cell>{m.ref}</Table.Cell>
                <Table.Cell>{m.id}</Table.Cell>
                <Table.Cell>
                  <Button
                    content={m.name}
                    onClick={() => act('view_machine', { id: m.id })}
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

export const TelecommsMonitor = (props, context) => {
  const { act, data } = useBackend(context);
  const { screen, error } = data;
  return (
    <Window width={575} height={400}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            {error !== '' && <NoticeBox>{error}</NoticeBox>}
          </Stack.Item>
          <Stack.Item grow>
            {(screen === 0 && <MainScreen />) ||
              (screen === 1 && <MachineScreen />)}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
