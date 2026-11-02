import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
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

type FavorEntry = {
  realm: string;
  ship: string;
  outcome: string;
  traded: number;
  expected: number;
  awarded: number;
  refunded_hail: BooleanLike;
};

type Service = {
  id: string;
  cost: number;
  owned: BooleanLike;
};

type Favor = {
  current: number;
  high: number;
  from_sendoffs: number;
  from_goldface: number;
  from_silverface: number;
  penalties: number;
  ledger: FavorEntry[];
  services: Service[];
  hailer_on: BooleanLike;
  gnome_margin: number;
};

type CatalogPack = {
  ref: string;
  name: string;
  cost: number;
  left: number;
};

type Catalog = {
  id: string;
  name: string;
  desc: string;
  favor_cost: number;
  open: BooleanLike;
  packs: CatalogPack[];
  stocked: number;
};

type Data = {
  motto: string;
  categories: string[];
  is_public: BooleanLike;
  command_center: BooleanLike;
  packs: Pack[];
  budget: number;
  tariff_rate: number;
  dodging: BooleanLike;
  proprietor: BooleanLike;
  tariff_paid: number;
  tariff_dodged: number;
  favor?: Favor;
  catalogs?: Catalog[];
};

const SERVICES: Record<string, [string, string]> = {
  pier: ['Extra pier', 'One more ship may lie at the harbor.'],
  hailer: [
    'Harbor crew',
    'Hails offshore ships into free piers and sends off the satisfied or overstaying ones.',
  ],
  gnomes: [
    'Company gnomes',
    "Collect the public SILVERFACEs' margin for the merchant fund.",
  ],
};

/** The company's favor, its services and its catalogs (Ratwood Goldface.tsx favor and catalog tabs). */
const Company = () => {
  const { act, data } = useBackend<Data>();
  const favor = data.favor;
  if (!favor) {
    return null;
  }
  const tariff = (cost: number) => Math.floor(data.tariff_rate * cost);
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Favor with the Ferentian Trading Company">
          <LabeledList>
            <LabeledList.Item label="Favor">
              {favor.current} (highest {favor.high})
            </LabeledList.Item>
            <LabeledList.Item label="Earned">
              ships {favor.from_sendoffs}, GOLDFACE {favor.from_goldface},
              SILVERFACE {favor.from_silverface}; lost {favor.penalties}
            </LabeledList.Item>
            {favor.gnome_margin > 0 && (
              <LabeledList.Item label="Gnomes' margin">
                {favor.gnome_margin}m
              </LabeledList.Item>
            )}
          </LabeledList>
          <Table mt={1}>
            {favor.services.map((service) => {
              const [label, tooltip] = SERVICES[service.id] || [
                service.id,
                '',
              ];
              return (
                <Table.Row key={service.id} className="candystripe">
                  <Table.Cell>{label}</Table.Cell>
                  <Table.Cell color="label">{tooltip}</Table.Cell>
                  <Table.Cell collapsing>
                    {service.owned ? (
                      service.id === 'hailer' ? (
                        <Button.Checkbox
                          checked={!!favor.hailer_on}
                          onClick={() => act('toggle_hailer')}
                        >
                          Working
                        </Button.Checkbox>
                      ) : (
                        <Box color="good">Retained</Box>
                      )
                    ) : (
                      <Button
                        disabled={favor.current < service.cost}
                        onClick={() => act('upgrade', { id: service.id })}
                      >
                        {service.cost} favor
                      </Button>
                    )}
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title="Catalogs">
          {(data.catalogs || []).map((catalog) => (
            <Section
              key={catalog.id}
              title={catalog.name}
              buttons={
                !catalog.open && (
                  <Button
                    disabled={favor.current < catalog.favor_cost}
                    onClick={() => act('unlock_catalog', { id: catalog.id })}
                  >
                    Open for {catalog.favor_cost} favor
                  </Button>
                )
              }
            >
              <Box color="label">{catalog.desc}</Box>
              {catalog.packs.length === 0 && (
                <NoticeBox mt={1}>
                  None of its {catalog.stocked} wares reach the realm yet.
                </NoticeBox>
              )}
              {!!catalog.open && catalog.packs.length > 0 && (
                <Table mt={1}>
                  {catalog.packs.map((pack) => {
                    const price = pack.cost + tariff(pack.cost);
                    return (
                      <Table.Row key={pack.ref} className="candystripe">
                        <Table.Cell>{pack.name}</Table.Cell>
                        <Table.Cell collapsing>{pack.left} left</Table.Cell>
                        <Table.Cell collapsing>{price}m</Table.Cell>
                        <Table.Cell collapsing>
                          <Button
                            disabled={pack.left <= 0 || price > data.budget}
                            onClick={() =>
                              act('catalog_buy', {
                                id: catalog.id,
                                ref: pack.ref,
                              })
                            }
                          >
                            Buy
                          </Button>
                        </Table.Cell>
                      </Table.Row>
                    );
                  })}
                </Table>
              )}
            </Section>
          ))}
          {favor.ledger.length > 0 && (
            <Section title="Last ships">
              <Table>
                {favor.ledger.map((entry, index) => (
                  <Table.Row key={index} className="candystripe">
                    <Table.Cell>
                      {entry.ship} ({entry.realm})
                    </Table.Cell>
                    <Table.Cell collapsing>
                      {entry.traded}/{entry.expected}m
                    </Table.Cell>
                    <Table.Cell
                      collapsing
                      color={entry.awarded < 0 ? 'bad' : 'good'}
                    >
                      {entry.outcome} {entry.awarded > 0 ? '+' : ''}
                      {entry.awarded}
                      {!!entry.refunded_hail && ', hail back'}
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

/** GOLDFACE: the merchant's import catalog (Ratwood Goldface.tsx; the harbor is the ship fulfillment crate). */
export const RogueGoldface = () => {
  const { act, data } = useBackend<Data>();
  const categories = data.categories || [];
  const [picked, setCategory] = useState('');
  const [search, setSearch] = useState('');
  const [page, setPage] = useState('imports');
  const category = categories.includes(picked) ? picked : categories[0];
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
  const company = !!data.command_center && !!data.proprietor && !!data.favor;
  return (
    <Window width={720} height={620}>
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
                  Budget: <b>{data.budget}</b> mammons. Crown import tariff:{' '}
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
              {company && (
                <Tabs mt={1}>
                  <Tabs.Tab
                    selected={page === 'imports'}
                    onClick={() => setPage('imports')}
                  >
                    Imports
                  </Tabs.Tab>
                  <Tabs.Tab
                    selected={page === 'company'}
                    onClick={() => setPage('company')}
                  >
                    The Company (favor {data.favor?.current})
                  </Tabs.Tab>
                </Tabs>
              )}
              {(!company || page === 'imports') && (
                <Input
                  mt={1}
                  fluid
                  placeholder="Search the catalog..."
                  value={search}
                  onChange={setSearch}
                />
              )}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            {company && page === 'company' ? (
              <Company />
            ) : (
              <Stack fill>
                {!needle && (
                  <Stack.Item width="190px">
                    <Section fill scrollable>
                      <Tabs vertical>
                        {categories.map((name) => (
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
                  <Section
                    fill
                    scrollable
                    title={needle ? 'Search' : category}
                  >
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
                </Stack.Item>
              </Stack>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
