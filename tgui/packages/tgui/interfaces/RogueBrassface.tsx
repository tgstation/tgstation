import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Pack = {
  ref: string;
  name: string;
  category: string;
  qty: number;
  cost: number;
  base: number;
};

type HoardEntry = {
  kind: string;
  time: string;
  text: string;
  amount: number;
  who: string | null;
};

type Data = {
  motto: string;
  categories: string[];
  packs: Pack[];
  budget: number;
  tariff_rate: number;
  dodging: BooleanLike;
  proprietor: BooleanLike;
  tariff_paid: number;
  tariff_dodged: number;
  hoard_paid: number;
  hoard_log: HoardEntry[];
};

/** BRASSFACE: the bathhouse's import machine and its hoard ledger (Ratwood Brassface.tsx). */
export const RogueBrassface = () => {
  const { act, data } = useBackend<Data>();
  const categories = data.categories || [];
  const [picked, setCategory] = useState('');
  const [search, setSearch] = useState('');
  const hoard = 'The Hoard';
  const tabs = data.proprietor ? [...categories, hoard] : categories;
  const category = tabs.includes(picked) ? picked : tabs[0];
  const needle = search.trim().toLowerCase();
  const shown = (data.packs || [])
    .filter((pack) =>
      needle
        ? pack.name.toLowerCase().includes(needle) ||
          pack.category.toLowerCase().includes(needle)
        : pack.category === category,
    )
    .sort((a, b) => a.name.localeCompare(b.name));
  const tariff = (pack: Pack) => Math.floor(data.tariff_rate * pack.cost);
  return (
    <Window width={720} height={600}>
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
              <Stack align="center">
                <Stack.Item grow>
                  Budget: <b>{data.budget}</b> mammons. Import tariff:{' '}
                  {Math.round(data.tariff_rate * 100)}%.
                </Stack.Item>
                {!!data.proprietor && (
                  <Stack.Item>
                    <Button.Checkbox
                      checked={!!data.dodging}
                      onClick={() => act('toggle_tariff')}
                    >
                      Stop paying taxes
                    </Button.Checkbox>
                  </Stack.Item>
                )}
              </Stack>
              {!!data.proprietor && (
                <Box mt={1} color="label">
                  Tariff paid here: {data.tariff_paid}m, dodged:{' '}
                  {data.tariff_dodged}m.
                </Box>
              )}
              <Input
                mt={1}
                fluid
                placeholder="Search the catalog..."
                value={search}
                onChange={setSearch}
              />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              {!needle && (
                <Stack.Item width="190px">
                  <Section fill scrollable>
                    <Tabs vertical>
                      {tabs.map((name) => (
                        <Tabs.Tab
                          key={name}
                          selected={name === category}
                          onClick={() => setCategory(name)}
                        >
                          {name}
                        </Tabs.Tab>
                      ))}
                    </Tabs>
                  </Section>
                </Stack.Item>
              )}
              <Stack.Item grow>
                {!needle && category === hoard ? (
                  <Section
                    fill
                    scrollable
                    title={`The Hoard - paid to the Bathhouse Fund: ${data.hoard_paid}m`}
                  >
                    {data.hoard_log.length === 0 && (
                      <NoticeBox>The ledger is empty.</NoticeBox>
                    )}
                    {data.hoard_log.map((entry, index) => (
                      <Box
                        key={index}
                        color={entry.kind === 'payout' ? 'good' : undefined}
                      >
                        [{entry.time}]{' '}
                        {entry.kind === 'payout' ? 'PAYOUT' : 'CONSIGNED'}:{' '}
                        {entry.text} - {entry.amount}m
                        {entry.who ? ` (${entry.who})` : ''}
                      </Box>
                    ))}
                  </Section>
                ) : (
                  <Section fill scrollable title={needle ? 'Search' : category}>
                    {shown.length === 0 && (
                      <NoticeBox>Nothing to import here.</NoticeBox>
                    )}
                    <Table>
                      {shown.map((pack) => {
                        const price = pack.base + tariff(pack);
                        return (
                          <Table.Row key={pack.ref} className="candystripe">
                            <Table.Cell>
                              {pack.name}
                              {pack.qty > 1 && ` x${pack.qty}`}
                            </Table.Cell>
                            <Table.Cell collapsing>
                              {price}m
                              {tariff(pack) > 0 && (
                                <Box inline color="label">
                                  &nbsp;(+{tariff(pack)} tariff)
                                </Box>
                              )}
                            </Table.Cell>
                            <Table.Cell collapsing>
                              <Button
                                disabled={price > data.budget}
                                onClick={() => act('buy', { ref: pack.ref })}
                              >
                                Buy
                              </Button>
                            </Table.Cell>
                          </Table.Row>
                        );
                      })}
                    </Table>
                  </Section>
                )}
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
