import { useBackend, useSharedState } from '../backend';
import { Box, Button, LabeledList, NoticeBox, NumberInput, Icon, Section, Stack, Tabs } from '../components';
import { NtosWindow } from '../layouts';

export const NtosNetMonitor = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab_main, setTab_main] = useSharedState(context, 'tab_main', 1);
  const {
    ntnetrelays,
    ntnetstatus,
    config_softwaredownload,
    config_peertopeer,
    config_communication,
    config_systemcontrol,
    idsalarm,
    idsstatus,
    ntnetmaxlogs,
    maxlogs,
    minlogs,
    ntnetlogs = [],
    tablets = [],
  } = data;
  return (
    <NtosWindow>
      <NtosWindow.Content scrollable>
        <Stack.Item>
          <Tabs>
            <Tabs.Tab
              icon="network-wired"
              lineHeight="23px"
              selected={tab_main === 1}
              onClick={() => setTab_main(1)}>
              NtNet
            </Tabs.Tab>
            <Tabs.Tab
              icon="tablet"
              lineHeight="23px"
              selected={tab_main === 2}
              onClick={() => setTab_main(2)}>
              Tablets ({tablets.length})
            </Tabs.Tab>
          </Tabs>
        </Stack.Item>
        {tab_main === 1 && (
          <Stack.Item>
            <MainPage
              ntnetrelays={ntnetrelays}
              ntnetstatus={ntnetstatus}
              config_softwaredownload={config_softwaredownload}
              config_peertopeer={config_peertopeer}
              config_communication={config_communication}
              config_systemcontrol={config_systemcontrol}
              idsalarm={idsalarm}
              idsstatus={idsstatus}
              ntnetmaxlogs={ntnetmaxlogs}
              maxlogs={maxlogs}
              minlogs={minlogs}
              ntnetlogs={ntnetlogs}
            />
          </Stack.Item>
        )}
        {tab_main === 2 && (
          <Stack.Item>
            <TabletPage tablets={tablets} />
          </Stack.Item>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const MainPage = (props, context) => {
  const {
    ntnetrelays,
    ntnetstatus,
    config_softwaredownload,
    config_peertopeer,
    config_communication,
    config_systemcontrol,
    idsalarm,
    idsstatus,
    ntnetmaxlogs,
    maxlogs,
    minlogs,
    ntnetlogs = [],
  } = props;
  const { act, data } = useBackend(context);
  return (
    <Section>
      <NoticeBox>
        WARNING: Disabling wireless transmitters when using a wireless device
        may prevent you from reenabling them!
      </NoticeBox>
      <Section
        title="Wireless Connectivity"
        buttons={
          <Button.Confirm
            icon={ntnetstatus ? 'power-off' : 'times'}
            content={ntnetstatus ? 'ENABLED' : 'DISABLED'}
            selected={ntnetstatus}
            onClick={() => act('toggleWireless')}
          />
        }>
        {ntnetrelays ? (
          <LabeledList>
            <LabeledList.Item label="Active NTNet Relays">
              {ntnetrelays}
            </LabeledList.Item>
          </LabeledList>
        ) : (
          'No Relays Connected'
        )}
      </Section>
      <Section title="Firewall Configuration">
        <LabeledList>
          <LabeledList.Item
            label="Software Downloads"
            buttons={
              <Button
                icon={config_softwaredownload ? 'power-off' : 'times'}
                content={config_softwaredownload ? 'ENABLED' : 'DISABLED'}
                selected={config_softwaredownload}
                onClick={() => act('toggle_function', { id: '1' })}
              />
            }
          />
          <LabeledList.Item
            label="Peer to Peer Traffic"
            buttons={
              <Button
                icon={config_peertopeer ? 'power-off' : 'times'}
                content={config_peertopeer ? 'ENABLED' : 'DISABLED'}
                selected={config_peertopeer}
                onClick={() => act('toggle_function', { id: '2' })}
              />
            }
          />
          <LabeledList.Item
            label="Communication Systems"
            buttons={
              <Button
                icon={config_communication ? 'power-off' : 'times'}
                content={config_communication ? 'ENABLED' : 'DISABLED'}
                selected={config_communication}
                onClick={() => act('toggle_function', { id: '3' })}
              />
            }
          />
          <LabeledList.Item
            label="Remote System Control"
            buttons={
              <Button
                icon={config_systemcontrol ? 'power-off' : 'times'}
                content={config_systemcontrol ? 'ENABLED' : 'DISABLED'}
                selected={config_systemcontrol}
                onClick={() => act('toggle_function', { id: '4' })}
              />
            }
          />
        </LabeledList>
      </Section>
      <Section title="Security Systems">
        {!!idsalarm && (
          <>
            <NoticeBox>NETWORK INCURSION DETECTED</NoticeBox>
            <Box italics>
              Abnormal activity has been detected in the network. Check system
              logs for more information
            </Box>
          </>
        )}
        <LabeledList>
          <LabeledList.Item
            label="IDS Status"
            buttons={
              <>
                <Button
                  icon={idsstatus ? 'power-off' : 'times'}
                  content={idsstatus ? 'ENABLED' : 'DISABLED'}
                  selected={idsstatus}
                  onClick={() => act('toggleIDS')}
                />
                <Button
                  icon="sync"
                  content="Reset"
                  color="bad"
                  onClick={() => act('resetIDS')}
                />
              </>
            }
          />
          <LabeledList.Item
            label="Max Log Count"
            buttons={
              <NumberInput
                value={ntnetmaxlogs}
                minValue={minlogs}
                maxValue={maxlogs}
                width="39px"
                onChange={(e, value) =>
                  act('updatemaxlogs', {
                    new_number: value,
                  })
                }
              />
            }
          />
        </LabeledList>
        <Section
          title="System Log"
          level={2}
          buttons={
            <Button.Confirm
              icon="trash"
              content="Clear Logs"
              onClick={() => act('purgelogs')}
            />
          }>
          {ntnetlogs.map((log) => (
            <Box key={log.entry} className="candystripe">
              {log.entry}
            </Box>
          ))}
        </Section>
      </Section>
    </Section>
  );
};

const TabletPage = (props, context) => {
  const { tablets } = props;
  const { act, data } = useBackend(context);
  if (!tablets.length) {
    return <NoticeBox>No tablets detected.</NoticeBox>;
  }
  return (
    <Section>
      <Stack vertical mt={1}>
        <Section fill textAlign="center">
          <Icon name="comment" mr={1} />
          Active Tablets
        </Section>
      </Stack>
      <Stack vertical mt={1}>
        <Section fill>
          <Stack vertical>
            {tablets.map((tablet) => (
              <Section
                key={tablet.ref}
                title={tablet.name}
                buttons={
                  <Button.Confirm
                    icon={tablet.enabled_spam ? 'unlock' : 'lock'}
                    color={tablet.enabled_spam ? 'good' : 'default'}
                    content={
                      tablet.enabled_spam
                        ? 'Restrict Mass PDA'
                        : 'Allow Mass PDA'
                    }
                    onClick={() =>
                      act('toggle_mass_pda', {
                        ref: tablet.ref,
                      })
                    }
                  />
                }
              />
            ))}
          </Stack>
        </Section>
      </Stack>
    </Section>
  );
};
