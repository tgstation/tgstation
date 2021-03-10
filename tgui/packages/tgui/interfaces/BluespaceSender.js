import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, ProgressBar, Section, Stack, Box, AnimatedNumber } from '../components';
import { getGasColor, getGasLabel } from '../constants';
import { Window } from '../layouts';

export const BluespaceSender = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    on,
    gas_transfer_rate,
    price_multiplier,
  } = data;
  const bluespace_network_gases = flow([
    filter(gas => gas.amount >= 0.01),
    sortBy(gas => -gas.amount),
  ])(data.bluespace_network_gases || []);
  const gasMax = Math.max(1, ...bluespace_network_gases.map(gas => gas.amount));
  return (
    <Window
      title="Bluespace Sender"
      width={500}
      height={600}>
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <Section
              title="Controls"
              buttons={(
                <Button
                  icon={data.on ? 'power-off' : 'times'}
                  content={data.on ? 'On' : 'Off'}
                  selected={data.on}
                  onClick={() => act('power')} />
              )}>
              <NumberInput
                animated
                value={gas_transfer_rate}
                step={0.01}
                width="63px"
                unit="moles/S"
                minValue={0}
                maxValue={1}
                onDrag={(e, value) => act('rate', {
                  rate: value,
                })} />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section scrollable title="Bluespace Network Gases">
              <LabeledList>
                {bluespace_network_gases.map(gas => (
                  <LabeledList.Item
                    key={gas.name}
                    label={getGasLabel(gas.name)}>
                    <ProgressBar
                      color={getGasColor(gas.name)}
                      value={gas.amount}
                      minValue={0}
                      maxValue={gasMax}>
                      {toFixed(gas.amount, 2) + ' moles'}
                    </ProgressBar>
                    <NumberInput
                      animated
                      value={gas.price}
                      width="63px"
                      unit={gas.price === 1 && "credit per mole" || "credits per mole"}
                      minValue={0}
                      maxValue={10}
                      onDrag={(e, value) => act('price', {
                        gas_price: value,
                        gas_type: gas.id,
                      })} />
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
