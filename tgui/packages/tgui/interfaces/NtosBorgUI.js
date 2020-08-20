import { classes } from 'common/react';
import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Flex, Icon, NoticeBox, Section, ProgressBar, LabeledList } from '../components';
import { NtosWindow } from '../layouts';

export const NtosBorgUI = (props, context) => {
  return (
    <NtosWindow
      width={700}
      height={500}
      theme="ntos">
      <NtosBorgUIContent/>
    </NtosWindow>
  );
};

export const NtosBorgUIContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    charge,
    maxcharge,
    integrety,
    modDisable,
    cover,
    locomotion,
    wireModule,
    wireCamera,
    wireAI,
    wireLaw,
  } = data;
  const borgName = data.name || [];
  const borgType = data.type || [];
  const masterAI = data.masterAI || [];
  const laws = data.laws || [];
  const borgLog = data.borgLog || [];
  return (
    <Flex
      direction={"column"}
      hight="100%">
      <Flex
        direction={"row"}>
        <Flex.Item>
        <br></br><br></br>
        </Flex.Item>
      </Flex>
      <Flex
        direction={"row"}>
      <Flex.Item
        width="33%">
          <Section
            title="Configuration"
            fill={1}>
            <LabeledList>
              <LabeledList.Item
                label="Unit">
                {borgName}
              </LabeledList.Item>
              <LabeledList.Item
                label="Type">
                {borgType}
              </LabeledList.Item>
              <LabeledList.Item
                label="Master AI">
                {masterAI}
              </LabeledList.Item>
            </LabeledList>
          </Section>
      </Flex.Item>
      <Flex.Item
        grow={1}>
          <Section
            title="Status">
            Charge:
            <ProgressBar
              value={charge / maxcharge}>
              <AnimatedNumber value={charge} />
            </ProgressBar>
            Chassis Integrity:
            <ProgressBar
              value={integrety / 100}>
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
              color={wireCamera=="FALT"?"red":"green"}>
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
                  tooltip={"test"}
                  disabled={cover=="UNLOCKED"}
                  onClick={() => act('coverunlock')} />
              </LabeledList.Item>
            </LabeledList>
          </Section>
      </Flex.Item>
      </Flex>
      <Flex.Item>
          <Section
          title="Laws"
          fill={1}
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
          <LabeledList>
            {laws.map(law => (
              <LabeledList.Item>
              {law}
              </LabeledList.Item>
            ))}
          </LabeledList>
          </NtosWindow.Content>
          </Section>
      </Flex.Item>
    </Flex>
  );
};
