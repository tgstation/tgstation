import { useBackend } from 'tgui/backend';
import { Box, Flex, Icon, Section, Stack, Tooltip } from 'tgui-core/components';

import type { HypertorusFuel } from '.';
import { to_exponential_if_big } from './helpers';

type Data = {
  base_max_temperature: number;
  internal_coolant_temperature_archived: number;
  internal_coolant_temperature: number;
  internal_fusion_temperature_archived: number;
  internal_fusion_temperature: number;
  internal_output_temperature_archived: number;
  internal_output_temperature: number;
  moderator_internal_temperature_archived: number;
  moderator_internal_temperature: number;
  power_level: number;
  selectable_fuel: HypertorusFuel[];
  selected: string;
  temperature_period: number;
};

/*
 * Shows a set of temperatures on a unified temperature scale.
 *
 * Axis labels draw attention to points of interest.
 *
 * This is a good candidate for refactoring into something reusable, or
 * maybe extending ProgressBar.
 */

/**
 * Note: This must be kept in sync with Hypertorus.scss
 */
const height = 200;

const VerticalBar = (props) => {
  const { color, value, progressHeight } = props;
  const y = height - progressHeight;

  return (
    <div className="hypertorus-temperatures__vertical-bar">
      {!!value && <Box backgroundColor={color} top={`${y}px`} />}
    </div>
  );
};

const BarLabel = (props) => {
  const { label, delta, value } = props;

  return (
    <>
      <Box align="center">{label}</Box>
      {value > 0 ? (
        <>
          <Box align="center">{`${to_exponential_if_big(value)} K`}</Box>
          <Box align="center">
            {delta === 0
              ? '-'
              : `${delta < 0 ? '' : '+'}${to_exponential_if_big(delta)} K/s`}
          </Box>
        </>
      ) : (
        <>
          <Box align="center" color="red">
            Empty
          </Box>
          <Box className="hypertorus__unselectable">&nbsp;</Box>
        </>
      )}
    </>
  );
};

export const HypertorusTemperatures = (props) => {
  const { data } = useBackend<Data>();

  const {
    base_max_temperature,
    internal_coolant_temperature_archived,
    internal_coolant_temperature,
    internal_fusion_temperature_archived,
    internal_fusion_temperature,
    internal_output_temperature_archived,
    internal_output_temperature,
    moderator_internal_temperature_archived,
    moderator_internal_temperature,
    power_level,
    selectable_fuel = [],
    selected,
    temperature_period,
  } = data;

  const internal_fusion_temperature_delta =
    (internal_fusion_temperature - internal_fusion_temperature_archived) /
    temperature_period;
  const internal_output_temperature_delta =
    (internal_output_temperature - internal_output_temperature_archived) /
    temperature_period;
  const internal_coolant_temperature_delta =
    (internal_coolant_temperature - internal_coolant_temperature_archived) /
    temperature_period;
  const moderator_internal_temperature_delta =
    (moderator_internal_temperature - moderator_internal_temperature_archived) /
    temperature_period;

  const selected_fuel = selectable_fuel.filter((d) => d.id === selected)[0];

  let prev_power_level_temperature = 10 ** (1 + power_level);
  let next_power_level_temperature = 10 ** (2 + power_level);

  if (power_level === 0) {
    prev_power_level_temperature = 0;
    next_power_level_temperature = 500;
  } else if (power_level === 1) {
    prev_power_level_temperature = 500;
  } else if (power_level === 6) {
    next_power_level_temperature =
      base_max_temperature * (selected_fuel?.temperature_multiplier ?? 1);
  }

  const temperatures = [
    prev_power_level_temperature,
    next_power_level_temperature,
    ...[
      internal_fusion_temperature,
      moderator_internal_temperature,
      internal_output_temperature,
      internal_coolant_temperature,
    ].filter((d) => d),
  ].map((d) => d);

  const maxTemperature = Math.max(...temperatures);
  const minTemperature = Math.max(
    2.73,
    Math.min(20, ...temperatures.filter((d) => d > 0)),
  );

  if (power_level === 6) {
    next_power_level_temperature = 0;
  }

  const value_to_y = (value, baseTemp = minTemperature, fromBottom = false) => {
    const ratio =
      (Math.log10(value) - Math.log10(baseTemp)) /
      (Math.log10(maxTemperature) - Math.log10(minTemperature));
    return height * (fromBottom ? 1 - ratio : ratio);
  };

  const TemperatureLabel = (props) => {
    const { icon, force, tooltip, value } = props;
    const y = value_to_y(value);
    const label = (
      <Box className="hypertorus-temperatures__y-axis-label">
        {icon && (
          <Icon
            className="hypertorus-temperatures__y-axis-label-icon"
            name={icon}
          />
        )}
        {`${to_exponential_if_big(value)} K`}
      </Box>
    );
    return (
      (!!value || force) && (
        <Box
          className="hypertorus-temperatures__y-axis-tick-anchor"
          top={`${height - y}px`}
        >
          <Box className="hypertorus-temperatures__y-axis-tick" />
          {tooltip ? <Tooltip content={tooltip}>{label}</Tooltip> : label}
        </Box>
      )
    );
  };

  const TemperatureBar = (props) => {
    const { label, delta, value, children, ...rest } = props;
    const y = value_to_y(value);
    return (
      <Flex.Item mx={1}>
        <Stack vertical align="center">
          <Stack.Item>
            <VerticalBar progressHeight={y} value={value} {...rest}>
              {children}
            </VerticalBar>
          </Stack.Item>
          <Stack.Item color="label">
            <BarLabel delta={delta} label={label} value={value} />
          </Stack.Item>
        </Stack>
      </Flex.Item>
    );
  };

  // Make sure that our labels are legible before displaying them.
  // If two axis labels are too close to one another, don't show them.
  const clutter_threshold = 20;
  const label_legible = (l, r) =>
    Math.abs(value_to_y(l) - value_to_y(r)) > clutter_threshold;

  const show_min =
    label_legible(prev_power_level_temperature, minTemperature) ||
    power_level === 0;
  const show_max = label_legible(next_power_level_temperature, maxTemperature);

  return (
    <Section title="Gas Monitoring">
      <Box className="hypertorus-temperatures__container">
        <Box className="hypertorus-temperatures__y-axis-marks">
          {show_min && (
            <TemperatureLabel key="min_temp" value={minTemperature} force />
          )}
          <TemperatureLabel
            key="prev_fusion_temp"
            icon="chevron-down"
            tooltip="Previous Fusion Level"
            value={prev_power_level_temperature}
          />
          <TemperatureLabel
            key="next_fusion_temp"
            icon="chevron-up"
            tooltip="Next Fusion Level"
            value={next_power_level_temperature}
          />
          {show_max && (
            <TemperatureLabel key="max_temp" value={maxTemperature} />
          )}
        </Box>
        <Box className="hypertorus-temperatures__y-axis">
          <Box className="hypertorus-temperatures__x-axis" />
        </Box>
        <Flex
          overflowY="hidden"
          className="hypertorus-temperatures__chart"
          justify="space-around"
        >
          <TemperatureBar
            label="Fusion"
            value={internal_fusion_temperature}
            delta={internal_fusion_temperature_delta}
            color="#f2711c"
          />
          <TemperatureBar
            label="Moderator"
            value={moderator_internal_temperature}
            delta={moderator_internal_temperature_delta}
            color="#e03997"
          />
          <TemperatureBar
            label="Coolant"
            value={internal_coolant_temperature}
            delta={internal_coolant_temperature_delta}
            color="aliceblue"
          />
          <TemperatureBar
            label="Output"
            value={internal_output_temperature}
            delta={internal_output_temperature_delta}
            color="#20b142"
          />
        </Flex>
      </Box>
    </Section>
  );
};
