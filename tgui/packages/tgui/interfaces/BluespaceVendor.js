import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { multiline } from 'common/string';
import { useBackend } from '../backend';
import { Button, Divider, LabeledList, NumberInput, ProgressBar, Section, Stack } from '../components';
import { getGasColor, getGasLabel } from '../constants';
import { Window } from '../layouts';

export const BluespaceVendor = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    on,
    tank_filling_amount,
    price_multiplier,
    pumping,
    selected_gas,
  } = data;
  const bluespace_network_gases = flow([
    filter(gas => gas.amount >= 0.01),
    sortBy(gas => -gas.amount),
  ])(data.bluespace_network_gases || []);
  const gasMax = Math.max(1, ...bluespace_network_gases.map(gas => gas.amount));
  return (
    <Window
      title="Bluespace Vendor"
      width={500}
      height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section
              title="Controls"
              buttons={(
                <>
                  <Button
                    ml={1}
                    icon="plus"
                    content="Prepare Tank"
                    disabled={
                      data.pumping || data.inserted_tank || !data.tank_amount
                    }
                    onClick={() => act('tank_prepare')} />
                  <Button
                    ml={1}
                    icon="minus"
                    content="Remove Tank"
                    disabled={data.pumping || !data.inserted_tank}
                    onClick={() => act('tank_expel')} />
                </>
              )}>
              <Stack>
                <Stack.Item>
                  <NumberInput
                    animated
                    value={tank_filling_amount}
                    width="63px"
                    unit="% tank filling goal"
                    minValue={0}
                    maxValue={100}
                    onDrag={(e, value) => act('pumping_rate', {
                      rate: value,
                    })} />
                </Stack.Item>
                <Stack.Item grow>
                  {
                    <ProgressBar
                      value={data.tank_full / 1010}
                      ranges={{
                        good: [0.67, 1],
                        average: [0.34, 0.66],
                        bad: [0, 0.33],
                      }} />
                  }
                </Stack.Item>
              </Stack>


            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              scrollable
              fill
              title="Bluespace Network Gases"
              buttons={(
                <Button
                  color="transparent"
                  icon="info"
                  tooltipPosition="bottom-start"
                  tooltip={multiline`
                  Quick guide for machine use: prepare a tank to create a
                  new one in the machine, pick how much you want it filled,
                  and finally press start on the gas of your choice!
                `} />
              )}>
              <LabeledList>
                {bluespace_network_gases.map(gas => (
                  <>
                    <Stack key={gas.name}>
                      <Stack.Item color="label" basis={8} ml={1}>
                        {getGasLabel(gas.name) + " is " + gas.price + " credits per mole"}
                      </Stack.Item>
                      <Stack.Item grow mt={1}>
                        <ProgressBar
                          color={getGasColor(gas.name)}
                          value={gas.amount}
                          minValue={0}
                          maxValue={gasMax}>
                          {toFixed(gas.amount, 2) + ' moles'}
                        </ProgressBar>
                      </Stack.Item>
                      <Stack.Item ml={-0.1} mr={1} mt={1}>
                        {!data.pumping && data.selected_gas !== gas.id && (
                          <Button
                            ml={1}
                            icon="play"
                            tooltipPosition="left"
                            tooltip={"Start adding " + gas.name + "."}
                            disabled={!data.inserted_tank}
                            onClick={() => act('start_pumping', {
                              gas_id: gas.id,
                            })} />
                        ) || (
                          <Button
                            ml={1}
                            disabled={data.selected_gas !== gas.id}
                            icon="minus"
                            tooltipPosition="left"
                            tooltip={"Stop adding " + gas.name + "."}
                            onClick={() => act('stop_pumping', {
                              gas_id: gas.id,
                            })} />
                        )}
                      </Stack.Item>
                    </Stack>
                    <Divider />
                  </>
                ))}
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
