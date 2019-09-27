import { act } from 'byond';
import { Fragment } from 'inferno';
import { decodeHtmlEntities } from 'string-tools';
import { Box, Button, LabeledList, NoticeBox, Section } from '../components';
import { Flex } from '../components/Flex';
import { createLogger } from '../logging';
import { fixed } from '../math';

const logger = createLogger('AirAlarm');

export const AirAlarm = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const locked = data.locked && !data.siliconUser;
  return (
    <Fragment>
      <NoticeBox>
        <Flex align="center">
          <Flex.Item>
            {data.siliconUser
              && (data.locked
                && 'Lock status: engaged.'
                || 'Lock status: disengaged.')
              || (data.locked
                && 'Swipe an ID card to unlock this interface.'
                || 'Swipe an ID card to lock this interface.')}
          </Flex.Item>
          <Flex.Item grow={1} />
          <Flex.Item>
            {!!data.siliconUser && (
              <Button
                content={data.locked ? 'Unlock' : 'Lock'}
                onClick={() => act(ref, 'lock')} />
            )}
          </Flex.Item>
        </Flex>
      </NoticeBox>
      <AirAlarmStatus state={state} />
      {!locked && (
        <AirAlarmControl state={state} />
      )}
    </Fragment>
  );
};

const AirAlarmStatus = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const entries = data.environment_data || [];
  const dangerMap = {
    0: {
      color: 'good',
      localStatusText: 'Danger (Internals Required)',
    },
    1: {
      color: 'average',
      localStatusText: 'Caution',
    },
    2: {
      color: 'bad',
      localStatusText: 'Optimal',
    },
  };
  const localStatus = dangerMap[data.danger_level] || dangerMap[0];
  return (
    <Section title="Air Status">
      <LabeledList>
        {entries.length > 0 && (
          <Fragment>
            {entries.map(entry => {
              const status = dangerMap[entry.danger_level] || dangerMap[0];
              return (
                <LabeledList.Item
                  label={entry.name}
                  color={status.color}>
                  {fixed(entry.value, 2)}{entry.unit}
                </LabeledList.Item>
              );
            })}
            <LabeledList.Item
              label="Local status"
              color={localStatus.color}>
              {localStatus.localStatusText}
            </LabeledList.Item>
            <LabeledList.Item
              label="Area status"
              color={data.atmos_alarm || data.fire_alarm ? 'bad' : 'good'}>
              {data.atmos_alarm && 'Atmosphere Alarm'
                || data.fire_alarm && 'Fire Alarm'
                || 'Nominal'}
            </LabeledList.Item>
          </Fragment>
        ) || (
          <LabeledList.Item
            label="Warning"
            color="bad">
            Cannot obtain air sample for analysis.
          </LabeledList.Item>
        )}
        {!!data.emagged && (
          <LabeledList.Item
            label="Warning"
            color="bad">
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

const AirAlarmControl = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const route = AIR_ALARM_ROUTES[config.screen] || AIR_ALARM_ROUTES.home;
  const Component = route.component();
  return (
    <Section
      title={route.title}
      buttons={config.screen !== 'home' && (
        <Button
          icon="arrow-left"
          content="Back"
          onClick={() => act(ref, 'tgui:view', {
            screen: 'home',
          })} />
      )}>
      <Component state={state} />
    </Section>
  );
};


//  Home screen
// --------------------------------------------------------

const AirAlarmControlHome = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Fragment>
      <Button
        icon={data.atmos_alarm
          ? 'exclamation-triangle'
          : 'exclamation'}
        color={data.atmos_alarm && 'caution'}
        content="Area Atmosphere Alarm"
        onClick={() => act(ref,
          data.atmos_alarm ? 'reset' : 'alarm')} />
      <Box mt={1} />
      <Button
        icon={data.mode === 3
          ? 'exclamation-triangle'
          : 'exclamation'}
        color={data.mode === 3 && 'danger'}
        content="Panic Siphon"
        onClick={() => act(ref, 'mode', {
          mode: data.mode === 3 ? 1 : 3,
        })} />
      <Box mt={2} />
      <Button
        icon="sign-out"
        content="Vent Controls"
        onClick={() => act(ref, 'tgui:view', {
          screen: 'vents',
        })} />
      <Box mt={1} />
      <Button
        icon="filter"
        content="Scrubber Controls"
        onClick={() => act(ref, 'tgui:view', {
          screen: 'scrubbers',
        })} />
      <Box mt={1} />
      <Button
        icon="cog"
        content="Operating Mode"
        onClick={() => act(ref, 'tgui:view', {
          screen: 'modes',
        })} />
      <Box mt={1} />
      <Button
        icon="bar-chart"
        content="Alarm Thresholds"
        onClick={() => act(ref, 'tgui:view', {
          screen: 'thresholds',
        })} />
    </Fragment>
  );
};


//  Vents
// --------------------------------------------------------

const AirAlarmControlVents = props => {
  const { state } = props;
  const { vents } = state.data;
  if (!vents || vents.length === 0) {
    return 'Nothing to show';
  }
  return vents.map(vent => (
    <Vent key={vent.id_tag}
      state={state}
      {...vent} />
  ));
};

const Vent = props => {
  const {
    state,
    id_tag,
    long_name,
    power,
    checks,
    excheck,
    incheck,
    direction,
    external,
    internal,
    extdefault,
    intdefault,
  } = props;
  const { ref } = state.config;
  return (
    <Section
      level={2}
      title={decodeHtmlEntities(long_name)}
      buttons={(
        <Button
          icon={power ? 'power-off' : 'close'}
          selected={power}
          content={power ? 'On' : 'Off'}
          onClick={() => act(ref, 'power', {
            id_tag,
            val: Number(!power),
          })} />
      )}>
      <LabeledList>
        <LabeledList.Item label="Mode">
          {direction === 'release' ? 'Pressurizing' : 'Releasing'}
        </LabeledList.Item>
        <LabeledList.Item label="Pressure Regulator">
          <Button
            icon="sign-in"
            content="Internal"
            selected={incheck}
            onClick={() => act(ref, 'incheck', {
              id_tag,
              val: checks,
            })} />
          <Button
            icon="sign-out"
            content="External"
            selected={excheck}
            onClick={() => act(ref, 'excheck', {
              id_tag,
              val: checks,
            })} />
        </LabeledList.Item>
        {!!incheck && (
          <LabeledList.Item label="Internal Target">
            <Button
              icon="pencil"
              content={fixed(internal)}
              onClick={() => act(ref, 'set_internal_pressure', {
                id_tag,
              })} />
            <Button
              icon="refresh"
              disabled={intdefault}
              content="Reset"
              onClick={() => act(ref, 'reset_internal_pressure', {
                id_tag,
              })} />
          </LabeledList.Item>
        )}
        {!!excheck && (
          <LabeledList.Item label="External Target">
            <Button
              icon="pencil"
              content={fixed(external)}
              onClick={() => act(ref, 'set_external_pressure', {
                id_tag,
              })} />
            <Button
              icon="refresh"
              disabled={extdefault}
              content="Reset"
              onClick={() => act(ref, 'reset_external_pressure', {
                id_tag,
              })} />
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};


//  Scrubbers
// --------------------------------------------------------

const AirAlarmControlScrubbers = props => {
  const { state } = props;
  const { scrubbers } = state.data;
  if (!scrubbers || scrubbers.length === 0) {
    return 'Nothing to show';
  }
  return scrubbers.map(scrubber => (
    <Scrubber key={scrubber.id_tag}
      state={state}
      {...scrubber} />
  ));
};

const GAS_NOTATION_MAPPING = {
  o2: 'O₂',
  n2: 'N₂',
  co2: 'CO₂',
  water_vapor: 'H₂O',
  n2o: 'N₂O',
  no2: 'NO₂',
  bz: 'BZ',
};

const Scrubber = props => {
  const {
    state,
    long_name,
    power,
    scrubbing,
    id_tag,
    widenet,
    filter_types,
  } = props;
  const { ref } = state.config;
  return (
    <Section
      level={2}
      title={decodeHtmlEntities(long_name)}
      buttons={(
        <Button
          icon={power ? 'power-off' : 'close'}
          content={power ? 'On' : 'Off'}
          selected={power}
          onClick={() => act(ref, 'power', {
            id_tag,
            val: Number(!power),
          })} />
      )}>
      <LabeledList>
        <LabeledList.Item label="Mode">
          <Button
            icon={scrubbing ? 'filter' : 'sign-in'}
            color={scrubbing || 'danger'}
            content={scrubbing ? 'Scrubbing' : 'Siphoning'}
            onClick={() => act(ref, 'scrubbing', {
              id_tag,
              val: Number(!scrubbing),
            })} />
          <Button
            icon={widenet ? 'expand' : 'compress'}
            selected={widenet}
            content={widenet ? 'Expanded range' : 'Normal range'}
            onClick={() => act(ref, 'widenet', {
              id_tag,
              val: Number(!widenet),
            })} />
        </LabeledList.Item>
        <LabeledList.Item label="Filters">
          {scrubbing
            && filter_types.map(filter => (
              <Button key={filter.gas_id}
                icon={filter.enabled ? 'check-square-o' : 'square-o'}
                content={GAS_NOTATION_MAPPING[filter.gas_id]
                  || filter.gas_name}
                title={filter.gas_name}
                selected={filter.enabled}
                onClick={() => act(ref, 'toggle_filter', {
                  id_tag,
                  val: filter.gas_id,
                })} />
            ))
            || 'N/A'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};


//  Modes
// --------------------------------------------------------

const AirAlarmControlModes = props => {
  const { state } = props;
  const { ref } = state.config;
  const { modes } = state.data;
  if (!modes || modes.length === 0) {
    return 'Nothing to show';
  }
  return modes.map(mode => (
    <Fragment>
      <Button
        icon={mode.selected ? 'check-square-o' : 'square-o'}
        selected={mode.selected}
        color={mode.selected && mode.danger && 'danger'}
        content={mode.name}
        onClick={() => act(ref, 'mode', { mode: mode.mode })} />
      <Box mt={1} />
    </Fragment>
  ));
};


//  Thresholds
// --------------------------------------------------------

const AirAlarmControlThresholds = props => {
  const { state } = props;
  const { ref } = state.config;
  const { thresholds } = state.data;
  return (
    <table className="LabeledList"
      style={{ width: '100%' }}>
      <thead>
        <tr>
          <td />
          <td className="color-bad">min2</td>
          <td className="color-average">min1</td>
          <td className="color-average">max1</td>
          <td className="color-bad">max2</td>
        </tr>
      </thead>
      <tbody>
        {thresholds.map(threshold => (
          <tr>
            <td className="LabeledList__label">{threshold.name}</td>
            {threshold.settings.map(setting => (
              <td>
                <Button
                  content={fixed(setting.selected, 2)}
                  onClick={() => act(ref, 'threshold', {
                    env: setting.env,
                    var: setting.val,
                  })} />
              </td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
};
