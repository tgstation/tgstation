import { classes } from 'common/react';
import { resolveAsset } from '../assets';
import { useBackend, useSharedState } from '../backend';
import { AnimatedNumber, Box, Button, Flex, Icon, NoticeBox, Section, Slider, ProgressBar, LabeledList, Table, Tabs } from '../components';
import { NtosWindow } from '../layouts';

export const NtosRobotactUI = (props, context) => {
  const { act, data } = useBackend(context);
  const { PC_device_theme } = data;
  return (
    <NtosWindow
      width={800}
      height={500}
      theme={PC_device_theme}>
      <NtosRobotactContent/>
    </NtosWindow>
  );
};

export const NtosRobotactContent = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab_main, setTab_main] = useSharedState(context, 'tab_main', 1);
  const [tab_sub, setTab_sub] = useSharedState(context, 'tab_sub', 1);
  const {
    charge,
    maxcharge,
    integrity,
    lampIntensity,
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
  } = data;
  const borgName = data.name || [];
  const borgType = data.designation || [];
  const masterAI = data.masterAI || [];
  const laws = data.Laws || [];
  const borgLog = data.borgLog || [];
  const borgUpgrades = data.borgUpgrades || [];
  return (
    <Flex
      direction={"column"}
      height="100%">
      <Flex.Item
      position="relative">
        <br/>
        <br/>
        <Tabs>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab_main === 1}
            onClick={() => setTab_main(1)}>
            Status
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab_main === 2}
            onClick={() => setTab_main(2)}>
            Logs
          </Tabs.Tab>
        </Tabs>
      </Flex.Item>
      {tab_main === 1 && (
      <Fragment>
        <Flex
          direction={"row"}>
        <Flex.Item
          width="30%">
            <Section
              title="Configuration"
              fill>
              <LabeledList>
                <LabeledList.Item
                  label="Unit">
                  {borgName.slice(0,17)}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Type">
                  {borgType}
                </LabeledList.Item>
                <LabeledList.Item
                  label="AI">
                  {masterAI.slice(0,17)}
                </LabeledList.Item>
              </LabeledList>
            </Section>
        </Flex.Item>
        <Flex.Item
          grow={1}>
            <Section
              title="Status">
              Charge:
              <Button
                content="Power Alert"
                disabled={charge}
                onClick={() => act('alertPower')} />
              <ProgressBar
                value={charge / maxcharge}>
                <AnimatedNumber value={charge} />
              </ProgressBar>
              Chassis Integrity:
              <ProgressBar
                value={integrity / 100}>
              </ProgressBar>
            </Section>
            <Section
            title="Lamp Power">
            <Slider
              value={lampIntensity}
              step={1}
              stepPixelSize={25}
              maxValue={5}
              minValue={1}
              onChange={(e, value) => act('lampIntensity', {
                ref: value,
            })}/>
            </Section>
        </Flex.Item>
        <Flex.Item
          width="50%">
            <Section>
              <Tabs>
                <Tabs.Tab
                  icon="list"
                  lineHeight="23px"
                  selected={tab_sub === 1}
                  onClick={() => setTab_sub(1)}>
                  Actions
                </Tabs.Tab>
                <Tabs.Tab
                  icon="list"
                  lineHeight="23px"
                  selected={tab_sub === 2}
                  onClick={() => setTab_sub(2)}>
                  Upgrades
                </Tabs.Tab>
                <Tabs.Tab
                  icon="list"
                  lineHeight="23px"
                  selected={tab_sub === 3}
                  onClick={() => setTab_sub(3)}>
                  Diagnostics
                </Tabs.Tab>
              </Tabs>
            </Section>
            {tab_sub === 1 && (
            <Section
              fill>
              <LabeledList>
                <LabeledList.Item
                  label="Maintenance Cover">
                    <Button.Confirm
                      content="Unlock"
                      disabled={cover=="UNLOCKED"}
                      onClick={() => act('coverunlock')} />
                </LabeledList.Item>
                <LabeledList.Item
                  label="Sensor Overlay">
                    <Button
                      content={sensors}
                      onClick={() => act('toggleSensors')} />
                </LabeledList.Item>
                <LabeledList.Item
                  label={"Stored Photos (" + printerPictures + ")"}>
                    <Button
                      content="View"
                      disabled={!printerPictures}
                      onClick={() => act('viewImage')} />
                    <Button
                      content="Print"
                      disabled={!printerPictures}
                      onClick={() => act('printImage')} />
                </LabeledList.Item>
                <LabeledList.Item
                    label="Printer Toner">
                    <ProgressBar
                      value={printerToner / printerTonerMax}>
                    </ProgressBar>
                </LabeledList.Item>
                {!!thrustersInstalled && (
                  <LabeledList.Item
                    label="Toggle Thrusters">
                    <Button
                      content={thrustersStatus}
                      onClick={() => act('toggleThrusters')} />
                  </LabeledList.Item>
                )}
              </LabeledList>
            </Section>
            )}
            {tab_sub === 2 && (
            <Section
              fill>
              <Table>
                {borgUpgrades.map(upgrade => (
                  <Table.Row>
                    {upgrade}
                  </Table.Row>
                ))}
              </Table>
            </Section>
            )}
            {tab_sub === 3 && ( 
              <Section
                fill>
                <LabeledList>
                  <LabeledList.Item
                  label="AI Connection"
                  color={wireAI=="FAULT"?'red': wireAI=="READY"?'yellow': 'green'}>
                    {wireAI}
                  </LabeledList.Item>
                  <LabeledList.Item
                  label="LawSync"
                  color={wireLaw=="FAULT"?"red":"green"}>
                    {wireLaw}
                  </LabeledList.Item>
                  <LabeledList.Item
                  label="Camera"
                  color={wireCamera=="FAULT"?'red': wireCamera=="DISABLED"?'yellow': 'green'}>
                    {wireCamera}
                  </LabeledList.Item>
                  <LabeledList.Item
                  label="Module Controller"
                  color={wireModule=="FAULT"?"red":"green"}>
                    {wireModule}
                  </LabeledList.Item>
                  <LabeledList.Item
                  label="Motor Controller"
                  color={locomotion=="FAULT"?'red': locomotion=="DISABLED"?'yellow': 'green'}>
                    {locomotion}
                  </LabeledList.Item>
                  <LabeledList.Item
                  label="Maintenance Cover"
                  color={cover=="UNLOCKED"?"red":"green"}>
                    {cover}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            )}
        </Flex.Item>
        </Flex>
        <Flex.Item
          height={18}>
          <Section
            title="Laws"
            fill
              buttons={(
                <Fragment>
                  <Button
                    content="State Laws"
                    onClick={() => act('lawstate')} />
                  <Button
                    icon="volume-off"
                    onClick={() => act('lawchannel')} />
                </Fragment>
              )}>
            <NtosWindow.Content scrollable>
            <Table>
              {laws.map(law => (
                <Table.Row>
                  {law}
                </Table.Row>
              ))}
            </Table>
            </NtosWindow.Content>
          </Section>
        </Flex.Item>
      </Fragment>
      )}
      {tab_main === 2 && (
      <Flex.Item>
        <Section
        backgroundColor="black"
        height={34}>
        <NtosWindow.Content scrollable>
        <Table>
          {borgLog.map(log => (
            <Table.Row>
              <font color="green">{log}</font>
            </Table.Row>
          ))}
        </Table>
        </NtosWindow.Content>
        </Section>
      </Flex.Item>
      )}
    </Flex>
  );
};

