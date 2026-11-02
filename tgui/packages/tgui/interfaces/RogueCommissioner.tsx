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
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Amount = { name: string; qty: number };

type Work = {
  ref: string;
  name: string;
  category: string;
  price: number;
  material: string;
  materials: Amount[];
};

type Material = {
  path: string;
  name: string;
  price: number;
  priority: BooleanLike;
  enabled: BooleanLike;
};

type Line = { ref: string; name: string; qty: number; unit_price: number };

type Order = {
  ref: string;
  commissioner: string;
  smith: string;
  deposited: number;
  status: string;
  lines: Amount[];
  done: number;
  needed: number;
  is_commissioner: BooleanLike;
  is_smith: BooleanLike;
  days_left: number;
  note: string;
};

type Data = {
  catalog: Work[];
  percent_margin: number;
  flat_margin: number;
  item_cap: number;
  materials: Material[];
  locked: BooleanLike;
  is_guild: BooleanLike;
  escrow: number;
  my_deposit: number;
  has_active_order: BooleanLike;
  manifest: Line[];
  manifest_total: number;
  manifest_items: number;
  orders: Order[];
};

/** COMMISSIONER: the guild's commission board with an escrow box (Ratwood Commissioner.tsx). */
export const RogueCommissioner = () => {
  const { data } = useBackend<Data>();
  const [tab, setTab] = useState('catalog');
  return (
    <Window width={760} height={620}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={tab === 'catalog'}
                onClick={() => setTab('catalog')}
              >
                Catalog
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === 'manifest'}
                onClick={() => setTab('manifest')}
              >
                Manifest ({data.manifest_items})
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === 'orders'}
                onClick={() => setTab('orders')}
              >
                Orders ({data.orders.length})
              </Tabs.Tab>
              {!!data.is_guild && (
                <Tabs.Tab
                  selected={tab === 'guild'}
                  onClick={() => setTab('guild')}
                >
                  Guild
                </Tabs.Tab>
              )}
            </Tabs>
          </Stack.Item>
          {!data.locked && (
            <Stack.Item>
              <NoticeBox>
                Open for guild adjustments - turn the key to take orders again.
              </NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item grow>
            {tab === 'catalog' && <CatalogTab />}
            {tab === 'manifest' && <ManifestTab />}
            {tab === 'orders' && <OrdersTab />}
            {tab === 'guild' && <GuildTab />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const CatalogTab = () => {
  const { act, data } = useBackend<Data>();
  const categories = Array.from(
    new Set(data.catalog.map((work) => work.category)),
  ).sort();
  const [picked, setPicked] = useState('');
  const [search, setSearch] = useState('');
  const category = categories.includes(picked) ? picked : categories[0];
  const needle = search.trim().toLowerCase();
  const shown = data.catalog
    .filter((work) =>
      needle
        ? work.name.toLowerCase().includes(needle)
        : work.category === category,
    )
    .sort((a, b) => a.name.localeCompare(b.name));
  return (
    <Stack fill>
      <Stack.Item width="200px">
        <Section fill scrollable>
          <Input
            fluid
            placeholder="Search..."
            value={search}
            onChange={setSearch}
          />
          <Tabs vertical>
            {categories.map((name) => (
              <Tabs.Tab
                key={name}
                selected={!needle && name === category}
                onClick={() => setPicked(name)}
              >
                {name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={needle ? 'Search' : category || 'Nothing to commission'}
        >
          <Table>
            {shown.map((work) => (
              <Table.Row key={work.ref} className="candystripe">
                <Table.Cell>
                  {work.name}
                  <Box color="label" fontSize="0.9em">
                    {work.materials
                      .map((amount) => `${amount.qty} ${amount.name}`)
                      .join(', ')}
                  </Box>
                </Table.Cell>
                <Table.Cell collapsing>{work.price}m</Table.Cell>
                <Table.Cell collapsing>
                  <Button
                    icon="plus"
                    disabled={!data.locked}
                    onClick={() => act('manifest_add', { ref: work.ref })}
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const ManifestTab = () => {
  const { act, data } = useBackend<Data>();
  const [note, setNote] = useState('');
  return (
    <Section
      fill
      scrollable
      title={`Your deposit: ${data.my_deposit}m - manifest ${data.manifest_total}m`}
      buttons={
        <Button
          icon="coins"
          disabled={data.my_deposit <= 0}
          onClick={() => act('refund')}
        >
          Refund deposit
        </Button>
      }
    >
      {data.manifest.length === 0 && (
        <NoticeBox>Add works from the catalog, and feed coins in.</NoticeBox>
      )}
      <Table>
        {data.manifest.map((line) => (
          <Table.Row key={line.ref} className="candystripe">
            <Table.Cell>
              {line.name} x{line.qty}
            </Table.Cell>
            <Table.Cell collapsing>{line.unit_price * line.qty}m</Table.Cell>
            <Table.Cell collapsing>
              <Button
                icon="minus"
                onClick={() => act('manifest_remove', { ref: line.ref })}
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
      <Box mt={1}>
        Works: {data.manifest_items} / {data.item_cap}.
      </Box>
      <Input
        mt={1}
        fluid
        placeholder="A note for the guild..."
        value={note}
        onChange={setNote}
      />
      <Button
        mt={1}
        icon="paper-plane"
        disabled={
          !data.locked ||
          !!data.has_active_order ||
          data.manifest.length === 0 ||
          data.manifest_items > data.item_cap ||
          data.my_deposit < data.manifest_total
        }
        onClick={() => act('submit', { note })}
      >
        Post the commission
      </Button>
      {!!data.has_active_order && (
        <Box color="average" mt={1}>
          You already have an active commission here.
        </Box>
      )}
    </Section>
  );
};

const OrdersTab = () => {
  const { act, data } = useBackend<Data>();
  return (
    <Section fill scrollable title={`Held in escrow: ${data.escrow}m`}>
      {data.orders.length === 0 && <NoticeBox>No commissions posted.</NoticeBox>}
      {data.orders.map((order) => (
        <Section
          key={order.ref}
          title={`${order.commissioner} - ${order.deposited}m - ${order.status}`}
        >
          <Box>
            {order.lines.map((line) => `${line.name} x${line.qty}`).join(', ')}
          </Box>
          {!!order.note && <Box color="label">"{order.note}"</Box>}
          <Box color="label">
            Delivered {order.done}/{order.needed}
            {order.smith ? `, claimed by ${order.smith}` : ''}
            {order.status !== 'complete'
              ? `, ${order.days_left} day(s) left`
              : ''}
          </Box>
          {order.status === 'open' && !!order.is_commissioner && (
            <Button onClick={() => act('cancel', { ref: order.ref })}>
              Cancel
            </Button>
          )}
          {order.status === 'open' && !!data.is_guild && (
            <Button onClick={() => act('claim', { ref: order.ref })}>
              Claim
            </Button>
          )}
          {order.status === 'claimed' && !!order.is_smith && (
            <>
              <Button
                disabled={order.done < order.needed}
                onClick={() => act('complete', { ref: order.ref })}
              >
                Collect pay
              </Button>
              <Button
                disabled={order.done <= 0}
                onClick={() => act('settle_partial', { ref: order.ref })}
              >
                Settle in part
              </Button>
            </>
          )}
          {order.status === 'claimed' &&
            (!!order.is_smith || !!data.is_guild) && (
              <Button onClick={() => act('release', { ref: order.ref })}>
                Release claim
              </Button>
            )}
          {order.status === 'complete' && !!order.is_commissioner && (
            <Button onClick={() => act('collect', { ref: order.ref })}>
              Collect works
            </Button>
          )}
          {order.status !== 'complete' &&
            (!!data.is_guild || !!order.is_smith) && (
              <Button
                color="bad"
                onClick={() => act('reject', { ref: order.ref, reason: '' })}
              >
                Reject
              </Button>
            )}
        </Section>
      ))}
    </Section>
  );
};

const GuildTab = () => {
  const { act, data } = useBackend<Data>();
  const materials = [...data.materials].sort(
    (a, b) =>
      Number(!!b.priority) - Number(!!a.priority) ||
      a.name.localeCompare(b.name),
  );
  const locked = !!data.locked;
  return (
    <Section
      fill
      scrollable
      title="Guild settings"
      buttons={
        <Button icon={locked ? 'lock' : 'lock-open'} onClick={() => act('toggle_lock')}>
          {locked ? 'Open for adjustments' : 'Close and take orders'}
        </Button>
      }
    >
      <Box>
        Margin:{' '}
        <NumberInput
          value={data.percent_margin}
          minValue={0}
          maxValue={500}
          step={1}
          width="50px"
          disabled={locked}
          onChange={(value) => act('set_percent_margin', { value })}
        />
        % and{' '}
        <NumberInput
          value={data.flat_margin}
          minValue={0}
          maxValue={10000}
          step={1}
          width="50px"
          disabled={locked}
          onChange={(value) => act('set_flat_margin', { value })}
        />
        m a work. Works per commission:{' '}
        <NumberInput
          value={data.item_cap}
          minValue={1}
          maxValue={10}
          step={1}
          width="40px"
          disabled={locked}
          onChange={(value) => act('set_item_cap', { value })}
        />
      </Box>
      <Table mt={1}>
        {materials.map((material) => (
          <Table.Row key={material.path} className="candystripe">
            <Table.Cell>{material.name}</Table.Cell>
            <Table.Cell collapsing>
              <NumberInput
                value={material.price}
                minValue={0}
                maxValue={10000}
                step={1}
                width="50px"
                disabled={locked}
                onChange={(value) =>
                  act('set_material_price', { path: material.path, value })
                }
              />
            </Table.Cell>
            <Table.Cell collapsing>
              <Button.Checkbox
                checked={!!material.enabled}
                disabled={locked}
                onClick={() => act('toggle_material', { path: material.path })}
              >
                Worked
              </Button.Checkbox>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
