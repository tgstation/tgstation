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
    'Производит основные газы. Имеет небольшой тепловой бонус, помогающий запустить ранний процесс синтеза. При добавлении в больших количествах его высокая теплоемкость может помочь замедлить изменение температуры до приемлемой скорости.',
  bz: 'Производит промежуточные газы на уровне термоядерного синтеза 3 или выше. Сильно повышает радиацию и вызывает галлюцинации у окружающих.',
  proto_nitrate:
    'Производит продвинутые газы. Сильно увеличивает радиацию и ускоряет скорость изменения температуры. Убедитесь что у вас достаточно охлаждения.',
  o2: 'При добавлении в больших количествах быстро очищает железо. Не очищает содержание железа достаточно быстро, чтобы успевать за уроном на высоких уровнях синтеза.',
  healium:
    'Непосредственно восстанавливает сильно поврежденное ядро HFR на высоких уровнях синтеза, но быстро расходуется в процессе.',
  antinoblium:
    'Обеспечивает огромное количество энергии и излучения. Может вызывать опасные электрические бури даже в исправном HFR-ядре, если присутствует в более чем следовых количествах. При работе с ним используйте соответствующие средства электрозащиты.',
  freon:
    'Поглощает большинство форм энергии. Замедляет скорость изменения температуры.',
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
            Управление впрыском:
          </>
        }
      >
        <Button
          disabled={start_power === 0 || start_cooling === 0}
          icon={data[input_switch] ? 'power-off' : 'times'}
          content={data[input_switch] ? 'Вкл' : 'Выкл'}
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
      <Section title="Газы внутреннего синтеза">
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
              'Скорость, с которой новое топливо добавляется из порта подачи топлива.' +
              ' Этот показатель влияет на скорость производства,' +
              ' даже если ввод не активен.'
            }
            stickyGases={selected_fuel.requirements}
          />
        ) : (
          <Box align="center" color="red">
            {'Рецепт не выбран'}
          </Box>
        )}
      </Section>
      <Section title="Газы модератора">
        <GasList
          input_rate="moderator_injection_rate"
          input_switch="start_moderator"
          input_max={150}
          input_min={0.5}
          raw_gases={moderator_gases}
          minimumScale={500}
          rateHelp={
            'Скорость, с которой новый газ модератора добавляется из порта.'
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
