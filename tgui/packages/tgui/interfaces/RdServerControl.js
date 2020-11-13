import { useBackend, useLocalState } from '../backend';
import { Box, Button, Collapsible, LabeledList, ProgressBar, Section, Tabs, Table } from '../components';
import { Window } from '../layouts';

export const RdServerControl = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    rnd_servers,
    research_logs,
  } = data;
  const [
    tabIndex,
    setTabIndex,
  ] = useLocalState(context, 'tab-index', 1);

  return (
    <Window
      width={640}
      height={640}>
      <Window.Content>
        <Tabs>
          <Tabs.Tab
            selected={tabIndex === 1}
            onClick={() => setTabIndex(1)}>
            R&amp;D Server Control
          </Tabs.Tab>
          <Tabs.Tab
            selected={tabIndex === 2}
            onClick={() => setTabIndex(2)}>
            Research Log
          </Tabs.Tab>
        </Tabs>
        {tabIndex === 1 && (
          <Box>
            {rnd_servers.map(rnd_server => (
              <Section key={rnd_server.ref}
                title={rnd_server.name}
                buttons={(
                  <Button
                    icon="plug"
                    color={rnd_server.research_disabled ? "bad" : "good"}
                    onClick={() => act('rnd_server_power', {
                      rnd_server: rnd_server.ref,
                      research_disabled: !rnd_server.research_disabled,
                    })} />
                )}>
                <LabeledList>
                  <LabeledList.Item label="Temperature">
                    <Box color={rnd_server.current_temp_color}>
                      {rnd_server.current_temp}K
                    </Box>
                  </LabeledList.Item>
                  <LabeledList.Item label="Efficiency">
                    {(rnd_server.efficiency * 100)}%
                  </LabeledList.Item>
                  <LabeledList.Item label="Status">
                    {rnd_server.research_disabled
                      ? <Box color="bad">Research Disabled</Box>
                      : <Box color="good">Research Enabled</Box> }
                    {rnd_server.unpowered && <Box color="bad">Power Outage Detected</Box>}
                    {rnd_server.emped && <Box color="bad">Electrical Interference Detected</Box>}
                    {rnd_server.emagged && <Box color="bad">Firmware Errors Detected</Box>}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            ))}
          </Box>
        )}
        {tabIndex === 2 && (
          <Section key="Research Logs">
            <Table>
              <Table.Row header>
                <Table.Cell>Entry</Table.Cell>
                <Table.Cell>Research Name</Table.Cell>
                <Table.Cell>Cost</Table.Cell>
                <Table.Cell>Researcher Name</Table.Cell>
                <Table.Cell>Console Location</Table.Cell>
              </Table.Row>
              {research_logs.map((research_log, entryId) => (
                <Table.Row key={entryId}>
                  <Table.Cell>
                    {entryId+1}
                  </Table.Cell>
                  <Table.Cell>
                    {research_log[0]}
                  </Table.Cell>
                  <Table.Cell>
                    {research_log[1]}
                  </Table.Cell>
                  <Table.Cell>
                    {research_log[2]}
                  </Table.Cell>
                  <Table.Cell>
                    {research_log[3]}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
