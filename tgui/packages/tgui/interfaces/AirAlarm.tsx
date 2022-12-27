import { BooleanLike } from 'common/react';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';
import { Scrubber, ScrubberProps, Vent, VentProps } from './common/AtmosControls';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

type AirAlarmData = {
  locked: BooleanLike;
  siliconUser: BooleanLike;
  emagged: BooleanLike;
  dangerLevel: 0 | 1 | 2;
  atmosAlarm: any; // fix this
  fireAlarm: BooleanLike;
  envData: {
    name: string;
    value: string; // preformatted in backend, shorter code that way.
    danger: 0 | 1 | 2;
  }[];
  tlvSettings: {
    name: string;
    unit: string;
    warning_min: number;
    hazard_min: number;
    warning_max: number;
    hazard_max: number;
  }[];
  vents: VentProps[];
  scrubbers: ScrubberProps[];
  mode: 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9;
  modes: {
    name: string;
    mode: 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9;
    selected: BooleanLike;
    danger: BooleanLike;
  }[];
};

export const AirAlarm = (props, context) => {
  const { act, data } = useBackend<AirAlarmData>(context);
  const locked = data.locked && !data.siliconUser;
  return (
    <Window width={440} height={650}>
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
  const localStatus = dangerMap[data.dangerLevel] || dangerMap[0];
  return (
    <Section title="Air Status">
      <LabeledList>
        {(data.envData.length > 0 && (
          <>
            {data.envData.map((entry) => {
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
};

const AirAlarmControl = (props, context) => {
  const [screen, setScreen] = useLocalState(context, 'screen', 'home');
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
  const [screen, setScreen] = useLocalState(context, 'screen', 'home');
  const { mode, atmosAlarm } = data;
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
        icon={mode === 3 ? 'exclamation-triangle' : 'exclamation'}
        color={mode === 3 && 'danger'}
        content="Panic Siphon"
        onClick={() =>
          act('mode', {
            mode: mode === 3 ? 1 : 3,
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
    return 'Nothing to show';
  }
  return vents.map((vent) => <Vent key={vent.refID} {...vent} />);
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
    <Scrubber key={scrubber.refID} {...scrubber} />
  ));
};

//  Modes
// --------------------------------------------------------

const AirAlarmControlModes = (props, context) => {
  const { act, data } = useBackend<AirAlarmData>(context);
  const { modes } = data;
  if (!modes || modes.length === 0) {
    return 'Nothing to show';
  }
  return modes.map((mode) => (
    <Fragment key={mode.mode}>
      <Button
        icon={mode.selected ? 'check-square-o' : 'square-o'}
        selected={mode.selected}
        color={mode.selected && mode.danger && 'danger'}
        content={mode.name}
        onClick={() => act('mode', { mode: mode.mode })}
      />
      <Box mt={1} />
    </Fragment>
  ));
};

//  Thresholds
// --------------------------------------------------------

const AirAlarmControlThresholds = (props, context) => {
  const { act, data } = useBackend<AirAlarmData>(context);
  const { tlvSettings } = data;
  return (
    <table className="LabeledList" style={{ width: '100%' }}>
      <thead>
        <tr>
          <td />
          <td className="color-bad">hazard_min</td>
          <td className="color-average">warning_min</td>
          <td className="color-average">warning_max</td>
          <td className="color-bad">hazard_max</td>
        </tr>
      </thead>
      <tbody>
        {tlvSettings.map((threshold) => (
          <tr key={threshold.name}>
            <td className="LabeledList__label">{threshold.name}</td>
            <td className="LabeledList__label">
              {threshold.warning_min + threshold.unit}
            </td>
            <td className="LabeledList__label">
              {threshold.hazard_min + threshold.unit}
            </td>
            <td className="LabeledList__label">
              {threshold.warning_max + threshold.unit}
            </td>
            <td className="LabeledList__label">
              {threshold.hazard_max + threshold.unit}
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
};
