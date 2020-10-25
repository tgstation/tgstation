import { GenericUplink } from './Uplink';
import { useBackend, useSharedState } from '../backend';
import { Button, LabeledList, NoticeBox, Section, Tabs } from '../components';
import { Fragment } from 'inferno';
import { Window } from '../layouts';

export const AbductorConsole = (props, context) => {
  const [tab, setTab] = useSharedState(context, 'tab', 1);
  return (
    <Window
      theme="abductor"
      width={600}
      height={532}
      resizable>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 1}
            onClick={() => setTab(1)}>
            Abductsoft 3000
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 2}
            onClick={() => setTab(2)}>
            Mission Settings
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && (
          <Abductsoft />
        )}
        {tab === 2 && (
          <Fragment>
            <EmergencyTeleporter />
            <VestSettings />
          </Fragment>
        )}
      </Window.Content>
    </Window>
  );
};

const Abductsoft = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    experiment,
    points,
    credits,
  } = data;

  if (!experiment) {
    return (
      <NoticeBox danger>
        No Experiment Machine Detected
      </NoticeBox>
    );
  }

  return (
    <Fragment>
      <Section>
        <LabeledList>
          <LabeledList.Item label="Collected Samples">
            {points}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <GenericUplink
        currencyAmount={credits}
        currencySymbol="Credits" />
    </Fragment>
  );
};

const EmergencyTeleporter = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    pad,
    gizmo,
  } = data;

  if (!pad) {
    return (
      <NoticeBox danger>
        No Telepad Detected
      </NoticeBox>
    );
  }

  return (
    <Section
      title="Emergency Teleport"
      buttons={(
        <Button
          icon="exclamation-circle"
          content="Activate"
          color="bad"
          onClick={() => act('teleporter_send')} />
      )}>
      <LabeledList>
        <LabeledList.Item label="Mark Retrieval">
          <Button
            icon={gizmo ? "user-plus" : "user-slash"}
            content={gizmo ? "Retrieve" : "No Mark"}
            disabled={!gizmo}
            onClick={() => act('teleporter_retrieve')} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const VestSettings = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    vest,
    vest_mode,
    vest_lock,
  } = data;

  if (!vest) {
    return (
      <NoticeBox danger>
        No Agent Vest Detected
      </NoticeBox>
    );
  }

  return (
    <Section
      title="Agent Vest Settings"
      buttons={(
        <Button
          icon={vest_lock ? 'lock' : 'unlock'}
          content={vest_lock ? 'Locked' : 'Unlocked'}
          onClick={() => act('toggle_vest')} />
      )}>
      <LabeledList>
        <LabeledList.Item label="Mode">
          <Button
            icon={vest_mode === 1 ? 'eye-slash' : 'fist-raised'}
            content={vest_mode === 1 ? "Stealth" : "Combat"}
            onClick={() => act('flip_vest')} />
        </LabeledList.Item>
        <LabeledList.Item label="Disguise">
          <Button
            icon="user-secret"
            content="Select"
            onClick={() => act('select_disguise')} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
