import { useBackend } from '../../backend';
import { Box, Icon, Flex, Section, Stack, Tooltip } from '../../components';

import { to_exponential_if_big } from './helpers';

/*
 * Shows a set of temperatures on a unified temperature scale.
 *
 * Axis labels draw attention to points of interest.
 *
 * This is a good candidate for refactoring into something reusable, or
 * maybe extending ProgressBar.
 */

const VerticalBar = props => {
  const {
    borderRadius = "0.16em",
    color,
    height,
    value,
    progressHeight
  } = props;
  let y = height - progressHeight;
  return (
    <div
      style={{
        display: 'absolute',
        position: 'relative',
        height: `${height}px`,
        width: '17px',
        bottom: '0',
      }}
    >
      {
        !!value && (
          <div style={{
            'background-color': color,
            position: 'absolute',
            left: '-0.5px',
            right: '-0.5px',
            bottom: '0px',
            top: `${y}px`,
            "border-radius": borderRadius,
          }} />
        )
      }
    </div>);
};

export const HypertorusTemperatures = (props, context) => {
  const { data } = useBackend(context);

  const {
    power_level,
    base_max_temperature,
    internal_fusion_temperature,
    moderator_internal_temperature,
    internal_output_temperature,
    internal_coolant_temperature,
    temperature_period,
  } = data;

  const internal_fusion_temperature_delta = (internal_fusion_temperature
    - data.internal_fusion_temperature_archived) / temperature_period;
  const internal_output_temperature_delta = (internal_output_temperature
    - data.internal_output_temperature_archived) / temperature_period;
  const internal_coolant_temperature_delta = (internal_coolant_temperature
    - data.internal_coolant_temperature_archived) / temperature_period;
  const moderator_internal_temperature_delta = (moderator_internal_temperature
    - data.moderator_internal_temperature_archived) / temperature_period;

  const selected_fuel = (data.selectable_fuel || []).filter(
    d => d.id === data.selected
  )[0];

  let prev_power_level_temperature = 10 ** (1+power_level);
  let next_power_level_temperature = 10 ** (2+power_level);

  if (power_level === 0) {
    prev_power_level_temperature = 0;
    next_power_level_temperature = 500;
  } else if (power_level === 1) {
    prev_power_level_temperature = 500;
  } else if (power_level === 6) {
    next_power_level_temperature = base_max_temperature
      * (selected_fuel ? selected_fuel.temperature_multiplier : 1);
  }

  const temperatures = [
    prev_power_level_temperature,
    next_power_level_temperature,
    ...[
      internal_fusion_temperature,
      moderator_internal_temperature,
      internal_output_temperature,
      internal_coolant_temperature,
    ].filter(d => d),
  ].map(d => parseFloat(d));

  const maxTemperature = Math.max(...temperatures);
  const minTemperature = Math.max(2.73, Math.min(20, ...temperatures.filter(d=>d>0)));

  if (power_level === 6) {
    next_power_level_temperature = 0;
  }

  const height = 200;

  const yAxisLabelWidth = 60;
  const yAxisIconPadding = 2;
  const yAxisIconWidth = 14;
  const yAxisMargin = yAxisLabelWidth + yAxisIconWidth + yAxisIconPadding * 2;

  const value_to_y = (value, baseTemp = minTemperature, fromBottom=false) => {
    const ratio = (Math.log10(value) - Math.log10(baseTemp)) / (Math.log10(maxTemperature) - Math.log10(minTemperature));
    return height * (fromBottom ? (1 - ratio) : ratio);
  };

  const TemperatureLabel = (props, context) => {
    const {
      icon,
      force,
      tooltip,
      value,
      ...rest
    } = props;
    const y = value_to_y(value);
    const label = (
      <Box
        fluid
        align="right"
        color="label"
        position="absolute"
        top="0"
        left="0"
        width={`${yAxisMargin}px`}
      >
        {icon && (<Icon
          display="inline-block"
          mr={`${yAxisIconPadding}px`}
          name={icon}
        />)}
        {to_exponential_if_big(value) + " K"}
      </Box>
    );
    return (!!value || force) && (
      <Box fluid style={{
        position: 'absolute',
        top: `${height - y}px`,
        left: '0px',
        right: '20px',
      }}>
        <Box
          backgroundColor="label"
          style={{
            position: "absolute",
            left: `${yAxisMargin}px`,
            right: '0',
            top: '0.5em',
            height: '1px',
          }}
        />
        {tooltip
          ? (
            <Tooltip content={tooltip}>
              {label}
            </Tooltip>
          )
          : label}
      </Box>
    );
  };

  const TemperatureBar = (props, context) => {
    const {
      label,
      delta,
      value,
      children,
      ...rest
    } = props;
    const y = value_to_y(value);
    const delta_str = to_exponential_if_big(delta) + " K/s";
    return (
      <Flex.Item mx={1}>
        <Stack vertical align="center">
          <Stack.Item>
            <VerticalBar
              height={height}
              progressHeight={y}
              value={value}
              {...rest}
            >
              {children}
            </VerticalBar>
          </Stack.Item>
          <Stack.Item color="label">
            <Box align="center">{label}</Box>
            {value > 0
              ? (
                <>
                  <Box align="center">
                    {to_exponential_if_big(value) + " K"}
                  </Box>
                  <Box align="center">{(delta > 0
                    ? `+${delta_str}`
                    : delta < 0
                      ? `${delta_str}`
                      : "-"
                  )}
                  </Box>
                </>)
              : (
                <>
                  <Box
                    align="center"
                    color="red"
                  >
                    Empty
                  </Box>
                  <Box
                    style={{
                      "user-select": "none",
                      "-ms-user-select": "none",
                      unselectable: Byond.IS_LTE_IE8,
                    }}
                  >
                &nbsp;
                  </Box>
                </>
              )}
          </Stack.Item>
        </Stack>
      </Flex.Item>
    );
  };

  return (
    <Section title="Gas Monitoring" minWidth="400px">
      <Flex overflowY="hidden">
        <Flex.Item mx={1} width={`${yAxisMargin}px`}>
          {(power_level === 0 || Math.abs(value_to_y(prev_power_level_temperature) - value_to_y(minTemperature)) > 20) && (<TemperatureLabel key="min_temp" value={minTemperature} force />)}
          <TemperatureLabel key="prev_fusion_temp" icon="chevron-down" tooltip="Previous Fusion Level" value={prev_power_level_temperature} />
          <TemperatureLabel key="next_fusion_temp" icon="chevron-up" tooltip="Next Fusion Level" value={next_power_level_temperature} />
          {Math.abs(value_to_y(next_power_level_temperature) - value_to_y(maxTemperature)) > 20 && (<TemperatureLabel key="max_temp" value={maxTemperature} />)}
        </Flex.Item>
        <Box
          backgroundColor="label"
          style={{
            position: "absolute",
            left: `${yAxisMargin}px`,
            height: `${height}px`,
            top: '0.5em',
            width: '1px',
          }}
        />
        <TemperatureBar
          label="Fusion"
          value={internal_fusion_temperature}
          delta={internal_fusion_temperature_delta}
          color="#f2711c" />
        <TemperatureBar
          label="Moderator"
          value={moderator_internal_temperature}
          delta={moderator_internal_temperature_delta}
          color="#e03997" />
        <TemperatureBar
          label="Coolant"
          value={internal_coolant_temperature}
          delta={internal_coolant_temperature_delta}
          color="aliceblue" />
        <TemperatureBar
          label="Output"
          value={internal_output_temperature}
          delta={internal_output_temperature_delta}
          color="#20b142" />
      </Flex>
    </Section>
  );
};
