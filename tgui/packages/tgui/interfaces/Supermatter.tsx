import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { BooleanLike } from 'common/react';
import { InfernoNode } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section, Stack } from '../components';
import { getGasFromPath } from '../constants';
import { Window } from '../layouts';

const logScale = (value) => Math.log2(16 + Math.max(0, value)) - 4;

type SMGasMetadata = {
  [key: string]: {
    desc?: string;
    numeric_data: {
      name: string;
      amount: number;
      positive: BooleanLike;
    }[];
  };
};

type SupermatterProps = {
  sectionButton?: InfernoNode;
  uid: number;
  area_name: string;
  integrity: number;
  integrity_factors: { name: string; amount: number }[];
  internal_energy: number;
  internal_energy_factors: { name: string; amount: number }[];
  zap_multiplier: number;
  zap_multiplier_factors: { name: string; amount: number }[];
  temp_limit: number;
  temp_limit_factors: { name: string; amount: number }[];
  waste_multiplier: number;
  waste_multiplier_factors: { name: string; amount: number }[];
  absorbed_ratio: number;
  gas_composition: { [gas_path: string]: number };
  gas_temperature: number;
  gas_total_moles: number;
  gas_metadata: SMGasMetadata;
};

// LabeledList but stack and with a chevron dropdown.
type SupermatterEntryProps = {
  title: string;
  content: InfernoNode;
  detail?: InfernoNode;
  alwaysShowChevron?: boolean;
};
const SupermatterEntry = (props: SupermatterEntryProps, context) => {
  const { title, content, detail, alwaysShowChevron } = props;
  if (!alwaysShowChevron && !detail) {
    return (
      <Stack.Item>
        <Stack align="center">
          <Stack.Item color="grey" width="125px">
            {title + ':'}
          </Stack.Item>
          <Stack.Item grow>{content}</Stack.Item>
        </Stack>
      </Stack.Item>
    );
  }
  const [activeDetail, setActiveDetail] = useLocalState(context, title, false);
  return (
    <>
      <Stack.Item>
        <Stack align="center">
          <Stack.Item color="grey" width="125px">
            {title + ':'}
          </Stack.Item>
          <Stack.Item grow>{content}</Stack.Item>
          <Stack.Item>
            <Button
              onClick={() => setActiveDetail(!activeDetail)}
              icon={activeDetail ? 'chevron-up' : 'chevron-down'}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      {activeDetail && !!detail && <Stack.Item pl={3}>{detail}</Stack.Item>}
    </>
  );
};
export const SupermatterContent = (props: SupermatterProps, context) => {
  const {
    sectionButton,
    uid,
    area_name,
    integrity,
    integrity_factors,
    internal_energy,
    internal_energy_factors,
    zap_multiplier,
    zap_multiplier_factors,
    temp_limit,
    temp_limit_factors,
    waste_multiplier,
    waste_multiplier_factors,
    absorbed_ratio,
    gas_temperature,
    gas_total_moles,
    gas_metadata,
  } = props;
  const [allGasActive, setAllGasActive] = useLocalState(
    context,
    'allGasActive',
    false
  );
  const gas_composition: [gas_path: string, amount: number][] = flow([
    !allGasActive && filter(([gas_path, amount]) => amount !== 0),
    sortBy(([gas_path, amount]) => -amount),
  ])(Object.entries(props.gas_composition));
  return (
    <Stack height="100%">
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={uid + '. ' + area_name}
          buttons={sectionButton}>
          <Stack vertical>
            <SupermatterEntry
              title="Integrity"
              alwaysShowChevron
              content={
                <ProgressBar
                  value={integrity / 100}
                  ranges={{
                    good: [0.9, Infinity],
                    average: [0.5, 0.9],
                    bad: [-Infinity, 0.5],
                  }}>
                  {toFixed(integrity, 2) + ' %'}
                </ProgressBar>
              }
              detail={
                !!integrity_factors.length && (
                  <LabeledList>
                    {integrity_factors.map(({ name, amount }) => (
                      <LabeledList.Item
                        key={name}
                        label={name + ' (∆)'}
                        labelWrap>
                        <Box color={amount > 0 ? 'green' : 'red'}>
                          {toFixed(amount, 2) + ' %'}
                        </Box>
                      </LabeledList.Item>
                    ))}
                  </LabeledList>
                )
              }
            />
            <SupermatterEntry
              title="Internal Energy"
              alwaysShowChevron
              content={
                <ProgressBar
                  value={internal_energy}
                  minValue={0}
                  maxValue={5000}
                  ranges={{
                    good: [-Infinity, 5000],
                    average: [5000, 7000],
                    bad: [7000, Infinity],
                  }}>
                  {toFixed(internal_energy) + ' MeV/cm3'}
                </ProgressBar>
              }
              detail={
                !!internal_energy_factors.length && (
                  <LabeledList>
                    {internal_energy_factors.map(({ name, amount }) => (
                      <LabeledList.Item
                        key={name}
                        label={name + ' (∆)'}
                        labelWrap>
                        <Box color={amount > 0 ? 'green' : 'red'}>
                          {toFixed(amount, 2) + ' MeV/cm3'}
                        </Box>
                      </LabeledList.Item>
                    ))}
                  </LabeledList>
                )
              }
            />
            <SupermatterEntry
              title="Zap Power Multiplier"
              alwaysShowChevron
              content={
                <ProgressBar
                  value={zap_multiplier}
                  minValue={0}
                  maxValue={5}
                  ranges={{
                    good: [1.2, Infinity],
                    average: [0.8, 1.2],
                    bad: [-Infinity, 0.8],
                  }}>
                  {toFixed(zap_multiplier, 2) + ' x'}
                </ProgressBar>
              }
              detail={
                !!zap_multiplier_factors.length && (
                  <LabeledList>
                    {zap_multiplier_factors.map(({ name, amount }) => (
                      <LabeledList.Item key={name} label={name} labelWrap>
                        <Box color={amount > 0 ? 'green' : 'red'}>
                          {toFixed(amount, 2) + ' x'}
                        </Box>
                      </LabeledList.Item>
                    ))}
                  </LabeledList>
                )
              }
            />
            <SupermatterEntry
              title="Absorbed Moles"
              content={
                <ProgressBar
                  value={gas_total_moles}
                  minValue={0}
                  maxValue={2000}
                  ranges={{
                    good: [0, 900],
                    average: [900, 1800],
                    bad: [1800, Infinity],
                  }}>
                  {toFixed(gas_total_moles, 2) + ' Moles'}
                </ProgressBar>
              }
            />
            <SupermatterEntry
              title="Temperature"
              content={
                <ProgressBar
                  value={logScale(gas_temperature)}
                  minValue={0}
                  maxValue={logScale(10000)}
                  ranges={{
                    teal: [-Infinity, logScale(100)],
                    good: [logScale(100), logScale(300)],
                    average: [logScale(300), logScale(temp_limit)],
                    bad: [logScale(temp_limit), Infinity],
                  }}>
                  {toFixed(gas_temperature, 2) + ' K'}
                </ProgressBar>
              }
            />
            <SupermatterEntry
              title="Temperature Limit"
              alwaysShowChevron
              content={temp_limit + ' K'}
              detail={
                !!temp_limit_factors.length && (
                  <LabeledList>
                    {temp_limit_factors.map(({ name, amount }) => (
                      <LabeledList.Item key={name} label={name} labelWrap>
                        <Box color={amount > 0 ? 'green' : 'red'}>
                          {toFixed(amount, 2) + ' K'}
                        </Box>
                      </LabeledList.Item>
                    ))}
                  </LabeledList>
                )
              }
            />
            <SupermatterEntry
              title="Waste Multiplier"
              alwaysShowChevron
              content={
                <ProgressBar
                  value={waste_multiplier}
                  minValue={0}
                  maxValue={20}
                  ranges={{
                    good: [-Infinity, 0.8],
                    average: [0.8, 2],
                    bad: [2, Infinity],
                  }}>
                  {toFixed(waste_multiplier, 2) + ' x'}
                </ProgressBar>
              }
              detail={
                !!waste_multiplier_factors.length && (
                  <LabeledList>
                    {waste_multiplier_factors.map(({ name, amount }) => (
                      <LabeledList.Item key={name} label={name} labelWrap>
                        <Box color={amount < 0 ? 'green' : 'red'}>
                          {toFixed(amount, 2) + ' x'}
                        </Box>
                      </LabeledList.Item>
                    ))}
                  </LabeledList>
                )
              }
            />
            <SupermatterEntry
              title="Absorption Ratio"
              content={absorbed_ratio * 100 + '%'}
            />
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title="Gases"
          buttons={
            <Button
              icon={allGasActive ? 'times' : 'book-open'}
              onClick={() => setAllGasActive(!allGasActive)}>
              {allGasActive ? 'Hide Gases' : 'Show All Gases'}
            </Button>
          }>
          <Stack vertical>
            {gas_composition.map(([gas_path, amount]) => (
              <SupermatterEntry
                key={gas_path}
                title={getGasFromPath(gas_path)?.label || 'Unknown'}
                content={
                  <ProgressBar
                    color={getGasFromPath(gas_path)?.color}
                    value={amount}
                    minValue={0}
                    maxValue={1}>
                    {toFixed(amount * 100, 2) + '%'}
                  </ProgressBar>
                }
                detail={
                  gas_metadata[gas_path] ? (
                    <>
                      {gas_metadata[gas_path].desc && <br />}
                      {gas_metadata[gas_path].numeric_data.length ? (
                        <>
                          <Box mb={1}>
                            At <b>100% Composition</b> gives:
                          </Box>
                          <LabeledList>
                            {gas_metadata[gas_path].numeric_data.map(
                              (effect) =>
                                effect.amount !== 0 && (
                                  <LabeledList.Item
                                    key={gas_path + effect.name}
                                    label={effect.name}
                                    color={
                                      effect.positive
                                        ? effect.amount > 0
                                          ? 'green'
                                          : 'red'
                                        : effect.amount < 0
                                          ? 'green'
                                          : 'red'
                                    }>
                                    {effect.amount > 0
                                      ? '+' + effect.amount * 100 + '%'
                                      : effect.amount * 100 + '%'}
                                  </LabeledList.Item>
                                )
                            )}
                          </LabeledList>
                        </>
                      ) : (
                        'Has no composition effects'
                      )}
                    </>
                  ) : (
                    'Has no effects'
                  )
                }
              />
            ))}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export type SupermatterData = {
  sm_data: Omit<SupermatterProps, 'sectionButton' | 'gas_metadata'>[];
  gas_metadata: SMGasMetadata;
};

export const Supermatter = (props, context) => {
  const { act, data } = useBackend<SupermatterData>(context);
  const { sm_data, gas_metadata } = data;
  return (
    <Window width={700} height={400} theme="ntos">
      <Window.Content>
        <SupermatterContent {...sm_data[0]} gas_metadata={gas_metadata} />
      </Window.Content>
    </Window>
  );
};
