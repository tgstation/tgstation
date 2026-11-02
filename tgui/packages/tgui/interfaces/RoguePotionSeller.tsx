import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Potion = {
  ref: string;
  name: string;
  price: number;
  volume: number;
};

type Data = {
  owner_mode: BooleanLike;
  budget: number;
  profits: number;
  bottle_price: number;
  bottles_left: number;
  inserted: { name: string; volume: number; max: number } | null;
  potions: Potion[];
};

/** POTION SELLER, FIRST ITERATION: potions by the dram (Ratwood potionseller.dm). */
export const RoguePotionSeller = () => {
  const { act, data } = useBackend<Data>();
  const [drams, setDrams] = useState<Record<string, number>>({});
  const amountOf = (potion: Potion) => drams[potion.ref] ?? 10;
  const owner = !!data.owner_mode;
  return (
    <Window width={540} height={520}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="POTION SELLER, FIRST ITERATION">
              {owner ? (
                <Stack align="center">
                  <Stack.Item grow>
                    UNLOCKED. Stored profits: <b>{data.profits}</b>m.
                  </Stack.Item>
                  <Stack.Item>
                    Bottle price:{' '}
                    <NumberInput
                      value={data.bottle_price}
                      minValue={0}
                      maxValue={10000}
                      step={1}
                      width="50px"
                      onChange={(value) =>
                        act('set_bottle_price', { price: value })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="coins"
                      disabled={data.profits <= 0}
                      onClick={() => act('withdraw_profits')}
                    >
                      Withdraw
                    </Button>
                  </Stack.Item>
                </Stack>
              ) : (
                <Stack align="center">
                  <Stack.Item grow>
                    Stored mammon: <b>{data.budget}</b>.{' '}
                    {data.inserted
                      ? `Container: ${data.inserted.name} (${data.inserted.volume}/${data.inserted.max} drams)`
                      : 'No container inserted.'}
                  </Stack.Item>
                  <Stack.Item>
                    {data.inserted ? (
                      <Button icon="eject" onClick={() => act('eject')}>
                        Eject
                      </Button>
                    ) : (
                      <Button
                        disabled={data.bottles_left < 1}
                        onClick={() => act('buy_bottle')}
                      >
                        {data.bottle_price
                          ? `Buy bottle for ${data.bottle_price}m`
                          : 'Take a FREE bottle'}{' '}
                        ({data.bottles_left} left)
                      </Button>
                    )}
                    <Button
                      icon="coins"
                      disabled={data.budget <= 0}
                      onClick={() => act('change')}
                    >
                      Change
                    </Button>
                  </Stack.Item>
                </Stack>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable title="Potions">
              {data.potions.length === 0 && (
                <NoticeBox>The vat is empty.</NoticeBox>
              )}
              <Table>
                {data.potions.map((potion) => (
                  <Table.Row key={potion.ref} className="candystripe">
                    <Table.Cell>
                      {owner ? (
                        <Input
                          value={potion.name}
                          onBlur={(value) =>
                            act('set_name', { ref: potion.ref, name: value })
                          }
                        />
                      ) : (
                        potion.name
                      )}
                    </Table.Cell>
                    <Table.Cell collapsing>{potion.volume} drams</Table.Cell>
                    <Table.Cell collapsing>
                      {owner ? (
                        <NumberInput
                          value={potion.price}
                          minValue={0}
                          maxValue={10000}
                          step={0.1}
                          width="50px"
                          onChange={(value) =>
                            act('set_price', { ref: potion.ref, price: value })
                          }
                        />
                      ) : potion.price ? (
                        `${potion.price}m per dram`
                      ) : (
                        'FREE'
                      )}
                    </Table.Cell>
                    <Table.Cell collapsing>
                      <NumberInput
                        value={amountOf(potion)}
                        minValue={1}
                        maxValue={Math.max(1, potion.volume)}
                        step={1}
                        width="40px"
                        onChange={(value) =>
                          setDrams({ ...drams, [potion.ref]: value })
                        }
                      />
                    </Table.Cell>
                    <Table.Cell collapsing>
                      {owner ? (
                        <Button
                          onClick={() =>
                            act('retrieve', {
                              ref: potion.ref,
                              amount: amountOf(potion),
                            })
                          }
                        >
                          Take
                        </Button>
                      ) : (
                        <Button
                          disabled={!data.inserted}
                          onClick={() =>
                            act('buy', {
                              ref: potion.ref,
                              amount: amountOf(potion),
                            })
                          }
                        >
                          {potion.price ? 'Buy' : 'Take'}
                        </Button>
                      )}
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
              {!owner && (
                <Box mt={1} color="label">
                  Insert coins and a bottle, then pick how many drams to pour.
                </Box>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
