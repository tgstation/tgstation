import { classes } from 'common/react';
import { resolveAsset } from '../assets';
import { useBackend, useSharedState } from '../backend';
import { AnimatedNumber, Box, Button, Flex, Icon, NoticeBox, Section, ProgressBar, LabeledList, Table, Tabs } from '../components';
import { NtosWindow } from '../layouts';

export const NtosBorgUI = (props, context) => {
  const [tab, setTab] = useSharedState(context, 'tab', 1);
  return (
    <NtosWindow
      width={700}
      height={500}
      theme="ntos">
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
  const {
    charge,
    maxcharge,
    integrity,
    modDisable,
    cover,
    locomotion,
    wireModule,
    wireCamera,
    wireAI,
    wireLaw,
  } = data;
  const borgName = data.name || [];
  const borgType = data.designation || [];
  const masterAI = data.masterAI || [];
  const laws = data.Laws || [];
  const borgLog = data.borgLog || [];
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
            fill={1}>
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
          <Flex
            direction={"row"}>
            <Flex.Item
              grow={1}>
              <Section
                title="Slot_1"
                fill={1}>
                {modDisable&1?<font color="red">OFFLINE</font>:<font color="green">ONLINE</font>}
              </Section>
            </Flex.Item>
            <Flex.Item
              grow={1}>
              <Section
                title="Slot_2"
                fill={1}>
                {modDisable&2?<font color="red">OFFLINE</font>:<font color="green">ONLINE</font>}
              </Section>
            </Flex.Item>
            <Flex.Item
              grow={1}>
              <Section
                title="Slot_3"
                fill={1}>
                {modDisable&4?<font color="red">OFFLINE</font>:<font color="green">ONLINE</font>}
              </Section>
            </Flex.Item>
          </Flex>
      </Flex.Item>
      <Flex.Item
        width="33%">
          <Section
            title="Diagnostics"
            fill={1}>
            <LabeledList>
              <LabeledList.Item
              label="AI Connection"
              color={wireAI=="FAULT"?"red":"green"}>
                {wireAI}
              </LabeledList.Item>
              <LabeledList.Item
              label="LawSync"
              color={wireLaw=="FAULT"?"red":"green"}>
                {wireLaw}
              </LabeledList.Item>
              <LabeledList.Item
              label="Camera"
              color={wireCamera=="FAULT"?"red":"green"}>
                {wireCamera}
              </LabeledList.Item>
              <LabeledList.Item
              label="Module Controller"
              color={wireModule=="FAULT"?"red":"green"}>
                {wireModule}
              </LabeledList.Item>
              <LabeledList.Item
              label="Motor Controller"
              color={locomotion=="ENABLED"?"green":"red"}>
                {locomotion}
              </LabeledList.Item>
              <LabeledList.Item
              label="Maintenance Cover"
              color={cover=="UNLOCKED"?"red":"green"}>
                <Button.Confirm
                  content={cover}
                  disabled={cover=="UNLOCKED"}
                  onClick={() => act('coverunlock')} />
              </LabeledList.Item>
            </LabeledList>
          </Section>
      </Flex.Item>
      </Flex>
      <Flex.Item
        height={21}>
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
      background_color="black"
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

