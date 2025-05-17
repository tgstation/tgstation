import {
  Button,
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
      <Stack.Item>
        <Section
          className="HistoryTab__HistoryEntry"
          align="center"
          textAlign="center"
          title={node_name}
        />
      </Stack.Item>
    );
  };

  return (
    <Section
      title="Research History"
      align="center"
      textAlign="center"
      className="ServerControl__HistoryTab"
    >
      {!logs.length ? (
        <NoticeBox mt={2} info>
          No research history found.
        </NoticeBox>
      ) : (
        <Stack vertical>
          {logs.map((server_log, index) => (
            <HistoryEntry key={index} {...server_log} />
          ))}
        </Stack>
      )}
    </Section>
  );
};

export const ServerControl = (props) => {
  const { act, data } = useBackend<Data>();
  const { server_connected, servers, consoles, logs } = data; // Assuming 'servers', 'consoles', and 'logs' are used by the child components
  const [currentTab, setTab] = useSharedState('tab', 1);
  const TitlesAndTabs = [['Active Servers', ], ['Active Consoles', ], ['Research History', ]];

  // Define the helper component with PascalCase and corrected 'className'
  const ServerControlWindow = (componentProps) => {
    // Renamed props to avoid conflict with outer props
    return (
      <Window width={575} height={500} theme="hackerman">
        <Window.Content
          className="ServerControl__"
          scrollable
          {...componentProps}
        />
      </Window>
    );
    const ServerControlTabs = (componentProps) => {
      return (
        <Tabs
          className="ServerControl__Tabs"
          selected={currentTab}
          onSelect={(tab) => setTab(tab)}
          {...componentProps}
        />
      );
    };
    return (
      <ServerControlWindow>
        {!server_connected ? (
          <NoticeBox textAlign="center" danger>
            Not connected to a Server. Please sync one using a multitool.
          </NoticeBox>
        ) : (
          <Tabs />
        )}
      </ServerControlWindow>
    );
  };
};
