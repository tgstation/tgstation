import { act } from 'byond';
import { Button } from '../components';
import { createLogger } from '../logging';

const logger = createLogger('AirAlarm');

export const AirAlarm = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const locked = data.locked && !data.siliconUser;

  if (config.screen === 'vents') {
    return <Vents state={state} />
  }
  if (config.screen === 'scrubbers') {
    return <Scrubbers state={state} scrubbers={data.scrubbers} />
  }
  if (config.screen === 'modes') {
    return <Modes state={state} />
  }
  if (config.screen === 'thresholds') {
    return <Thresholds state={state} />
  }

  return (
    <div>
      <h2>Air Controls</h2>
      <Button
        icon={data.atmos_alarm
          ? 'exclamation-triangle'
          : 'exclamation'}
        content="Area Atmosphere Alarm"
        onClick={() => act(ref,
          data.atmos_alarm ? 'reset' : 'alarm')} />
      <Button
        icon={data.mode === 3
          ? 'exclamation-triangle'
          : 'exclamation'}
        content="Panic Siphon"
        onClick={() => act(ref, 'mode', {
          mode: data.mode === 3 ? 1 : 3,
        })} />
      <br /><br />
      <Button fluid
        icon="sign-out"
        content="Vent Controls"
        onClick={() => act(ref, 'tgui:view', {
          screen: 'vents',
        })} />
      <Button fluid
        icon="filter"
        content="Scrubber Controls"
        onClick={() => act(ref, 'tgui:view', {
          screen: 'scrubbers',
        })} />
      <Button fluid
        icon="cog"
        content="Operating Mode"
        onClick={() => act(ref, 'tgui:view', {
          screen: 'modes',
        })} />
      <Button fluid
        icon="bar-chart"
        content="Alarm Thresholds"
        onClick={() => act(ref, 'tgui:view', {
          screen: 'thresholds',
        })} />
    </div>
  );
};

const Vents = props => 'TODO';
const Modes = props => 'TODO';
const Thresholds = props => 'TODO';

/**
 * TOOD: Move to components
 */
const Section = props => {
  const { label, children } = props;
  return (
    <div>
      <span>{label}:</span>
      {children}
    </div>
  );
};

const Scrubbers = props => {
  const { state, scrubbers } = props;
  if (!scrubbers) {
    return 'Nothing to show';
  }
  return scrubbers.map(scrubber => (
    <Scrubber key={scrubber.id_tag}
      state={state}
      {...scrubber} />
  ));
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
    <div>
      <h3>{long_name}</h3>
      <Section label="Power">
        <Button
          icon={power ? 'power-off' : 'close'}
          content={power ? 'On' : 'Off'}
          selected={power}
          onClick={() => act(ref, 'power', {
            id_tag,
            val: Number(!power),
          })} />
      </Section>
      <Section label="Mode">
        <Button
          icon={scrubbing ? 'filter' : 'sign-in'}
          color={scrubbing || 'danger'}
          content={scrubbing ? 'Scrubbing' : 'Siphoning'}
          onClick={() => act(ref, 'scrubbing', {
            id_tag,
            val: Number(!scrubbing),
          })} />
      </Section>
      <Section label="Range">
        <Button
          icon={widenet ? 'expand' : 'compress'}
          selected={widenet}
          content={widenet ? 'Expanded' : 'Normal'}
          onClick={() => act(ref, 'widenet', {
            id_tag,
            val: Number(!widenet),
          })} />
      </Section>
      <Section label="Filters">
        {filter_types.map(filter => (
          <Button key={filter.gas_id}
            icon={filter.enabled ? 'check-square-o' : 'square-o'}
            content={filter.gas_name}
            selected={filter.enabled}
            onClick={() => act(ref, 'toggle_filter', {
              id_tag,
              val: filter.gas_id,
            })} />
        ))}
      </Section>
    </div>
  )
}
