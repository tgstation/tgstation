import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Ware = {
  ref: string;
  name: string;
  price_base: number;
  price_tariff: number;
};

type Data = {
  motto: string;
  budget: number;
  is_proprietor: BooleanLike;
  dodging: BooleanLike;
  tariff_rate_pct: number;
  tariff_paid: number;
  tariff_evaded: number;
  cut_pct: number;
  cut_tier: number;
  recent_payments: number;
  secret_budget: number;
  upgrade_a_cost: number;
  upgrade_b_cost: number;
  withdraw_tax: number;
  withdraw_net: number;
  items: Ware[];
};

/** PURITY: the bathhouse's vice machine (Ratwood Purity.tsx). */
export const RoguePurity = () => {
  const { act, data } = useBackend<Data>();
  const items = [...(data.items || [])].sort((a, b) =>
    a.name.localeCompare(b.name),
  );
  return (
    <Window width={520} height={560}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section
              title={data.motto}
              buttons={
                <Button
                  icon="coins"
                  disabled={data.budget <= 0}
                  onClick={() => act('change')}
                >
                  Change
                </Button>
              }
            >
              Budget: <b>{data.budget}</b> mammons. Crown import tariff:{' '}
              {data.dodging ? 'dodged' : `${data.tariff_rate_pct}%`}.
            </Section>
          </Stack.Item>
          {!!data.is_proprietor && (
            <Stack.Item>
              <Section title="The Master's Ledger">
                <LabeledList>
                  <LabeledList.Item label="Cut">
                    {data.cut_pct}% of the takings
                  </LabeledList.Item>
                  <LabeledList.Item label="Takings since the last cut">
                    {data.recent_payments}m
                  </LabeledList.Item>
                  <LabeledList.Item label="Secret purse">
                    {data.secret_budget}m
                  </LabeledList.Item>
                  <LabeledList.Item label="Tariff">
                    paid {data.tariff_paid}m, dodged {data.tariff_evaded}m
                  </LabeledList.Item>
                </LabeledList>
                <Box mt={1}>
                  <Button.Checkbox
                    checked={!!data.dodging}
                    onClick={() => act('toggle_tax')}
                  >
                    Stop paying taxes
                  </Button.Checkbox>
                  {data.cut_tier < 1 && (
                    <Button onClick={() => act('unlock_cut', { level: 'a' })}>
                      Quarter cut ({data.upgrade_a_cost}m)
                    </Button>
                  )}
                  {data.cut_tier === 1 && (
                    <Button onClick={() => act('unlock_cut', { level: 'b' })}>
                      Half cut ({data.upgrade_b_cost}m)
                    </Button>
                  )}
                </Box>
                <Box mt={1}>
                  <Button
                    disabled={data.withdraw_net < 1}
                    onClick={() => act('withdraw_cut', { mode: 'bank' })}
                  >
                    Bank {data.withdraw_net}m (Crown keeps {data.withdraw_tax}m)
                  </Button>
                  <Button
                    disabled={data.secret_budget < 1}
                    onClick={() => act('withdraw_cut', { mode: 'direct' })}
                  >
                    Take {data.secret_budget}m in coin
                  </Button>
                </Box>
              </Section>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Section fill scrollable title="Vices">
              {items.length === 0 && <NoticeBox>Nothing for sale.</NoticeBox>}
              <Table>
                {items.map((ware) => {
                  const price = ware.price_base + ware.price_tariff;
                  return (
                    <Table.Row key={ware.ref} className="candystripe">
                      <Table.Cell>{ware.name}</Table.Cell>
                      <Table.Cell collapsing>
                        {price}m
                        {ware.price_tariff > 0 && (
                          <Box inline color="label">
                            &nbsp;(+{ware.price_tariff} tariff)
                          </Box>
                        )}
                      </Table.Cell>
                      <Table.Cell collapsing>
                        <Button
                          disabled={price > data.budget}
                          onClick={() => act('buy', { ref: ware.ref })}
                        >
                          Buy
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  );
                })}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
