import { useBackend } from 'tgui/backend';
import {
  Flex,
  LabeledControls,
  RoundGauge,
  Section,
} from 'tgui-core/components';
import { formatSiUnit } from 'tgui-core/format';
import { toFixed } from 'tgui-core/math';

type Data = {
  apc_energy: number;
  energy_level: number;
  heat_output_max: number;
  heat_output_min: number;
  heat_output: number;
  instability: number;
  integrity: number;
  iron_content: number;
  power_level: number;
  start_power: number;
};

/*
 * Parameter display
 *
 * Displays a set of gauges displaying key information about the
 * HFR.
 *
 * Parameters with dangerous thresholds also display warnings at the
 * relevant levels.
 */
export const HypertorusParameters = (props) => {
  const { data } = useBackend<Data>();
  const {
    apc_energy,
    energy_level,
    heat_output_max,
    heat_output_min,
    heat_output,
    instability,
    integrity,
    iron_content,
    power_level,
    start_power,
  } = data;

  const energy_minimum_exponent = 12;
  const energy_minimum_suffix = energy_minimum_exponent / 3;

  let activity =
    heat_output / (heat_output < 0 ? heat_output_min : heat_output_max);
  if (Number.isNaN(activity) || !Number.isFinite(activity)) {
    activity = 0;
  }

  return (
    <Section title="Состояние реактора">
      <Flex className="hypertorus-parameters" justify="space-between" wrap>
        <Flex.Item grow="360" minWidth="120px">
          <LabeledControls justify="space-around" wrap>
            <LabeledControls.Item label="Целостность реактора">
              <RoundGauge
                size={1.75}
                value={integrity}
                minValue={0}
                maxValue={100}
                alertBefore={95}
                format={(v) => `${Math.round(v)}%`}
                ranges={{
                  good: [90, 100],
                  average: [50, 90],
                  bad: [0, 50],
                }}
              />
            </LabeledControls.Item>
            <LabeledControls.Item label="Содержание железа">
              <RoundGauge
                size={1.75}
                value={iron_content}
                minValue={0}
                maxValue={1}
                alertAfter={0.25}
                format={(v) => `${Math.round(v * 100)}%`}
                ranges={{
                  good: [0, 0.1],
                  average: [0.1, 0.36],
                  bad: [0.36, 1],
                }}
              />
            </LabeledControls.Item>
            <LabeledControls.Item label="Питание зоны">
              <RoundGauge
                size={1.75}
                value={apc_energy}
                minValue={0}
                maxValue={100}
                alertBefore={30}
                format={(v) => `${Math.round(v)}%`}
                ranges={{
                  // Keep these in line with the auto-off thresholds in apc.dm
                  bad: [0, 15],
                  average: [15, 30],
                  good: [30, 100],
                }}
              />
            </LabeledControls.Item>
          </LabeledControls>
        </Flex.Item>
        <Flex.Item grow="140" minWidth="140px" align="center">
          <LabeledControls justify="space-around">
            <LabeledControls.Item label="Уровень синтеза">
              <RoundGauge
                size={3}
                minValue={0}
                maxValue={6}
                value={power_level}
                alertAfter={4.5}
                ranges={{
                  grey: [0, 1],
                  good: [1, 3.5],
                  average: [3.5, 4.5],
                  bad: [4.5, 6],
                }}
              />
            </LabeledControls.Item>
          </LabeledControls>
        </Flex.Item>
        <Flex.Item grow="360" minWidth="120px">
          <LabeledControls justify="space-around" wrap>
            <LabeledControls.Item label="Тепловыделение">
              <RoundGauge
                size={1.75}
                value={Math.max(0, Math.log10(energy_level))}
                minValue={energy_minimum_exponent}
                maxValue={30}
                format={(v) =>
                  formatSiUnit(10 ** v, energy_minimum_suffix, 'J')
                }
                ranges={{
                  black: [energy_minimum_exponent, 15],
                  grey: [15, 18], // Anything under 1EJ is pretty mediocre
                  yellow: [18, 24],
                  orange: [24, 30],
                }}
              />
            </LabeledControls.Item>
            <LabeledControls.Item label="Активность реакции">
              <RoundGauge
                size={1.75}
                value={activity * 100}
                minValue={0}
                maxValue={130} // Proto-nitrate lets us exceed 100%
                format={(v) => `${start_power ? toFixed(v, 1) : 0}%`}
                ranges={{
                  grey: [0, 70],
                  blue: [70, 100],
                  orange: [100, 130],
                }}
              />
            </LabeledControls.Item>
            <LabeledControls.Item label="Нестабильность">
              <RoundGauge
                size={1.75}
                value={Math.max(instability, 0)}
                minValue={0}
                maxValue={10}
                format={(v) =>
                  `${start_power ? toFixed((v / 8) * 100, 1) : 0}%`
                }
                ranges={{
                  orange: [0, 8], // exothermic
                  blue: [8, 10], // endothermic
                }}
              />
            </LabeledControls.Item>
          </LabeledControls>
        </Flex.Item>
      </Flex>
    </Section>
  );
};
