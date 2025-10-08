import { sortBy } from 'es-toolkit';
import { filter } from 'es-toolkit/compat';
import { useBackend } from 'tgui/backend';
import { getGasColor, getGasLabel } from 'tgui/constants';
import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import type { HypertorusFuel, HypertorusGas } from '.';
import { HelpDummy, HoverHelp } from './helpers';

type GasListProps = {
  input_max: number;
  input_min: number;
  input_rate: string;
  input_switch: string;
  raw_gases: HypertorusGas[];
  minimumScale: number;
  prepend?: (gas: HypertorusGas) => void;
  rateHelp?: string;
  stickyGases?: readonly string[];
};

type GasListData = {
  start_power: number;
  start_cooling: number;
};

type HypertorusData = {
  fusion_gases: HypertorusGas[];
  moderator_gases: HypertorusGas[];
  selectable_fuel: HypertorusFuel[];
  selected: string;
};

/*
 * Displays contents of gas mixtures, along with help text for gases with
 * special text when present. Some gas bars are always visible, even when
 * absent, to hint at what can be added and their effects.
 */

const moderator_gases_help = {
  plasma:
    'Produces basic gases. Has a modest heat bonus to help kick start the early fusion process. When added in large quantities, its high heat capacity can help to slow down temperature changes to manageable speeds.',
  bz: 'Produces intermediate gases at Fusion Level 3 or higher. Massively increases radiation, and induces hallucinations in bystanders.',
  proto_nitrate:
    'Produces advanced gases. Massively increases radiation, and accelerates the rate of temperature change. Make sure you have enough cooling.',
  o2: 'When added in high quantities, rapidly purges iron content. Does not purge iron content fast enough to keep up with damage at high Fusion Levels.',
  healium:
    'Directly heals a heavily damaged HFR core at high Fusion Levels, but is rapidly consumed in the process.',
  antinoblium:
    'Provides huge amounts of energy and radiation. Can cause dangerous electrical storms even from a healthy HFR core when present in more than trace amounts. Wear appropriate electrical protection when handling.',
  freon:
    'Saps most forms of energy expression. Slows the rate of temperature change.',
} as const;

const moderator_gases_sticky_order = ['plasma', 'bz', 'proto_nitrate'] as const;

const ensure_gases = (gas_array: HypertorusGas[] = [], gasids) => {
  const gases_by_id = {};
  gas_array.forEach((gas) => {
    gases_by_id[gas.id] = true;
  });

  for (const gasid of gasids) {
    if (!gases_by_id[gasid]) {
      gas_array.push({ id: gasid, amount: 0 });
    }
  }
};

const GasList = (props: GasListProps) => {
  const { act, data } = useBackend<GasListData>();
  const {
    input_max,
    input_min,
    input_rate,
    input_switch,
    raw_gases = [],
    minimumScale,
    prepend,
    rateHelp = '',
    stickyGases,
  } = props;
  const { start_power, start_cooling } = data;

  const gases: HypertorusGas[] = sortBy(
    filter(raw_gases, (gas) => gas.amount >= 0.01),
    [(gas) => -gas.amount],
  );

  if (stickyGases) {
    ensure_gases(gases, stickyGases);
  }

  return (
    <LabeledList>
      <LabeledList.Item
        label={
          <>
            <HoverHelp content={rateHelp} />
            Injection control:
          </>
        }
      >
        <Button
          disabled={start_power === 0 || start_cooling === 0}
          icon={data[input_switch] ? 'power-off' : 'times'}
          content={data[input_switch] ? 'On' : 'Off'}
          selected={data[input_switch]}
          onClick={() => act(input_switch)}
        />
        <NumberInput
          animated
          tickWhileDragging
          step={1}
          value={parseFloat(data[input_rate])}
          unit="mol/s"
          minValue={input_min}
          maxValue={input_max}
          onChange={(v) => act(input_rate, { [input_rate]: v })}
        />
      </LabeledList.Item>
      {gases.map((gas) => {
        let labelPrefix;
        if (prepend) {
          labelPrefix = prepend(gas);
        }
        return (
          <LabeledList.Item
            key={gas.id}
            label={
              <>
                {labelPrefix}
                {getGasLabel(gas.id)}:
              </>
            }
          >
            <ProgressBar
              color={getGasColor(gas.id)}
              value={gas.amount}
              minValue={0}
              maxValue={minimumScale}
            >
              {`${toFixed(gas.amount, 2)} moles`}
            </ProgressBar>
          </LabeledList.Item>
        );
      })}
    </LabeledList>
  );
};

export const HypertorusGases = (props) => {
  const { data } = useBackend<HypertorusData>();
  const {
    fusion_gases = [],
    moderator_gases = [],
    selectable_fuel = [],
    selected,
  } = data;

  const selected_fuel = selectable_fuel.filter((d) => d.id === selected)[0];

  return (
    <>
      <Section title="Internal Fusion Gases">
        {selected_fuel ? (
          <GasList
            input_rate="fuel_injection_rate"
            input_switch="start_fuel"
            input_max={150}
            input_min={0.5}
            raw_gases={fusion_gases}
            minimumScale={500}
            prepend={() => <HelpDummy />}
            rateHelp={
              'The rate at which new fuel is added from the fuel input port.' +
              ' This rate affects the rate of production,' +
              ' even when input is not active.'
            }
            stickyGases={selected_fuel.requirements}
          />
        ) : (
          <Box align="center" color="red">
            {'No recipe selected'}
          </Box>
        )}
      </Section>
      <Section title="Moderator Gases">
        <GasList
          input_rate="moderator_injection_rate"
          input_switch="start_moderator"
          input_max={150}
          input_min={0.5}
          raw_gases={moderator_gases}
          minimumScale={500}
          rateHelp={
            'The rate at which new moderator gas is added from the moderator port.'
          }
          stickyGases={moderator_gases_sticky_order}
          prepend={(gas) =>
            moderator_gases_help[gas.id] ? (
              <HoverHelp content={moderator_gases_help[gas.id]} />
            ) : (
              <HelpDummy />
            )
          }
        />
      </Section>
    </>
  );
};
