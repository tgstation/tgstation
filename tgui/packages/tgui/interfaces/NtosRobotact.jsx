import { useState } from 'react';
import {
  AnimatedNumber,
  Box,
  Button,
  Flex,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Slider,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { formatEnergy } from 'tgui-core/format';
import { formatPower } from 'tgui-core/format';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

export const NtosRobotact = (props) => {
  return (
    <NtosWindow width={800} height={600}>
      <NtosWindow.Content>
        <NtosRobotactContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosRobotactContent = (props) => {
  const { act, data } = useBackend();
  const [tab_main, setTab_main] = useState(1);
  const [tab_sub, setTab_sub] = useState(1);
  const {
    charge,
    maxcharge,
    integrity,
    lampIntensity,
    lampConsumption,
    cover,
    locomotion,
    wireModule,
    wireCamera,
    wireAI,
    wireLaw,
    sensors,
    printerPictures,
    printerToner,
    printerTonerMax,
    thrustersInstalled,
    thrustersStatus,
    selfDestructAble,
    cyborg_groups = [],
    masterAI_online,
    MasterAI_connected,
  } = data;
  const borgName = data.borgName || [];
  const borgType = data.designation || [];
  const masterAI = data.masterAI || [];
  const laws = data.Laws || [];
  const borgLog = data.borgLog || [];
  const borgUpgrades = data.borgUpgrades || [];

  return (
    <Flex direction={'column'}>
      <Flex.Item position="relative" mb={1}>
        <Tabs>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab_main === 1}
            onClick={() => setTab_main(1)}
          >
            Status
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab_main === 2}
            onClick={() => setTab_main(2)}
          >
            Logs
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab_main === 3}
            onClick={() => setTab_main(3)}
          >
            Network
          </Tabs.Tab>
        </Tabs>
      </Flex.Item>
      {tab_main === 1 && (
        <>
          <Flex direction={'row'}>
            <Flex.Item width="30%">
              <Section title="Configuration" fill>
                <LabeledList>
                  <LabeledList.Item label="Unit">
                    {borgName.slice(0, 17)}
                  </LabeledList.Item>
                  <LabeledList.Item label="Type">{borgType}</LabeledList.Item>
                  <LabeledList.Item label="AI">
                    {masterAI.slice(0, 17)}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Flex.Item>
            <Flex.Item grow={1} basis="content" ml={1}>
              <Section title="Status">
                Charge:
                <Button
                  content="Power Alert"
                  disabled={charge}
                  onClick={() => act('alertPower')}
                />
                <ProgressBar
                  value={charge / maxcharge}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.1, 0.5],
                    bad: [-Infinity, 0.1],
                  }}
                >
                  <AnimatedNumber
                    value={charge}
                    format={(charge) => formatEnergy(charge)}
                  />
                </ProgressBar>
                Chassis Integrity:
                <ProgressBar
                  value={integrity}
                  minValue={0}
                  maxValue={100}
                  ranges={{
                    bad: [-Infinity, 25],
                    average: [25, 75],
                    good: [75, Infinity],
                  }}
                />
              </Section>
              <Section title="Lamp Power">
                <Slider
                  value={lampIntensity}
                  step={1}
                  stepPixelSize={25}
                  maxValue={5}
                  minValue={1}
                  onChange={(e, value) =>
                    act('lampIntensity', {
                      ref: value,
                    })
                  }
                />
                Lamp power usage: {formatPower(lampIntensity * lampConsumption)}
              </Section>
            </Flex.Item>
            <Flex.Item width="50%" ml={1}>
              <Section fitted>
                <Tabs fluid={1} textAlign="center">
                  <Tabs.Tab
                    icon=""
                    lineHeight="23px"
                    selected={tab_sub === 1}
                    onClick={() => setTab_sub(1)}
                  >
                    Actions
                  </Tabs.Tab>
                  <Tabs.Tab
                    icon=""
                    lineHeight="23px"
                    selected={tab_sub === 2}
                    onClick={() => setTab_sub(2)}
                  >
                    Upgrades
                  </Tabs.Tab>
                  <Tabs.Tab
                    icon=""
                    lineHeight="23px"
                    selected={tab_sub === 3}
                    onClick={() => setTab_sub(3)}
                  >
                    Diagnostics
                  </Tabs.Tab>
                </Tabs>
              </Section>
              {tab_sub === 1 && (
                <Section>
                  <LabeledList>
                    <LabeledList.Item label="Maintenance Cover">
                      <Button.Confirm
                        content="Unlock"
                        disabled={cover === 'UNLOCKED'}
                        onClick={() => act('coverunlock')}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Sensor Overlay">
                      <Button
                        content={sensors}
                        onClick={() => act('toggleSensors')}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item
                      label={`Stored Photos (${printerPictures})`}
                    >
                      <Button
                        content="View"
                        disabled={!printerPictures}
                        onClick={() => act('viewImage')}
                      />
                      <Button
                        content="Print"
                        disabled={!printerPictures}
                        onClick={() => act('printImage')}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Printer Toner">
                      <ProgressBar value={printerToner / printerTonerMax} />
                    </LabeledList.Item>
                    {!!thrustersInstalled && (
                      <LabeledList.Item label="Toggle Thrusters">
                        <Button
                          content={thrustersStatus}
                          onClick={() => act('toggleThrusters')}
                        />
                      </LabeledList.Item>
                    )}
                    {!!selfDestructAble && (
                      <LabeledList.Item label="Self Destruct">
                        <Button.Confirm
                          content="ACTIVATE"
                          color="red"
                          onClick={() => act('selfDestruct')}
                        />
                      </LabeledList.Item>
                    )}
                  </LabeledList>
                </Section>
              )}
              {tab_sub === 2 && (
                <Section>
                  {borgUpgrades.map((upgrade) => (
                    <Box mb={1} key={upgrade}>
                      {upgrade}
                    </Box>
                  ))}
                </Section>
              )}
              {tab_sub === 3 && (
                <Section>
                  <LabeledList>
                    <LabeledList.Item
                      label="AI Connection"
                      color={
                        wireAI === 'FAULT'
                          ? 'red'
                          : wireAI === 'READY'
                            ? 'yellow'
                            : 'green'
                      }
                    >
                      {wireAI}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="LawSync"
                      color={wireLaw === 'FAULT' ? 'red' : 'green'}
                    >
                      {wireLaw}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Camera"
                      color={
                        wireCamera === 'FAULT'
                          ? 'red'
                          : wireCamera === 'DISABLED'
                            ? 'yellow'
                            : 'green'
                      }
                    >
                      {wireCamera}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Module Controller"
                      color={wireModule === 'FAULT' ? 'red' : 'green'}
                    >
                      {wireModule}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Motor Controller"
                      color={
                        locomotion === 'FAULT'
                          ? 'red'
                          : locomotion === 'DISABLED'
                            ? 'yellow'
                            : 'green'
                      }
                    >
                      {locomotion}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Maintenance Cover"
                      color={cover === 'UNLOCKED' ? 'red' : 'green'}
                    >
                      {cover}
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              )}
            </Flex.Item>
          </Flex>
          <Flex.Item height={21} mt={1}>
            <Section
              title="Laws"
              fill
              scrollable
              buttons={
                <>
                  <Button
                    content="State Laws"
                    onClick={() => act('lawstate')}
                  />
                  <Button icon="volume-off" onClick={() => act('lawchannel')} />
                </>
              }
            >
              {laws.map((law) => (
                <Box mb={1} key={law}>
                  {law}
                </Box>
              ))}
            </Section>
          </Flex.Item>
        </>
      )}
      {tab_main === 2 && (
        <Flex.Item height={40}>
          <Section fill scrollable backgroundColor="black">
            {borgLog.map((log) => (
              <Box mb={1} key={log}>
                <font color="green">{log}</font>
              </Box>
            ))}
          </Section>
        </Flex.Item>
      )}
      {tab_main === 3 && (
        <Flex.Item height={40}>
          <Section
            title={MasterAI_connected ? masterAI : 'NOT CONFIGURED'}
            textAlign="center"
          >
            <LabeledList>
              <LabeledList.Item label="Status">
                <Box color={masterAI_online ? 'good' : 'bad'}>
                  {!MasterAI_connected
                    ? 'No Conection'
                    : masterAI_online
                      ? 'Online'
                      : 'Unresponsive'}
                </Box>
              </LabeledList.Item>
            </LabeledList>
          </Section>

          <Stack vertical>
            {cyborg_groups.map((borggroup, cyborgindex) => (
              <Stack.Item key={cyborgindex}>
                <Stack>
                  {borggroup.map((cyborg, borgindex) => (
                    <Stack.Item key={borgindex} width="24.25%">
                      <Section
                        key={cyborg.ref}
                        title={cyborg.otherBorgName.slice(0, 20)}
                      >
                        <LabeledList>
                          <LabeledList.Item label="Status">
                            <Box
                              color={
                                cyborg.status
                                  ? 'bad'
                                  : cyborg.locked_down
                                    ? 'average'
                                    : 'good'
                              }
                            >
                              {cyborg.status
                                ? 'Not Responding'
                                : cyborg.locked_down
                                  ? 'Locked Down'
                                  : cyborg.shell_discon
                                    ? 'Nominal/Disconnected'
                                    : 'Nominal'}
                            </Box>
                          </LabeledList.Item>
                          <LabeledList.Item label="Condition">
                            <Box
                              color={
                                cyborg.integ <= 25
                                  ? 'bad'
                                  : cyborg.integ <= 75
                                    ? 'average'
                                    : 'good'
                              }
                            >
                              {cyborg.integ === 0
                                ? 'Hard Fault'
                                : cyborg.integ <= 25
                                  ? 'Functionality Disrupted'
                                  : cyborg.integ <= 75
                                    ? 'Functionality Impaired'
                                    : 'Operational'}
                            </Box>
                          </LabeledList.Item>
                          <LabeledList.Item label="Charge">
                            <Box
                              color={
                                cyborg.charge <= 30
                                  ? 'bad'
                                  : cyborg.charge <= 70
                                    ? 'average'
                                    : 'good'
                              }
                            >
                              {typeof cyborg.charge === 'number'
                                ? `${cyborg.charge}%`
                                : 'No Cell'}
                            </Box>
                          </LabeledList.Item>
                          <LabeledList.Item label="Model">
                            {cyborg.module}
                          </LabeledList.Item>
                        </LabeledList>
                      </Section>
                    </Stack.Item>
                  ))}
                </Stack>
                <Stack.Divider />
              </Stack.Item>
            ))}
          </Stack>

          {!cyborg_groups.length && (
            <NoticeBox textAlign="center" top="30%" position="relative">
              <Box fontSize={2}>
                CONNECTION UNAVAILABLE -- NETWORK STATUS UNKNOWN
              </Box>
            </NoticeBox>
          )}
        </Flex.Item>
      )}
    </Flex>
  );
};
