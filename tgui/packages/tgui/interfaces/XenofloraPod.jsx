
import { useBackend } from '../backend';
import { Button, Section, Stack, LabeledList, ProgressBar } from '../components';
import { getGasColor, getGasLabel } from '../constants';
import { Window } from '../layouts';
import { toFixed } from 'common/math';

const logScale = value => Math.log2(16 + Math.max(0, value)) - 4;

export const XenofloraPod = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      width={1000}
      height={360 + 24 * data.additional_bars}>
      <Window.Content>
        <Section
          title="Xenoflora Pod"
          buttons={(
            <>
              <Button
                icon={data.on ? 'power-off' : 'times'}
                content={data.on ? 'On' : 'Off'}
                selected={data.on}
                onClick={() => act('power')} />
              <Button
                icon="tree"
                content="Toggle Dome"
                selected={data.dome}
                disabled={!data.on}
                onClick={() => act('dome')} />
            </>
          )}>
          <Stack vertical>
            <Stack.Item>
              <Stack fill>
                <Stack.Item width="60%">
                  <Stack.Item fontSize="17px">
                    {data.plant_name ? data.plant_name : "No plant located!"}
                  </Stack.Item>
                  <Stack.Item>
                    {data.plant_desc}
                  </Stack.Item>
                  {!!data.plant_name && (
                    <Stack.Item>
                      {data.safe_temp ? data.safe_temp : "Plant has no temperature requirements."}
                    </Stack.Item>
                  )}
                </Stack.Item>
                <Stack.Divider mr={1} />
                <Stack.Item width="40%">
                  <LabeledList>
                    <LabeledList.Item label="Plant Health">
                      <ProgressBar
                        value={data.health}
                        minValue={0}
                        maxValue={100}
                        ranges={{
                          bad: [0, 40],
                          average: [40, 70],
                          good: [70, 100],
                        }}>
                        {toFixed(data.health, 1) + '%'}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Growth Progress">
                      <ProgressBar
                        value={data.progress}
                        minValue={0}
                        maxValue={100}
                        ranges={{
                          good: [0, 100],
                        }}>
                        {toFixed(data.progress, 1) + '%'}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Total Growth Progress">
                      <ProgressBar
                        value={data.total_progress}
                        minValue={0}
                        maxValue={100}
                        ranges={{
                          good: [0, 100],
                        }}>
                        {toFixed(data.total_progress, 1) + '%'}
                      </ProgressBar>
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            {data.plant_name && (
              <>
                {!!(data.required_gases && data.required_gases.length) && (
                  <>
                    <Stack.Item fontSize="13px">
                      Required gases:
                    </Stack.Item>
                    <Stack.Item>
                      <LabeledList>
                        {data.required_gases.map(gas => (
                          <LabeledList.Item
                            key={gas.name}
                            label={getGasLabel(gas.name)}>
                            <ProgressBar
                              color={getGasColor(gas.name)}
                              value={gas.amount}
                              minValue={0}
                              maxValue={data.total_required_gases}>
                              {toFixed(gas.amount, 0.1) + ' moles per second'}
                            </ProgressBar>
                          </LabeledList.Item>
                        ))}
                      </LabeledList>
                    </Stack.Item>
                  </>
                )}
                {!!(data.required_chems && data.required_chems.length) && (
                  <>
                    <Stack.Item fontSize="13px">
                      Required chemicals:
                    </Stack.Item>
                    <Stack.Item>
                      <LabeledList>
                        {data.required_chems.map(chem => (
                          <LabeledList.Item
                            key={chem.name}
                            label={getGasLabel(chem.name)}>
                            <ProgressBar
                              color={chem.color}
                              value={chem.amount}
                              minValue={0}
                              maxValue={data.total_required_chems}>
                              {toFixed(chem.amount, 0.1) + ' moles per second'}
                            </ProgressBar>
                          </LabeledList.Item>
                        ))}
                      </LabeledList>
                    </Stack.Item>
                  </>
                )}
                {!!(data.produced_gases && data.produced_gases.length) && (
                  <>
                    <Stack.Item fontSize="13px">
                      Produced gases:
                    </Stack.Item>
                    <Stack.Item>
                      <LabeledList>
                        {data.produced_gases.map(gas => (
                          <LabeledList.Item
                            key={gas.name}
                            label={getGasLabel(gas.name)}>
                            <ProgressBar
                              color={getGasColor(gas.name)}
                              value={gas.amount}
                              minValue={0}
                              maxValue={data.total_produced_gases}>
                              {toFixed(gas.amount, 0.1) + ' moles per second'}
                            </ProgressBar>
                          </LabeledList.Item>
                        ))}
                      </LabeledList>
                    </Stack.Item>
                  </>
                )}
                {!!(data.produced_chems && data.produced_chems.length) && (
                  <>
                    <Stack.Item fontSize="13px">
                      Produced chemicals:
                    </Stack.Item>
                    <Stack.Item>
                      <LabeledList>
                        {data.produced_chems.map(chem => (
                          <LabeledList.Item
                            key={chem.name}
                            label={getGasLabel(chem.name)}>
                            <ProgressBar
                              color={chem.color}
                              value={chem.amount}
                              minValue={0}
                              maxValue={data.total_produced_chems}>
                              {toFixed(chem.amount, 0.1) + ' moles per second'}
                            </ProgressBar>
                          </LabeledList.Item>
                        ))}
                      </LabeledList>
                    </Stack.Item>
                  </>
                )}
              </>
            )}
          </Stack>
        </Section>
        <Section title="Gases">
          {data.internal_gas_data && (
            <LabeledList>
              <LabeledList.Item label="Temperature">
                <ProgressBar
                  value={logScale(data.temperature)}
                  minValue={0}
                  maxValue={logScale(10000)}
                  ranges={{
                    teal: [-Infinity, logScale(80)],
                    good: [logScale(80), logScale(600)],
                    average: [logScale(600), logScale(5000)],
                    bad: [logScale(5000), Infinity],
                  }}>
                  {toFixed(data.temperature, 0.1) + ' K'}
                </ProgressBar>
              </LabeledList.Item>
              {data.internal_gas_data.map(gas => (
                <LabeledList.Item
                  key={gas.name}
                  label={getGasLabel(gas.name)}>
                  <ProgressBar
                    color={getGasColor(gas.name)}
                    value={gas.amount}
                    minValue={0}
                    maxValue={data.total_gases}>
                    {toFixed(gas.amount, 0.1) + ' moles'}
                  </ProgressBar>
                </LabeledList.Item>
              ))}
            </LabeledList>
          )}
        </Section>
        <Section title="Reagents">
          {data.chemical_data && (
            <LabeledList>
              <LabeledList.Item label="Temperature">
                <ProgressBar
                  value={logScale(data.chem_temperature)}
                  minValue={0}
                  maxValue={logScale(1000)}
                  ranges={{
                    teal: [-Infinity, logScale(20)],
                    average: [logScale(20), logScale(225)],
                    good: [logScale(225), logScale(600)],
                    bad: [logScale(600), Infinity],
                  }}>
                  {toFixed(data.chem_temperature, 0.1) + ' K'}
                </ProgressBar>
              </LabeledList.Item>
              {data.chemical_data.map(chemical => (
                <LabeledList.Item
                  key={chemical.name}
                  label={chemical.name}>
                  <ProgressBar
                    color={chemical.color}
                    value={chemical.amount}
                    minValue={0}
                    maxValue={data.total_chems}>
                    {toFixed(chemical.amount, 0.1) + ' moles'}
                  </ProgressBar>
                </LabeledList.Item>
              ))}
            </LabeledList>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
