import { useBackend, useLocalState } from '../backend';
import { Section, Stack, Input, Button, Table, LabeledList, Flex, Divider, NoticeBox } from '../components';
import { Window } from '../layouts';

const PacketInfo = (props, context) => {
  const { act, data } = useBackend(context);
  const { packet } = props;
  return (
    <Stack.Item>
      <Flex justify="space-between">
        <Flex.Item align="left">{packet.name}</Flex.Item>
        <Flex.Item align="right">
          <Button
            icon="trash"
            color="red"
            onClick={() => act('delete_packet', { ref: packet.ref })}
          />
        </Flex.Item>
      </Flex>
      <LabeledList>
        <LabeledList.Item label="Data Type">{packet.type}</LabeledList.Item>
        <LabeledList.Item label="Source">
          {packet.source + (packet.job ? ' (' + packet.job + ')' : '')}
        </LabeledList.Item>
        <LabeledList.Item label="Class">{packet.race}</LabeledList.Item>
        <LabeledList.Item label="Contents">{packet.message}</LabeledList.Item>
        <LabeledList.Item label="Language">{packet.language}</LabeledList.Item>
      </LabeledList>
      <Divider />
    </Stack.Item>
  );
};

const ServerScreen = (props, context) => {
  const { act, data } = useBackend(context);
  const { network, server } = data;
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section
          title="Server Information"
          buttons={
            <Button
              content="Main Menu"
              icon="home"
              onClick={() => act('return_home')}
            />
          }>
          <LabeledList>
            <LabeledList.Item label="Network">{network}</LabeledList.Item>
            <LabeledList.Item label="Server">{server.name}</LabeledList.Item>
            <LabeledList.Item label="Total Recorded Traffic">
              {server.traffic >= 1024
                ? server.traffic / 1024 + ' TB'
                : server.traffic + ' GB'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title="Stored Packets">
          <Stack vertical>
            {server.packets?.map((p) => (
              <PacketInfo key={p.ref} packet={p} />
            ))}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const MainScreen = (props, context) => {
  const { act, data } = useBackend(context);
  const { servers, network } = data;
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
            content="Scan"
            onClick={() => act('scan_network', { network_id: networkId })}
          />
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title="Detected Telecommunication Servers"
          buttons={
            <Button
              content="Clear Buffer"
              icon="trash"
              color="red"
              disabled={servers.length === 0}
              onClick={() => act('clear_buffer')}
            />
          }>
          <Table>
            <Table.Row header>
              <Table.Cell>Address</Table.Cell>
              <Table.Cell>Identification String</Table.Cell>
              <Table.Cell>Name</Table.Cell>
            </Table.Row>
            {servers?.map((s) => (
              <Table.Row key={s.ref}>
                <Table.Cell>{s.ref}</Table.Cell>
                <Table.Cell>{s.id}</Table.Cell>
                <Table.Cell>
                  <Button
                    content={s.name}
                    onClick={() => act('view_server', { server: s.ref })}
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

export const ServerMonitor = (props, context) => {
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
              (screen === 1 && <ServerScreen />)}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
