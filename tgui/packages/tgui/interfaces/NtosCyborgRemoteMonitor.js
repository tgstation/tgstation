import { useBackend, useSharedState } from '../backend';
import { Box, Button, Flex, Fragment, LabeledList, NoticeBox, ProgressBar, Section, Tabs } from '../components';
import { NtosWindow } from '../layouts';

export const NtosCyborgRemoteMonitor = (props, context) => {
  return (
    <NtosWindow
      width={600}
      height={800}
      resizable>
      <NtosWindow.Content scrollable>
        <NtosCyborgRemoteMonitorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const ProgressSwitch = (param) => {
  switch (param) {
    case -1:
      return '_';
    case 0:
      return 'Connecting';
    case 25:
      return 'Requesting Data';
    case 50:
      return 'Starting Transfer';
    case 75:
      return 'Downloading';
    case 100:
      return 'Formatting';
  };
};

export const NtosCyborgRemoteMonitorContent = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab_main, setTab_main] = useSharedState(context, 'tab_main', 1);
  const {
    card,
    cyborgs = [],
    DL_progress,
  } = data;
  const storedlog = data.borglog || [];

  if (!cyborgs.length) {
    return (
      <NoticeBox>
        No cyborg units detected.
      </NoticeBox>
    );
  }

  return (
    <Flex
      direction={"column"}>
    <Flex.Item
      position="relative"
      mb={1}>
      <Tabs>
        <Tabs.Tab
          icon="robot"
          lineHeight="23px"
          selected={tab_main === 1}
          onClick={() => setTab_main(1)}>
          Cyborgs
        </Tabs.Tab>
        <Tabs.Tab
          icon="clipboard"
          lineHeight="23px"
          selected={tab_main === 2}
          onClick={() => setTab_main(2)}>
          Stored Log File
        </Tabs.Tab>
      </Tabs>
    </Flex.Item>
    {tab_main === 1 && (
      <>
        {!card && (
          <NoticeBox>
            Certain features require an ID card login.
          </NoticeBox>
        )}
        {cyborgs.map(cyborg => {
          return (
            <Section
              key={cyborg.ref}
              title={cyborg.name}
              buttons={(
                <Button
                  icon="terminal"
                  content="Send Message"
                  color="blue"
                  disabled={!card}
                  onClick={() => act('messagebot', {
                    ref: cyborg.ref,
                  })} />
              )}>
              <LabeledList>
                <LabeledList.Item label="Status">
                  <Box color={cyborg.status
                    ? 'bad'
                    : cyborg.locked_down
                      ? 'average'
                      : 'good'}>
                    {cyborg.status
                      ? "Not Responding"
                      : cyborg.locked_down
                        ? "Locked Down"
                        : cyborg.shell_discon
                          ? "Nominal/Disconnected"
                          : "Nominal"}
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Charge">
                  <Box color={cyborg.charge <= 30
                    ? 'bad'
                    : cyborg.charge <= 70
                      ? 'average'
                      : 'good'}>
                    {typeof cyborg.charge === 'number'
                      ? cyborg.charge + "%"
                      : "Not Found"}
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Model">
                  {cyborg.module}
                </LabeledList.Item>
                <LabeledList.Item label="Upgrades">
                  {cyborg.upgrades}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          );
        })}
      </>
    )}
    {tab_main === 2 && (
      <Fragment>
        <Flex.Item>
          <Section>
            Scan a cyborg to download stored logs.
            <ProgressBar
              value={DL_progress/100}>
              {ProgressSwitch(DL_progress)}
            </ProgressBar>
          </Section>
        </Flex.Item>
        <Flex.Item
          height={40}>
          <Section
            fill
            scrollable
            backgroundColor="black">
            {storedlog.map(log => (
              <Box
                mb={1}
                key={log}
                color="green">
                {log}
              </Box>
            ))}
          </Section>
        </Flex.Item>
      </Fragment>
    )}
    </Flex>
  );
};
