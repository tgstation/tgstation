import { LabeledControls, RoundGauge, Section } from '../../components';
import { formatSiUnit } from '../../format';
import { to_exponential_if_big }from './helpers';

export const HypertorusParameters = props => {
  const {
    energyLevel: energy_level,
    realHeatOutput: heat_output,
    realHeatLimiterModifier: heat_limiter_modifier,
    rawHeatLimiterModifier: raw_heat_limiter_modifier,
    powerLevel: power_level,
    ironContent: iron_content,
    integrity,
  } = props;

  // Heat change is an interesting control, and there's a lot we're trying
  // to indicate in a fairly small space.

  // The scale must be logarithmic, simply due to the units involved.
  const log10scale = value => {
    const scale = Math.max(0,Math.log10(Math.abs(value)));
    return (value < 0 ? -1 : 1) * scale;
  };

  // First, we want to indicate the potential range from the power level.
  // This forms the scale that our gauge uses.
  //
  // max is 10 * 10**power_level * heating_conductor / 100
  // min is 1/100th of max, but expressly leave this 2 off the real min to show asymmetry
  const max_power_level_heat_change = 10 * 10 ** power_level * 5;
  const min_power_level_heat_change = -max_power_level_heat_change;

  // Next, we want to indicate how much of this range is available, based
  // on our heat limiter modifier.
  // This forms the markers on the gauge.
  const max_capped_heat_change = raw_heat_limiter_modifier;
  const min_capped_heat_change = -raw_heat_limiter_modifier / 100;

  // Force each band to be of minimum size for visibility
  const visible_epsilon = 0.2;

  const log_max_capped_heat_change = Math.max( 2 * visible_epsilon, log10scale(max_capped_heat_change));
  const log_min_capped_heat_change = Math.min(-2 * visible_epsilon, log10scale(min_capped_heat_change));

  const log_heat_midpoint = Math.max( visible_epsilon, log_max_capped_heat_change - 1);
  const log_cool_midpoint = Math.min(-visible_epsilon, log_min_capped_heat_change + 1);

  const heat_change_gauge_ranges = {
    //pink: [log10scale(-max_power_level_heat_change), log_min_capped_heat_change],
    blue: [log_min_capped_heat_change, log_cool_midpoint],
    grey: [log_cool_midpoint, log_heat_midpoint],
    orange: [log_heat_midpoint, log_max_capped_heat_change],
    //red: [log_max_capped_heat_change, log10scale(max_power_level_heat_change)]
  };

  // Finally, we want to indicate how much of the potential heat change is
  // being achieved.
  // This will form the needle on the gauge. We pass this in to the
  // heat RoundGauge directly.

  const heat_change_value = log10scale(heat_output);

  // Visually, we place a large Fusion Level Gauge in the center.
  // Immediately adjacent are Gauges that track an important intermediate
  // parameter, and on the sides are Gauges that track the result that people
  // are most likely to ultimately care about relating to each value.

  const energy_minimum_exponent = 12;
  const energy_minimum_suffix = energy_minimum_exponent / 3;

  return (
    <Section title="Reactor Parameters">
      <LabeledControls justify="space-around">
        <LabeledControls.Item label="Reactor Integrity">
          <RoundGauge
            size={1.75}
            value={integrity}
            minValue={0}
            maxValue={100}
            alertBefore={95}
            format={v=>`${Math.round(v)}%`}
            ranges={{
              good: [90, 100],
              average: [50, 90],
              bad: [0, 50],
            }} />
        </LabeledControls.Item>
        <LabeledControls.Item label="Iron Content">
          <RoundGauge
            size={1.75}
            value={iron_content}
            minValue={0}
            maxValue={1}
            alertAfter={.25}
            format={v=>`${Math.round(v*100)}%`}
            ranges={{
              good: [0, .1],
              average: [.1, .36],
              bad: [.36, 1],
            }} />
        </LabeledControls.Item>
        <LabeledControls.Item label="Fusion Level">
          <RoundGauge
            size={2.5}
            minValue={0}
            maxValue={6}
            value={power_level}
            alertAfter={4.5}
            ranges={{
              grey: [0, 1],
              good: [1, 3.5],
              average: [3.5, 4.5],
              bad: [4.5, 6],
            }} />
        </LabeledControls.Item>
        <LabeledControls.Item label="Energy">
          <RoundGauge
            size={1.75}
            value={Math.max(0,Math.log10(energy_level))}
            minValue={energy_minimum_exponent}
            maxValue={30}
            format={v=>formatSiUnit(10**v, energy_minimum_suffix, 'J')}
            ranges={{
              black: [energy_minimum_exponent, 15],
              grey: [15, 18], // Anything under 1EJ is pretty mediocre
              yellow: [18, 24],
              orange: [24, 30],
            }} />
        </LabeledControls.Item>
        <LabeledControls.Item label="Heat Change/Cap">
          <RoundGauge
            size={1.75}
            value={heat_change_value}
            minValue={log10scale(min_power_level_heat_change)}
            maxValue={log10scale(max_power_level_heat_change)}
            format={()=>`${to_exponential_if_big(heat_output)} K/${to_exponential_if_big(heat_limiter_modifier)} K`}
            ranges={heat_change_gauge_ranges} />
        </LabeledControls.Item>
      </LabeledControls>
    </Section>
  );
};
