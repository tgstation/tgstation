import {
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { NtosWindow } from '../layouts';

export const NtosNetMonitor = (props) => {
  const { act, data } = useBackend();
  const [tab_main, setTab_main] = useSharedState('tab_main', 1);
  const {
    ntnetrelays,
    idsalarm,
    idsstatus,
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
              onClick={() => setTab_main(1)}
            >
              NtNet
            </Tabs.Tab>
            <Tabs.Tab
              icon="tablet"
              lineHeight="23px"
              selected={tab_main === 2}
              onClick={() => setTab_main(2)}
            >
              Tablets ({tablets.length})
            </Tabs.Tab>
          </Tabs>
        </Stack.Item>
        {tab_main === 1 && (
          <Stack.Item>
            <MainPage
              ntnetrelays={ntnetrelays}
              idsalarm={idsalarm}
              idsstatus={idsstatus}
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

const MainPage = (props) => {
  const { ntnetrelays, idsalarm, idsstatus, ntnetlogs = [] } = props;
  const { act, data } = useBackend();

  return (
    <Section>
      <NoticeBox>
        WARNING: Disabling wireless transmitters when using a wireless device
        may prevent you from reenabling them!
      </NoticeBox>
      <Section title="Wireless Connectivity">
        {ntnetrelays.map((relay) => (
          <Section
            key={relay.ref}
            title={relay.name}
            buttons={
              <Button.Confirm
                color={relay.is_operational ? 'good' : 'bad'}
                content={relay.is_operational ? 'ENABLED' : 'DISABLED'}
                onClick={() =>
                  act('toggle_relay', {
                    ref: relay.ref,
                  })
                }
              />
            }
          />
        ))}
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
        </LabeledList>
        <Section
          title="System Log"
          buttons={
            <Button.Confirm
              icon="trash"
              content="Clear Logs"
              onClick={() => act('purgelogs')}
            />
          }
        >
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

const TabletPage = (props) => {
  const { tablets } = props;
  const { act, data } = useBackend();
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
