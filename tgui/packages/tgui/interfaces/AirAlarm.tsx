import { BooleanLike } from 'common/react';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, Modal, NumberInput, Section, Table } from '../components';
import { Window } from '../layouts';
import { Scrubber, ScrubberProps, Vent, VentProps } from './common/AtmosControls';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

type AirAlarmData = {
  locked: BooleanLike;
  siliconUser: BooleanLike;
  emagged: BooleanLike;
  dangerLevel: 0 | 1 | 2;
  atmosAlarm: BooleanLike; // fix this
  fireAlarm: BooleanLike;
  envData: {
    name: string;
    value: string; // preformatted in backend, shorter code that way.
    danger: 0 | 1 | 2;
  }[];
  tlvSettings: {
    id: string;
    name: string;
    unit: string;
    warning_min: number;
    hazard_min: number;
    warning_max: number;
    hazard_max: number;
  }[];
  vents: VentProps[];
  scrubbers: ScrubberProps[];
  selectedModePath: string;
  panicSiphonPath: string;
  filteringPath: string;
  modes: {
    name: string;
    desc: string;
    path: string;
    danger: BooleanLike;
  }[];
  thresholdTypeMap: Record<string, number>;
};

export const AirAlarm = (props, context) => {
  const { act, data } = useBackend<AirAlarmData>(context);
  const locked = data.locked && !data.siliconUser;
  return (
    <Window width={475} height={650}>
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
  const { envData } = data;
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
  const localStatus = dangerMap[data.dangerLevel] || dangerMap[0];
  return (
    <Section title="Air Status">
      <LabeledList>
        {(envData.length > 0 && (
          <>
            {envData.map((entry) => {
              const status = dangerMap[entry.danger] || dangerMap[0];
              return (
                <LabeledList.Item
                  key={entry.name}
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
              color={data.atmosAlarm || data.fireAlarm ? 'bad' : 'good'}>
              {(data.atmosAlarm && 'Atmosphere Alarm') ||
                (data.fireAlarm && 'Fire Alarm') ||
                'Nominal'}
            </LabeledList.Item>
          </>
        )) || (
          <LabeledList.Item label="Warning" color="bad">
            Cannot obtain air sample for analysis.
          </LabeledList.Item>
        )}
        {!!data.emagged && (
          <LabeledList.Item label="Warning" color="bad">
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
} as const;

type Screen = keyof typeof AIR_ALARM_ROUTES;

const AirAlarmControl = (props, context) => {
  const [screen, setScreen] = useLocalState<Screen>(context, 'screen', 'home');
  const route = AIR_ALARM_ROUTES[screen] || AIR_ALARM_ROUTES.home;
  const Component = route.component();
  return (
    <Section
      title={route.title}
      buttons={
        screen && (
          <Button
            icon="arrow-left"
            content="Back"
            onClick={() => setScreen('home')}
          />
        )
      }>
      <Component />
    </Section>
  );
};

//  Home screen
// --------------------------------------------------------

const AirAlarmControlHome = (props, context) => {
  const { act, data } = useBackend<AirAlarmData>(context);
  const [screen, setScreen] = useLocalState<Screen>(context, 'screen', 'home');
  const { selectedModePath, panicSiphonPath, filteringPath, atmosAlarm } = data;
  const isPanicSiphoning = selectedModePath === panicSiphonPath;
  return (
    <>
      <Button
        icon={atmosAlarm ? 'exclamation-triangle' : 'exclamation'}
        color={atmosAlarm && 'caution'}
        content="Area Atmosphere Alarm"
        onClick={() => act(atmosAlarm ? 'reset' : 'alarm')}
      />
      <Box mt={1} />
      <Button
        icon={isPanicSiphoning ? 'exclamation-triangle' : 'exclamation'}
        color={isPanicSiphoning && 'danger'}
        content="Panic Siphon"
        onClick={() =>
          act('mode', {
            mode: isPanicSiphoning ? filteringPath : panicSiphonPath,
          })
        }
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
    return <span>Nothing to show</span>;
  }
  return (
    <>
      {vents.map((vent) => (
        <Vent key={vent.refID} {...vent} />
      ))}
    </>
  );
};

//  Scrubbers
// --------------------------------------------------------

const AirAlarmControlScrubbers = (props, context) => {
  const { data } = useBackend<AirAlarmData>(context);
  const { scrubbers } = data;
  if (!scrubbers || scrubbers.length === 0) {
    return <span>Nothing to show</span>;
  }
  return (
    <>
      {scrubbers.map((scrubber) => (
        <Scrubber key={scrubber.refID} {...scrubber} />
      ))}
    </>
  );
};

//  Modes
// --------------------------------------------------------

const AirAlarmControlModes = (props, context) => {
  const { act, data } = useBackend<AirAlarmData>(context);
  const { modes, selectedModePath } = data;
  if (!modes || modes.length === 0) {
    return <span>Nothing to show</span>;
  }
  return (
    <>
      {modes.map((mode) => (
        <Fragment key={mode.path}>
          <Button
            icon={
              mode.path === selectedModePath ? 'check-square-o' : 'square-o'
            }
            color={
              mode.path === selectedModePath && (mode.danger ? 'red' : 'green')
            }
            content={mode.name + ' - ' + mode.desc}
            onClick={() => act('mode', { mode: mode.path })}
          />
          <Box mt={1} />
        </Fragment>
      ))}
    </>
  );
};

//  Thresholds
// --------------------------------------------------------

type EditingModalProps = {
  id: string;
  name: string;
  type: number;
  typeVar: string;
  typeName: string;
  unit: string;
  oldValue: number;
  finish: () => void;
};

const EditingModal = (props: EditingModalProps, context) => {
  const { act, data } = useBackend<AirAlarmData>(context);
  const { id, name, type, typeVar, typeName, unit, oldValue, finish } = props;
  return (
    <Modal>
      <Section
        title={'Threshold Value Editor'}
        buttons={<Button onClick={() => finish()} icon="times" color="red" />}>
        <Box mb={1.5}>
          {`Editing the ${typeName.toLowerCase()} value for ${name.toLowerCase()}...`}
        </Box>
        {oldValue === -1 ? (
          <Button
            onClick={() =>
              act('set_threshold', {
                threshold: id,
                threshold_type: type,
                value: 0,
              })
            }>
            {'Enable'}
          </Button>
        ) : (
          <>
            <NumberInput
              onChange={(e, value) =>
                act('set_threshold', {
                  threshold: id,
                  threshold_type: type,
                  value: value,
                })
              }
              unit={unit}
              value={oldValue}
              minValue={0}
              maxValue={100000}
              step={10}
            />
            <Button
              onClick={() =>
                act('set_threshold', {
                  threshold: id,
                  threshold_type: type,
                  value: -1,
                })
              }>
              {'Disable'}
            </Button>
          </>
        )}
      </Section>
    </Modal>
  );
};

const AirAlarmControlThresholds = (props, context) => {
  const { act, data } = useBackend<AirAlarmData>(context);
  const [activeModal, setActiveModal] = useLocalState<Omit<
    EditingModalProps,
    'oldValue'
  > | null>(context, 'tlvModal', null);
  const { tlvSettings, thresholdTypeMap } = data;
  return (
    <>
      <Table>
        <Table.Row>
          <Table.Cell bold>Threshold</Table.Cell>
          <Table.Cell bold color="bad">
            Minimum Hazard
          </Table.Cell>
          <Table.Cell bold color="average">
            Minimum Warning
          </Table.Cell>
          <Table.Cell bold color="average">
            Maximum Warning
          </Table.Cell>
          <Table.Cell bold color="bad">
            Maximum Hazard
          </Table.Cell>
          <Table.Cell bold>Actions</Table.Cell>
        </Table.Row>
        {tlvSettings.map((tlv) => (
          <Table.Row key={tlv.name}>
            <Table.Cell>{tlv.name}</Table.Cell>
            <Table.Cell>
              <Button
                fluid
                onClick={() =>
                  setActiveModal({
                    id: tlv.id,
                    name: tlv.name,
                    type: thresholdTypeMap['hazard_min'],
                    typeVar: 'hazard_min',
                    typeName: 'Minimum Hazard',
                    unit: tlv.unit,
                    finish: () => setActiveModal(null),
                  })
                }>
                {tlv.hazard_min === -1
                  ? 'Disabled'
                  : tlv.hazard_min + ' ' + tlv.unit}
              </Button>
            </Table.Cell>
            <Table.Cell>
              <Button
                fluid
                onClick={() =>
                  setActiveModal({
                    id: tlv.id,
                    name: tlv.name,
                    type: thresholdTypeMap['warning_min'],
                    typeVar: 'warning_min',
                    typeName: 'Minimum Warning',
                    unit: tlv.unit,
                    finish: () => setActiveModal(null),
                  })
                }>
                {tlv.warning_min === -1
                  ? 'Disabled'
                  : tlv.warning_min + ' ' + tlv.unit}
              </Button>
            </Table.Cell>
            <Table.Cell>
              <Button
                fluid
                onClick={() =>
                  setActiveModal({
                    id: tlv.id,
                    name: tlv.name,
                    type: thresholdTypeMap['warning_max'],
                    typeVar: 'warning_max',
                    typeName: 'Maximum Warning',
                    unit: tlv.unit,
                    finish: () => setActiveModal(null),
                  })
                }>
                {tlv.warning_max === -1
                  ? 'Disabled'
                  : tlv.warning_max + ' ' + tlv.unit}
              </Button>
            </Table.Cell>
            <Table.Cell>
              <Button
                fluid
                onClick={() =>
                  setActiveModal({
                    id: tlv.id,
                    name: tlv.name,
                    type: thresholdTypeMap['hazard_max'],
                    typeVar: 'hazard_max',
                    typeName: 'Maximum Hazard',
                    unit: tlv.unit,
                    finish: () => setActiveModal(null),
                  })
                }>
                {tlv.hazard_max === -1
                  ? 'Disabled'
                  : tlv.hazard_max + ' ' + tlv.unit}
              </Button>
            </Table.Cell>
            <Table.Cell>
              <>
                <Button
                  color="green"
                  icon="sync"
                  onClick={() =>
                    act('reset_threshold', {
                      threshold: tlv.id,
                      threshold_type: thresholdTypeMap['all'],
                    })
                  }
                />
                <Button
                  color="red"
                  icon="times"
                  onClick={() =>
                    act('set_threshold', {
                      threshold: tlv.id,
                      threshold_type: thresholdTypeMap['all'],
                      value: -1,
                    })
                  }
                />
              </>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
      {activeModal && (
        <EditingModal
          oldValue={
            (tlvSettings.find((tlv) => tlv.id === activeModal.id) || {})[
              activeModal.typeVar
            ]
          }
          {...activeModal}
        />
      )}
    </>
  );
};
