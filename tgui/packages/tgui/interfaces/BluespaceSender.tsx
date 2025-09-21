import { sortBy } from 'es-toolkit';
import { filter } from 'es-toolkit/compat';
import {
  Box,
  Button,
  Divider,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
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

export const BluespaceSender = (props) => {
  const { act, data } = useBackend<Data>();
  const { gas_transfer_rate, credits, bluespace_network_gases = [], on } = data;

  const gases: Gas[] = sortBy(
    filter(bluespace_network_gases, (gas) => gas.amount >= 0.01),
    [(gas) => -gas.amount],
  );

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
                tooltip={`
                Any gas you pipe into here will be added to the Bluespace
                Network! That means any connected Bluespace Vendor (multitool)
                will hook up to all the gas stored in this, and charge
                this machine's price to buy it.
              `}
              />
              <NumberInput
                animated
                tickWhileDragging
                value={gas_transfer_rate}
                step={0.01}
                width="63px"
                unit="moles/S"
                minValue={0}
                maxValue={1}
                onChange={(value) =>
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
          }
        >
          <Box>{`The vendors have made ${credits} credits so far.`}</Box>
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

const GasDisplay = (props: GasDisplayProps) => {
  const { act } = useBackend<Data>();
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
            tickWhileDragging
            value={price}
            step={1}
            unit="per mole"
            minValue={0}
            maxValue={100}
            onChange={(value) =>
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
          {`${toFixed(amount, 2)} moles`}
        </Stack.Item>
      </Stack>
    </LabeledList.Item>
  );
};
