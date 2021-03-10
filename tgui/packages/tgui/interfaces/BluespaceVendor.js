import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Button, Divider, LabeledList, NumberInput, ProgressBar, Section, Stack, Box } from '../components';
import { getGasColor, getGasLabel } from '../constants';
import { Window } from '../layouts';

export const BluespaceVendor = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    on,
    gas_transfer_rate,
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
            title="Controls">
              <NumberInput
                animated
                value={gas_transfer_rate}
                width="63px"
                unit="% of tank filled"
                minValue={0}
                maxValue={100}
                onDrag={(e, value) => act('pumping_rate', {
                  rate: value,
                })} />
              <Button
                ml={1}
                icon="plus"
                content="Prepare Tank"
                disabled={data.pumping || data.inserted_tank || !data.tank_amount}
                onClick={() => act('tank_prepare')} />
              <Button
                ml={1}
                icon="minus"
                content="Remove Tank"
                disabled={data.pumping || !data.inserted_tank}
                onClick={() => act('tank_expel'
                )} />
              <Box>
                {
                  <ProgressBar
                    value={data.tank_full / 1010}
                    ranges={{
                      good: [0.67, 1],
                      average: [0.34, 0.66],
                      bad: [0, 0.33],
                    }} />
                }
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section scrollable fill title="Bluespace Network Gases">
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
                          disabled={data.pumping || !data.inserted_tank}
                          onClick={() => act('start_pumping', {
                            gas_id: gas.id,
                          })} />
                        ) || (
                          <Button
                          ml={1}
                          icon="minus"
                          content="Stop Pumping"
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
