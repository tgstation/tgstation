import {
  Box,
  Button,
  Divider,
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

  return (
    <Section
      title={
        <span
          style={{
            fontSize: '1.9em',
            fontWeight: 'bolder',
            color: 'var(--color-sedate-grey)',
            position: 'relative',
            left: '2.5em',
            fontFamily: 'var(--font-ternary)',
          }}
        >
          RESEARCH HISTORY
        </span>
      }
      fitted
      backgroundColor="transparent"
    >
      {!logs.length ? (
        <NoticeBox mt={2} info>
          No history found.
        </NoticeBox>
      ) : (
        <Stack vertical color="transparent" backgroundColor="transparent">
          {logs.map((server_log, index = 1) => (
            <Stack.Item
              key={index++}
              align="center"
              textAlign="center"
              width="100%"
            >
              <Divider />
              <Box as="span" align="center" fontSize="1.35em" nowrap>
                <Button
                  style={{
                    textShadow: '5px 5px 35px black',
                    color: 'var(--color-sedate-grey',
                    fontFamily: 'var(--font-secondary)',
                    outline: '2px solid black',
                    outlineStyle: 'groove',
                    outlineOffset: '-5px',
                  }}
                >
                  {server_log.node_name}
                </Button>
              </Box>
              <Box width="85%" position="relative" height="1.2em">
                <Box
                  as="span"
                  position="absolute"
                  left={2}
                  fontSize="1.2em"
                  style={{
                    fontFamily: 'var(--font-secondary)',
                    textShadow: '0px 0px 10px black',
                    textDecoration: 'underline',
                  }}
                >
                  Cost
                </Box>
                <Box
                  as="span"
                  position="absolute"
                  right={-2}
                  fontSize="1.2em"
                  style={{
                    fontFamily: 'var(--font-secondary)',
                    textShadow: '0px 0px 10px black',
                    textDecoration: 'underline',
                  }}
                >
                  Researcher
                </Box>
              </Box>
              <Box width="100%" position="relative" height="1.2em">
                <Box
                  as="span"
                  position="absolute"
                  left={2}
                  fontSize="1.2em"
                  style={{
                    fontFamily: 'var(--font-ternary)',
                  }}
                >
                  {server_log.node_cost} points
                </Box>
                <Box
                  as="span"
                  position="absolute"
                  right={2}
                  fontSize="1.2em"
                  style={{
                    fontFamily: 'var(--font-ternary)',
                  }}
                >
                  {server_log.node_researcher}
                </Box>
              </Box>
              <Box
                width="50%"
                position="relative"
                left={'22.5%'}
                style={{
                  textTransform: 'uppercase',
                  fontSize: '1.1em',
                  fontFamily: 'var(--font-ternary)',
                }}
                mt={1.5}
              >
                {server_log.node_researched_timestamp}
              </Box>

              <Box
                width="100%"
                position="relative"
                left={'0%'}
                style={{
                  textTransform: 'uppercase',
                  fontSize: '1.1em',
                  fontFamily: 'var(--font-secondary)',
                }}
                mt={1.5}
              >
                {server_log.node_researcher_location}
              </Box>
              <Divider />
            </Stack.Item>
          ))}
        </Stack>
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
    <Window width={575} height={700} theme="ntos_terminal_sci_themed">
      <Window.Content scrollable backgroundColor="transparent">
        <Stack vertical backgroundColor="transparent">
          <Stack.Item grow backgroundColor="transparent">
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
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
