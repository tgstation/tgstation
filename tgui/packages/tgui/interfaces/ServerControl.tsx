import { useMemo } from 'react';
import {
  Button,
  Collapsible,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

type Data = {
  server_connected: BooleanLike;
  servers: ServerData[];
  consoles: ConsoleData[];
  logs: LogData[];
};

type ServerData = {
  server_name: string;
  server_details: string;
  server_disabled: string;
  server_ref: string;
};

type ConsoleData = {
  console_name: string;
  console_location: string;
  console_locked: string;
  console_ref: string;
};

type LogData = {
  node_name: string;
  node_cost: string;
  node_researcher: string;
  node_researcher_location: string;
  node_researched_timestamp: string;
};

export const ServersView = (props) => {
  const { act, data } = useBackend<Data>();
  const { server_connected, servers } = data;
  return !servers ? (
    <NoticeBox mt={2} info>
      No servers found.
    </NoticeBox>
  ) : (
    <Section>
      <Table textAlign="center">
        <Table.Row header>
          <Table.Cell>Research Servers</Table.Cell>
        </Table.Row>
        {servers.map((server) => (
          <>
            <Table.Row header key={server.server_ref} className="candystripe" />
            <Table.Cell> {server.server_name}</Table.Cell>
            <Button
              mt={1}
              tooltip={server.server_details}
              color={server.server_disabled ? 'bad' : 'good'}
              content={server.server_disabled ? 'Offline' : 'Online'}
              fluid
              textAlign="center"
              onClick={() =>
                act('lockdown_server', {
                  selected_server: server.server_ref,
                })
              }
            />
          </>
        ))}
      </Table>
    </Section>
  );
};

export const ConsolesView = (props) => {
  const { act, data } = useBackend<Data>();
  const { consoles } = data;
  return !consoles ? (
    <NoticeBox mt={2} info>
      No consoles found.
    </NoticeBox>
  ) : (
    <Section align="right">
      <Table textAlign="center">
        <Table.Row header>
          <Table.Cell>Research Consoles</Table.Cell>
        </Table.Row>
        {consoles.map((console) => (
          <>
            <Table.Row
              header
              key={console.console_ref}
              className="candystripe"
            />
            <Table.Cell>
              {' '}
              {console.console_name} - Location: {console.console_location}{' '}
            </Table.Cell>
            <Button
              mt={1}
              color={console.console_locked ? 'bad' : 'good'}
              content={console.console_locked ? 'LOCKED' : 'UNLOCKED'}
              fluid
              textAlign="center"
              onClick={() =>
                act('lock_console', {
                  selected_console: console.console_ref,
                })
              }
            />
          </>
        ))}
      </Table>
    </Section>
  );
};

const HistoryEntry = (server_log: LogData) => {
  const {
    node_name,
    node_cost,
    node_researcher,
    node_researcher_location,
    node_researched_timestamp,
  } = server_log;

  return (
    <Collapsible title={node_name}>
      <Stack.Item>
        <Section
          align="center"
          textAlign="center"
          title={node_name}
          className="ServerControl__History_Entry"
        >
          <Stack vertical inline justify="space-between">
            <Stack justify="space-between" className="EntryHeader">
              <Stack.Item>RESEARCHER</Stack.Item>
              <Stack.Item>COST</Stack.Item>
            </Stack>
            <Stack justify="space-between">
              <Stack.Item>{node_researcher}</Stack.Item>
              <Stack.Item>{node_cost} points</Stack.Item>
            </Stack>
          </Stack>
          <Stack
            vertical
            align="center"
            textAlign="center"
            className="EntryHeader"
          >
            <Stack.Item>CONSOLE LOCATION</Stack.Item>
          </Stack>
          <Stack vertical align="center" textAlign="center">
            <Stack.Item>{node_researcher_location}</Stack.Item>
          </Stack>
          <Stack vertical align="center" textAlign="center">
            <Stack.Item shrink className="EntryTimestamp">
              {node_researched_timestamp}
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Collapsible>
  );
};

const ResearchHistoryView = (props) => {
  const { data } = useBackend<Data>();
  const { logs } = data;

  const historyEntries = useMemo(() => {
    return logs.map((server_log, index) => (
      <HistoryEntry key={index} {...server_log} />
    ));
  }, [logs]);

  return (
    <Section
      title="Research History"
      align="center"
      textAlign="center"
      className="SeverControl__History"
    >
      {!logs.length ? (
        <NoticeBox mt={2} info>
          No research history found.
        </NoticeBox>
      ) : (
        <Stack vertical>{historyEntries}</Stack>
      )}
    </Section>
  );
};

export const ServerControl = (props) => {
  const { act, data } = useBackend<Data>();
  const { server_connected, servers, consoles, logs } = data; // Assuming 'servers', 'consoles', and 'logs' are used by the child components
  const [currentTab, setTab] = useSharedState('tab', 1);
  const TitlesAndTabs = [
    { title: 'Active Servers', component: ServersView },
    { title: 'Active Consoles', component: ConsolesView },
    { title: 'Research History', component: ResearchHistoryView },
  ];

  const ServerControlTabs = (componentProps) => {
    return (
      <Tabs
        className="ServerControl__Tabs"
        onSelect={(tab) => setTab(tab)}
        {...componentProps}
      >
        {TitlesAndTabs.map((tab, index) => (
          <Tabs.Tab
            key={index}
            selected={currentTab === index + 1}
            onClick={() => setTab(index + 1)}
          >
            {tab.title}
          </Tabs.Tab>
        ))}
      </Tabs>
    );
  };
  return !server_connected ? (
    <Window width={400} height={500} theme="hackerman">
      <Window.Content scrollable className="ServerControl__Content">
        <NoticeBox textAlign="center" danger>
          Not connected to a Server. Please sync one using a multitool.
        </NoticeBox>
      </Window.Content>
    </Window>
  ) : (
    <Window width={400} height={500} theme="hackerman">
      <Window.Content scrollable className="ServerControl__Content">
        <ServerControlTabs />
        {TitlesAndTabs.map((tab, index) =>
          currentTab === index + 1 ? <tab.component key={index} /> : null,
        )}
      </Window.Content>
    </Window>
  );
};
