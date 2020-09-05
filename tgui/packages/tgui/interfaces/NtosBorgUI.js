import { classes } from 'common/react';
import { resolveAsset } from '../assets';
import { useBackend, useSharedState } from '../backend';
import { AnimatedNumber, Box, Button, Flex, Icon, NoticeBox, Section, Slider, ProgressBar, LabeledList, Table, Tabs } from '../components';
import { NtosWindow } from '../layouts';

export const NtosBorgUI = (props, context) => {
  const [tab, setTab] = useSharedState(context, 'tab', 1);
  const { act, data } = useBackend(context);
  const { PC_device_theme } = data;
  return (
    <NtosWindow
      width={800}
      height={500}
      theme={PC_device_theme}>
      <br></br>
      <br></br>
      <Tabs>
        <Tabs.Tab
          icon="list"
          lineHeight="23px"
          selected={tab === 1}
          onClick={() => setTab(1)}>
          Status
        </Tabs.Tab>
        <Tabs.Tab
          icon="list"
          lineHeight="23px"
          selected={tab === 2}
          onClick={() => setTab(2)}>
          Logs
        </Tabs.Tab>
      </Tabs>
      {tab === 1 && (
          <NtosBorgUIContent_one/>
        )}
        {tab === 2 && (
          <NtosBorgUIContent_two/>
      )}
      
    </NtosWindow>
  );
};

export const NtosBorgUIContent_one = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab_sub, setTab_two] = useSharedState(context, 'tab_sub', 1);
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
      hight="100%">
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
          <Tabs>
            <Tabs.Tab
              icon="list"
              lineHeight="23px"
              selected={tab_sub === 1}
              onClick={() => setTab_two(1)}>
              Actions
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              lineHeight="23px"
              selected={tab_sub === 2}
              onClick={() => setTab_two(2)}>
              Upgrades
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              lineHeight="23px"
              selected={tab_sub === 3}
              onClick={() => setTab_two(3)}>
              Diagnostics
            </Tabs.Tab>
          </Tabs>
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
    </Flex>
  );
};

export const NtosBorgUIContent_two = (props, context) => {
  const { act, data } = useBackend(context);
  const borgLog = data.borgLog || [];
  return (
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
  );
};

