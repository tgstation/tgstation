import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { BooleanLike } from 'common/react';
import { multiline } from 'common/string';
import { useBackend } from '../backend';
import { Button, Divider, NumberInput, ProgressBar, Section, Box, LabeledList, Stack } from '../components';
import { getGasColor } from '../constants';
import { Window } from '../layouts';

type Data = {
  on: BooleanLike;
  gas_transfer_rate: number;
  bluespace_network_gases: Gas[];
  credits: number;
};

type Gas = {
  name: string;
  amount: number;
  price: number;
  id: string;
};

type GasDisplayProps = {
  gas: Gas;
  gasMax: number;
};

const mappedTopMargin = '2%';

export const BluespaceSender = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { gas_transfer_rate, credits, bluespace_network_gases = [], on } = data;

  const gases: Gas[] = flow([
    filter<Gas>((gas) => gas.amount >= 0.01),
    sortBy<Gas>((gas) => -gas.amount),
  ])(bluespace_network_gases);

  const gasMax = Math.max(1, ...gases.map((gas) => gas.amount));

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
                icon={on ? 'power-off' : 'times'}
                content={on ? 'On' : 'Off'}
                selected={on}
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
          <Box>{'The vendors have made ' + credits + ' credits so far.'}</Box>
          <Divider />
          <LabeledList>
            {gases.map((gas, index) => (
              <GasDisplay gas={gas} gasMax={gasMax} key={index} />
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

const GasDisplay = (props: GasDisplayProps, context) => {
  const { act } = useBackend<Data>(context);
  const {
    gas: { amount, id, name, price },
    gasMax,
  } = props;

  return (
    <LabeledList.Item className="candystripe" label={name}>
      <Stack fill>
        <Stack.Item grow={2}>
          <NumberInput
            animated
            fluid
            value={price}
            unit="per mole"
            minValue={0}
            maxValue={100}
            onDrag={(event, value) =>
              act('price', {
                gas_price: value,
                gas_type: id,
              })
            }
          />
        </Stack.Item>
        <Stack.Item grow={3}>
          <ProgressBar
            color={getGasColor(id)}
            value={amount}
            minValue={0}
            maxValue={gasMax}
          />
        </Stack.Item>
        <Stack.Item color="label" grow={2}>
          {toFixed(amount, 2) + ' moles'}
        </Stack.Item>
      </Stack>
    </LabeledList.Item>
  );
};
