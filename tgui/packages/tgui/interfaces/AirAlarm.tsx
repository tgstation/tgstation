import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  Modal,
  NumberInput,
  Section,
  Table,
} from '../components';
import { Window } from '../layouts';
import { Scrubber, Vent, VentData, ScrubberData } from './common/AtmosControls';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

type AlarmThreshold = {
  warning_min: number;
  hazard_min: number;
  warning_max: number;
  hazard_max: number;
  threshold_name: string;
  threshold_unit: string;
};
type GasInformation = { name: string; value: string; status: 0 | 1 | 2 };
type AirAlarmStaticData = {
  modes: {
    name: string;
    mode: number;
    danger: boolean;
  }[];
  warning_min: number;
  warning_max: number;
  hazard_min: number;
  hazard_max: number;
};
type AirAlarmDynamicData = {
  locked: boolean;
  siliconUser: boolean;
  emagged: boolean;
  danger_level: number;
  atmos_alarm: boolean;
  fire_alarm: boolean;
  sensor_reading: Record<string, GasInformation>;
  thresholds: Record<string, AlarmThreshold>;
  vents: VentData[];
  scrubbers: ScrubberData[];
  mode: number;
};
type AirAlarmData = AirAlarmDynamicData & AirAlarmStaticData;

export const AirAlarm = (props, context) => {
  const { act, data } = useBackend<AirAlarmData>(context);
  const locked = data.locked && !data.siliconUser;
  return (
    <Window width={480} height={650}>
      <Window.Content scrollable>
        <InterfaceLockNoticeBox />
        <AirAlarmStatus />
        {!locked && <AirAlarmControl />}
      </Window.Content>
    </Window>
  );
};

const AirAlarmStatus = (props, context) => {
  const { data } = useBackend<AirAlarmData>(context);
  const dangerMap = {
    0: {
      color: 'good',
      localStatusText: 'Optimal',
    },
    1: {
      color: 'average',
      localStatusText: 'Caution',
    },
    2: {
      color: 'bad',
      localStatusText: 'Danger (Internals Required)',
    },
  };
  const localStatus = dangerMap[data.danger_level] || dangerMap[0];
  const { sensor_reading } = data;
  return (
    <Section title="Air Status">
      <LabeledList>
        {Object.entries(sensor_reading).map(([index, entry]) => {
          const status = dangerMap[entry.status] || dangerMap[0];
          return (
            <LabeledList.Item
              key={index}
              label={entry.name}
              color={status.color}>
              {entry.value}
            </LabeledList.Item>
          );
        })}
        <LabeledList.Item label="Local status" color={localStatus.color}>
          {localStatus.localStatusText}
        </LabeledList.Item>
        <LabeledList.Item
          label="Area status"
          color={data.atmos_alarm || data.fire_alarm ? 'bad' : 'good'}>
          {(data.atmos_alarm && 'Atmosphere Alarm')
            || (data.fire_alarm && 'Fire Alarm')
            || 'Nominal'}
        </LabeledList.Item>
        {Object.keys(data.sensor_reading).length <= 2 && (
          <LabeledList.Item label="Operational Warning" color="bad">
            Cannot obtain air sample for analysis.
          </LabeledList.Item>
        )}
        {!!data.emagged && (
          <LabeledList.Item label="Security Warning" color="bad">
            Safety measures offline. Device may exhibit abnormal behavior.
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};

const AIR_ALARM_ROUTES = {
  home: {
    title: 'Air Controls',
    component: () => AirAlarmControlHome,
  },
  vents: {
    title: 'Vent Controls',
    component: () => AirAlarmControlVents,
  },
  scrubbers: {
    title: 'Scrubber Controls',
    component: () => AirAlarmControlScrubbers,
  },
  modes: {
    title: 'Operating Mode',
    component: () => AirAlarmControlModes,
  },
  thresholds: {
    title: 'Alarm Thresholds',
    component: () => AirAlarmControlThresholds,
  },
};

const AirAlarmControl = (props, context) => {
  const [screen, setScreen] = useLocalState<string>(context, 'screen', 'home');
  const route = AIR_ALARM_ROUTES[screen] || AIR_ALARM_ROUTES.home;
  const Component = route.component();
  return (
    <Section
      title={route.title}
      buttons={
        (screen && (
          <Button
            icon="arrow-left"
            content="Back"
            onClick={() => setScreen('home')}
          />
        ))
      }>
      <Component />
    </Section>
  );
};

//  Home screen
// --------------------------------------------------------

const AirAlarmControlHome = (props, context) => {
  const { act, data } = useBackend<AirAlarmData>(context);
  const [screen, setScreen] = useLocalState(context, 'screen', 'home');
  const { mode, atmos_alarm } = data;
  return (
    <>
      <Button
        icon={atmos_alarm ? 'exclamation-triangle' : 'exclamation'}
        color={atmos_alarm && 'caution'}
        content="Area Atmosphere Alarm"
        onClick={() => act(atmos_alarm ? 'reset' : 'alarm')}
      />
      <Box mt={1} />
      <Button
        icon={mode === 3 ? 'exclamation-triangle' : 'exclamation'}
        color={mode === 3 && 'danger'}
        content="Panic Siphon"
        onClick={() =>
          act('mode', {
            mode: mode === 3 ? 1 : 3,
          })}
      />
      <Box mt={2} />
      <Button
        icon="sign-out-alt"
        content="Vent Controls"
        onClick={() => setScreen('vents')}
      />
      <Box mt={1} />
      <Button
        icon="filter"
        content="Scrubber Controls"
        onClick={() => setScreen('scrubbers')}
      />
      <Box mt={1} />
      <Button
        icon="cog"
        content="Operating Mode"
        onClick={() => setScreen('modes')}
      />
      <Box mt={1} />
      <Button
        icon="chart-bar"
        content="Alarm Thresholds"
        onClick={() => setScreen('thresholds')}
      />
    </>
  );
};

//  Vents
// --------------------------------------------------------

const AirAlarmControlVents = (props, context) => {
  const { data } = useBackend<AirAlarmData>(context);
  const { vents } = data;
  if (!vents || vents.length === 0) {
    return 'Nothing to show';
  }
  return vents.map((vent) => <Vent key={vent.id_tag} vent={vent} />);
};

//  Scrubbers
// --------------------------------------------------------

const AirAlarmControlScrubbers = (props, context) => {
  const { data } = useBackend<AirAlarmData>(context);
  const { scrubbers } = data;
  if (!scrubbers || scrubbers.length === 0) {
    return 'Nothing to show';
  }
  return scrubbers.map((scrubber) => (
    <Scrubber key={scrubber.id_tag} scrubber={scrubber} />
  ));
};

//  Modes
// --------------------------------------------------------

const AirAlarmControlModes = (props, context) => {
  const { act, data } = useBackend<AirAlarmData>(context);
  const { modes, mode } = data;
  if (!modes || modes.length === 0) {
    return 'Nothing to show';
  }
  return modes.map((mode_type) => (
    <Fragment key={mode_type.mode}>
      <Button
        icon={mode_type.mode === mode ? 'check-square-o' : 'square-o'}
        selected={mode_type.mode === mode}
        color={mode_type.mode === mode && mode_type.danger && 'danger'}
        content={mode_type.name}
        onClick={() => act('mode', { mode: mode_type.mode })}
      />
      <Box mt={1} />
    </Fragment>
  ));
};

//  Thresholds
// --------------------------------------------------------

const AirAlarmControlThresholds = (props, context) => {
  const { act, data } = useBackend<AirAlarmData>(context);
  // This is the state that opens a new modal to edit values with. 
  // ui_acts are sent by the modal.
  const [editingModal, setEditingModal] = useLocalState<{
    criteria: string;
    threshold_type: 'warning_min' | 'hazard_min' | 'warning_max' | 'hazard_max';
  } | null>(context, 'thresholdEdit', null);
  const { thresholds } = data;
  const thresholdMap = {
    warning_min: 'Lower Limit (Warning)',
    hazard_min: 'Lower Limit (Hazard)',
    warning_max: 'Upper Limit (Warning)',
    hazard_max: 'Upper Limit (Hazard)',
  };
  const identifierMap = {
    warning_min: data.warning_min,
    hazard_min: data.hazard_min,
    warning_max: data.warning_max,
    hazard_max: data.hazard_max,
  };
  return (
    <Table>
      <Table.Row>
        <Table.Cell />
        <Table.Cell>{thresholdMap['warning_min']}</Table.Cell>
        <Table.Cell>{thresholdMap['hazard_min']}</Table.Cell>
        <Table.Cell>{thresholdMap['warning_max']}</Table.Cell>
        <Table.Cell>{thresholdMap['hazard_max']}</Table.Cell>
      </Table.Row>
      {Object.entries(thresholds).map(([criteria, threshold]) => (
        <Table.Row key={threshold.threshold_name}>
          <Table.Cell>{threshold.threshold_name}</Table.Cell>
          <Table.Cell>
            <Button
              fluid
              onClick={() =>
                setEditingModal({
                  criteria: criteria,
                  threshold_type: 'warning_min',
                })}>
              {threshold.warning_min === -1
                ? 'Disabled'
                : `${threshold.warning_min} ${threshold.threshold_unit}`}
            </Button>
          </Table.Cell>
          <Table.Cell>
            <Button
              fluid
              onClick={() =>
                setEditingModal({
                  criteria: criteria,
                  threshold_type: 'hazard_min',
                })}>
              {threshold.hazard_min === -1
                ? 'Disabled'
                : `${threshold.hazard_min} ${threshold.threshold_unit}`}
            </Button>
          </Table.Cell>
          <Table.Cell>
            <Button
              fluid
              onClick={() =>
                setEditingModal({
                  criteria: criteria,
                  threshold_type: 'warning_max',
                })}>
              {threshold.warning_max === -1
                ? 'Disabled'
                : `${threshold.warning_max} ${threshold.threshold_unit}`}
            </Button>
          </Table.Cell>
          <Table.Cell>
            <Button
              fluid
              onClick={() =>
                setEditingModal({
                  criteria: criteria,
                  threshold_type: 'hazard_max',
                })}>
              {threshold.hazard_max === -1
                ? 'Disabled'
                : `${threshold.hazard_max} ${threshold.threshold_unit}`}
            </Button>
          </Table.Cell>
          <Table.Cell width={4.5}>
            <Button
              icon="times"
              color="bad"
              onClick={() =>
                act('kill_threshold', {
                  threshold_criteria: criteria,
                })}
            />
            <Button
              icon="sync"
              color="good"
              onClick={() =>
                act('reset_threshold', {
                  threshold_criteria: criteria,
                })}
            />
          </Table.Cell>
        </Table.Row>
      ))}
      {editingModal && (
        <Modal>
          <Section
            title={'Threshold Value Editor'}
            buttons={
              <Button onClick={() => setEditingModal(null)} icon="times" />
            }>
            <Box mb={1.5}>
              {`Currently editing ${thresholdMap[
                editingModal.threshold_type
              ].toLowerCase()} for ${thresholds[
                editingModal.criteria
              ].threshold_name.toLowerCase()}`}
            </Box>
            {thresholds[editingModal.criteria][editingModal.threshold_type]
            >= 0 
              ? (
                <>
                  <NumberInput
                    onChange={(e, value) =>
                      act('set_threshold', {
                        new_threshold: value,
                        threshold_type:
                        identifierMap[editingModal.threshold_type],
                        threshold_criteria: editingModal.criteria,
                      })}
                    unit={thresholds[editingModal.criteria].threshold_unit}
                    value={
                      thresholds[editingModal.criteria][
                        editingModal.threshold_type]
                    }
                    minValue={0}
                    maxValue={100000}
                    step={10}
                  />
                  <Button
                    onClick={() =>
                      act('set_threshold', {
                        new_threshold: -1,
                        threshold_type:
                        identifierMap[editingModal.threshold_type],
                        threshold_criteria: editingModal.criteria,
                      })}>
                    {'Disable'}
                  </Button>
                </>
              ) : (
                <Button
                  onClick={() =>
                    act('set_threshold', {
                      new_threshold: 0,
                      threshold_type: identifierMap[
                        editingModal.threshold_type],
                      threshold_criteria: editingModal.criteria,
                    })}>
                  {'Enable'}
                </Button>
              )}
          </Section>
        </Modal>
      )}
    </Table>
  );
};
