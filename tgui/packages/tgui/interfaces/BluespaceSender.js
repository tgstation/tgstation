import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Button, Divider, LabeledList, NumberInput, ProgressBar, Section, Stack, Box } from '../components';
import { getGasColor, getGasLabel } from '../constants';
import { Window } from '../layouts';

const mappedTopMargin = '2%';

export const BluespaceSender = (props, context) => {
  const { act, data } = useBackend(context);
  const { on, gas_transfer_rate, price_multiplier } = data;
  const bluespace_network_gases = flow([
    filter((gas) => gas.amount >= 0.01),
    sortBy((gas) => -gas.amount),
  ])(data.bluespace_network_gases || []);
  const gasMax = Math.max(
    1,
    ...bluespace_network_gases.map((gas) => gas.amount)
  );
  return (
    <Window title="Bluespace Sender" width={500} height={600}>
      <Window.Content>
        <Section
          scrollable
          fill
          title="Bluespace Network Gases"
          buttons={
            <>
              <Button
                mr={0.5}
                color="transparent"
                icon="info"
                tooltipPosition="bottom-start"
                tooltip={multiline`
                Any gas you pipe into here will be added to the Bluespace
                Network! That means any connected Bluespace Vendor (multitool)
                will hook up to all the gas stored in this, and charge
                this machine's price to buy it.
              `}
              />
              <NumberInput
                animated
                value={gas_transfer_rate}
                step={0.01}
                width="63px"
                unit="moles/S"
                minValue={0}
                maxValue={1}
                onDrag={(e, value) =>
                  act('rate', {
                    rate: value,
                  })
                }
              />
              <Button
                ml={0.5}
                icon={data.on ? 'power-off' : 'times'}
                content={data.on ? 'On' : 'Off'}
                selected={data.on}
                tooltipPosition="bottom-start"
                tooltip="Will only take in gases while on."
                onClick={() => act('power')}
              />
              <Button
                ml={0.5}
                content="Retrieve gases"
                tooltipPosition="bottom-start"
                tooltip="Will transfer any gases inside to the pipe."
                onClick={() => act('retrieve')}
              />
            </>
          }>
          <Box>
            {'The vendors have made ' + data.credits + ' credits so far.'}
          </Box>
          <Divider />
          <LabeledList>
            {bluespace_network_gases.map((gas) => (
              <>
                <Stack key={gas.name}>
                  <Stack.Item color="label" basis={10} ml={1}>
                    {getGasLabel(gas.name) + ' prices: '}
                    <br />
                    <Box mt={0.25}>
                      <NumberInput
                        animated
                        value={gas.price}
                        width="63px"
                        unit="per mole"
                        minValue={0}
                        maxValue={100}
                        onDrag={(e, value) =>
                          act('price', {
                            gas_price: value,
                            gas_type: gas.id,
                          })
                        }
                      />
                    </Box>
                  </Stack.Item>
                  <Stack.Item grow mt={mappedTopMargin} mr={1}>
                    <ProgressBar
                      color={getGasColor(gas.name)}
                      value={gas.amount}
                      minValue={0}
                      maxValue={gasMax}>
                      {toFixed(gas.amount, 2) + ' moles'}
                    </ProgressBar>
                  </Stack.Item>
                </Stack>
                <Divider />
              </>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
