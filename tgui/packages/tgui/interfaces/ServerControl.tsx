import { Button, NoticeBox, Section, Table, Tabs } from 'tgui-core/components';
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

const ResearchHistoryView = (props) => {
  const { act, data } = useBackend<Data>();
  const { logs } = data;

  const HistoryEntry = (server_log: LogData) => {
    const {
      node_name,
      node_cost,
      node_researcher,
      node_researcher_location,
      node_researched_timestamp,
    } = server_log;
    return (
      <Section className="ResearchHistoryEntry" title={node_name}>
        Testing Text
      </Section>
    );
  };

  return (
    <Section title="Research History" align="center" textAlign="center">
      {!logs.length ? (
        <NoticeBox mt={2} info>
          No research history found.
        </NoticeBox>
      ) : (
        logs.map((server_log, index = 1) => (
          <HistoryEntry key={index++} {...server_log} />
        ))
      )}
    </Section>
  );
};

export const ServerControl = (props) => {
  const { act, data } = useBackend<Data>();
  const { server_connected, servers, consoles, logs } = data;
  const [currentTab, setTab] = useSharedState('tab', 1);
  if (!server_connected) {
    return (
      <Window width={575} height={450}>
        <Window.Content>
          <NoticeBox textAlign="center" danger>
            Not connected to a Server. Please sync one using a multitool.
          </NoticeBox>
        </Window.Content>
      </Window>
    );
  }
  return (
    <Window width={575} height={500} theme="ntos_terminal_sci_themed">
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            key="servers"
            selected={currentTab === 1}
            onClick={() => setTab(1)}
          >
            Active Servers
          </Tabs.Tab>
          <Tabs.Tab
            key="consoles"
            selected={currentTab === 2}
            onClick={() => setTab(2)}
          >
            Active Consoles
          </Tabs.Tab>
          <Tabs.Tab
            key="research_history"
            selected={currentTab === 3}
            onClick={() => setTab(3)}
          >
            Research History
          </Tabs.Tab>
        </Tabs>
        {currentTab === 1 && <ServersView />}
        {currentTab === 2 && <ConsolesView />}
        {currentTab === 3 && <ResearchHistoryView />}
      </Window.Content>
    </Window>
  );
};
