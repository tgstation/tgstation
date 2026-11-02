import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Fund = { id: string; name: string; balance: number };
type Levy = { name: string; percent: number };
type Wage = { job: string; wage: number };
type Account = {
  ref: string;
  name: string;
  job: string;
  alive: BooleanLike;
  poll_class: string;
  balance: number;
  estate: number;
  poll_owed: number;
  advance: number;
  wages_suspended: BooleanLike;
  loan: number;
  defaulted: BooleanLike;
};
type Charter = {
  id: string;
  name: string;
  active: BooleanLike;
  suspended: BooleanLike;
};
type Stock = {
  ref: string;
  name: string;
  category: string;
  amount: number;
  limit: number;
  base_price: number;
  payout: number;
  withdraw: number;
  export: number;
  passive: number;
  accepting: BooleanLike;
  autoexport: BooleanLike;
};
type Good = {
  id: string;
  name: string;
  base_price: number;
  mod: number;
  stocked: BooleanLike;
};

type Data = {
  day: number;
  state: string;
  debt: number;
  bankruptcies: number;
  floor: number;
  autoexport: number;
  wage_outlay: number;
  hoard_paid: number;
  totals: Record<string, number>;
  funds: Fund[];
  levies: Levy[];
  wages: Wage[];
  accounts: Account[];
  charters: Charter[];
  stock: Stock[];
  stock_categories: string[];
  goods: Good[];
  ships: number;
  hails: number;
  orders: number;
  ledger: { amount: number; reason: string }[];
};

/** Economic Panel: the admin's view of the realm's money (Ratwood EconomicPanel.tsx, for what is ported). */
export const RogueEconomicPanel = () => {
  const [tab, setTab] = useState('treasury');
  const tabs = [
    ['treasury', 'Treasury'],
    ['accounts', 'Subjects'],
    ['charters', 'Charters'],
    ['stock', 'Stockpile'],
    ['trade', 'Trade'],
  ];
  return (
    <Window width={900} height={680}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              {tabs.map(([id, label]) => (
                <Tabs.Tab
                  key={id}
                  selected={tab === id}
                  onClick={() => setTab(id)}
                >
                  {label}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {tab === 'treasury' && <TreasuryTab />}
            {tab === 'accounts' && <AccountsTab />}
            {tab === 'charters' && <ChartersTab />}
            {tab === 'stock' && <StockTab />}
            {tab === 'trade' && <TradeTab />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const TreasuryTab = () => {
  const { act, data } = useBackend<Data>();
  const [amount, setAmount] = useState(100);
  const ticks = [
    ['rural', 'Rural tax'],
    ['estates', 'Estates'],
    ['payroll', 'Payroll'],
    ['loans', 'Loans'],
    ['poll', 'Poll tax'],
    ['stockpile', 'Stockpile import/export'],
    ['trade', 'Trade day'],
    ['hoard', 'Bathhouse hoard'],
  ];
  return (
    <Stack fill>
      <Stack.Item grow>
        <Section fill scrollable title={`Day ${data.day} - ${data.state}`}>
          <LabeledList>
            <LabeledList.Item label="Crown's debt">{data.debt}m</LabeledList.Item>
            <LabeledList.Item label="Sequestrations">
              {data.bankruptcies}
            </LabeledList.Item>
            <LabeledList.Item label="Wages due at dawn">
              {data.wage_outlay}m
            </LabeledList.Item>
            <LabeledList.Item label="Stockpile floor">
              <NumberInput
                value={data.floor}
                minValue={0}
                maxValue={100000}
                step={50}
                width="70px"
                onChange={(value) => act('set_floor', { amount: value })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Autoexport above">
              {data.autoexport}% of a good's limit
            </LabeledList.Item>
            <LabeledList.Item label="Hoard paid">{data.hoard_paid}m</LabeledList.Item>
          </LabeledList>
          <Section title="Funds">
            Amount:{' '}
            <NumberInput
              value={amount}
              minValue={1}
              maxValue={10000}
              step={10}
              width="70px"
              onChange={setAmount}
            />
            <Table mt={1}>
              {data.funds.map((fund) => (
                <Table.Row key={fund.id} className="candystripe">
                  <Table.Cell>{fund.name}</Table.Cell>
                  <Table.Cell collapsing>{fund.balance}m</Table.Cell>
                  <Table.Cell collapsing>
                    <Button onClick={() => act('mint_fund', { id: fund.id, amount })}>
                      Mint
                    </Button>
                    <Button onClick={() => act('burn_fund', { id: fund.id, amount })}>
                      Burn
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
          <Section title="Levies">
            <Table>
              {data.levies.map((levy) => (
                <Table.Row key={levy.name}>
                  <Table.Cell>{levy.name}</Table.Cell>
                  <Table.Cell collapsing>
                    <NumberInput
                      value={levy.percent}
                      minValue={0}
                      maxValue={100}
                      step={1}
                      width="50px"
                      onChange={(value) =>
                        act('set_levy', { name: levy.name, amount: value })
                      }
                    />
                    %
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
          <Section title="Wages">
            <Table>
              {data.wages.map((wage) => (
                <Table.Row key={wage.job}>
                  <Table.Cell>{wage.job}</Table.Cell>
                  <Table.Cell collapsing>
                    <NumberInput
                      value={wage.wage}
                      minValue={0}
                      maxValue={1000}
                      step={1}
                      width="50px"
                      onChange={(value) =>
                        act('set_wage', { job: wage.job, amount: value })
                      }
                    />
                    m
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        </Section>
      </Stack.Item>
      <Stack.Item width="330px">
        <Section title="Dawn business">
          <Button fluid icon="sun" onClick={() => act('advance_day')}>
            Advance the day (all of it)
          </Button>
          {ticks.map(([id, label]) => (
            <Button key={id} onClick={() => act('fire', { tick: id })}>
              {label}
            </Button>
          ))}
        </Section>
        <Section title="Solvency">
          <Button onClick={() => act('force_arrears')}>Force arrears</Button>
          <Button color="bad" onClick={() => act('force_sequestration')}>
            Force sequestration
          </Button>
          <Button color="good" onClick={() => act('force_recovery')}>
            Clear debt
          </Button>
        </Section>
        <Section title="Totals">
          <LabeledList>
            {Object.keys(data.totals).map((label) => (
              <LabeledList.Item key={label} label={label}>
                {data.totals[label]}m
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
        <Section title="Crown's ledger" scrollable height="160px">
          {data.ledger.map((entry, index) => (
            <Box key={index} color={entry.amount < 0 ? 'bad' : 'good'}>
              {entry.amount > 0 ? '+' : ''}
              {entry.amount}m {entry.reason}
            </Box>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const AccountsTab = () => {
  const { act, data } = useBackend<Data>();
  const [amount, setAmount] = useState(50);
  const [search, setSearch] = useState('');
  const needle = search.trim().toLowerCase();
  const shown = data.accounts.filter(
    (account) =>
      !needle ||
      account.name.toLowerCase().includes(needle) ||
      account.job.toLowerCase().includes(needle) ||
      account.poll_class.toLowerCase().includes(needle),
  );
  return (
    <Section
      fill
      scrollable
      title={`Accounts (${data.accounts.length})`}
      buttons={
        <>
          <Input placeholder="Filter..." value={search} onChange={setSearch} />{' '}
          Amount:{' '}
          <NumberInput
            value={amount}
            minValue={1}
            maxValue={10000}
            step={10}
            width="60px"
            onChange={setAmount}
          />
        </>
      }
    >
      <Table>
        <Table.Row header>
          <Table.Cell>Name</Table.Cell>
          <Table.Cell>Role</Table.Cell>
          <Table.Cell>Class</Table.Cell>
          <Table.Cell collapsing>Balance</Table.Cell>
          <Table.Cell collapsing>Poll owed</Table.Cell>
          <Table.Cell collapsing>Advance</Table.Cell>
          <Table.Cell collapsing>Loan</Table.Cell>
          <Table.Cell collapsing />
        </Table.Row>
        {shown.map((account) => (
          <Table.Row key={account.ref} className="candystripe">
            <Table.Cell color={account.alive ? undefined : 'label'}>
              {account.name}
            </Table.Cell>
            <Table.Cell>{account.job}</Table.Cell>
            <Table.Cell>{account.poll_class}</Table.Cell>
            <Table.Cell collapsing>{account.balance}m</Table.Cell>
            <Table.Cell collapsing>{account.poll_owed}m</Table.Cell>
            <Table.Cell collapsing>{account.advance}d</Table.Cell>
            <Table.Cell collapsing color={account.defaulted ? 'bad' : undefined}>
              {account.loan ? `${account.loan}m` : ''}
            </Table.Cell>
            <Table.Cell collapsing>
              <Button onClick={() => act('mint_account', { ref: account.ref, amount })}>
                +
              </Button>
              <Button onClick={() => act('burn_account', { ref: account.ref, amount })}>
                -
              </Button>
              <Button
                disabled={account.poll_owed <= 0}
                onClick={() => act('clear_debt', { ref: account.ref })}
              >
                Clear debt
              </Button>
              <Button onClick={() => act('advance', { ref: account.ref, amount: 1 })}>
                +1d
              </Button>
              <Button onClick={() => act('advance', { ref: account.ref, amount: -1 })}>
                -1d
              </Button>
              <Button.Checkbox
                checked={!account.wages_suspended}
                onClick={() => act('toggle_wages', { ref: account.ref })}
              >
                Wages
              </Button.Checkbox>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const ChartersTab = () => {
  const { act, data } = useBackend<Data>();
  return (
    <Section fill scrollable title="Charters of the realm">
      <Table>
        {data.charters.map((charter) => (
          <Table.Row key={charter.id} className="candystripe">
            <Table.Cell>
              {charter.name}
              {!!charter.suspended && (
                <Box inline color="average">
                  &nbsp;(suspended by sequestration)
                </Box>
              )}
            </Table.Cell>
            <Table.Cell collapsing>
              <Button.Checkbox
                checked={!!charter.active}
                onClick={() => act('toggle_charter', { id: charter.id })}
              >
                In force
              </Button.Checkbox>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const StockTab = () => {
  const { act, data } = useBackend<Data>();
  const [category, setCategory] = useState('');
  const shown = data.stock.filter(
    (entry) => !category || entry.category === category,
  );
  const number = (entry: Stock, field: string, value: number, step = 1) => (
    <NumberInput
      value={value}
      minValue={0}
      maxValue={100000}
      step={step}
      width="50px"
      onChange={(next) => act('set_stock', { ref: entry.ref, field, value: next })}
    />
  );
  return (
    <Stack fill>
      <Stack.Item width="170px">
        <Section fill scrollable title="Categories">
          <Tabs vertical>
            <Tabs.Tab selected={!category} onClick={() => setCategory('')}>
              All
            </Tabs.Tab>
            {data.stock_categories.map((name) => (
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
      <Stack.Item grow>
        <Section fill scrollable title="Goods of the stockpile">
          <Table>
            <Table.Row header>
              <Table.Cell>Good</Table.Cell>
              <Table.Cell>Category</Table.Cell>
              <Table.Cell collapsing>Held/limit</Table.Cell>
              <Table.Cell collapsing>Trade price</Table.Cell>
              <Table.Cell collapsing>Pays/sells/exports</Table.Cell>
              <Table.Cell collapsing>Imports</Table.Cell>
              <Table.Cell collapsing />
            </Table.Row>
            {shown.map((entry) => (
              <Table.Row key={entry.ref} className="candystripe">
                <Table.Cell>{entry.name}</Table.Cell>
                <Table.Cell>
                  <Input
                    width="110px"
                    value={entry.category}
                    onBlur={(value) =>
                      act('set_stock', {
                        ref: entry.ref,
                        field: 'category',
                        value,
                      })
                    }
                  />
                </Table.Cell>
                <Table.Cell collapsing>
                  {number(entry, 'amount', entry.amount)}
                  {number(entry, 'limit', entry.limit)}
                </Table.Cell>
                <Table.Cell collapsing>
                  {number(entry, 'base_price', entry.base_price)}
                </Table.Cell>
                <Table.Cell collapsing>
                  {number(entry, 'payout', entry.payout)}
                  {number(entry, 'withdraw', entry.withdraw)}
                  {number(entry, 'export', entry.export)}
                </Table.Cell>
                <Table.Cell collapsing>
                  {number(entry, 'passive', entry.passive)}
                </Table.Cell>
                <Table.Cell collapsing>
                  <Button.Checkbox
                    checked={!!entry.accepting}
                    onClick={() =>
                      act('set_stock', { ref: entry.ref, field: 'accepting' })
                    }
                  >
                    Buys
                  </Button.Checkbox>
                  <Button.Checkbox
                    checked={!!entry.autoexport}
                    onClick={() =>
                      act('set_stock', { ref: entry.ref, field: 'autoexport' })
                    }
                  >
                    Exports
                  </Button.Checkbox>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const TradeTab = () => {
  const { act, data } = useBackend<Data>();
  const goods = [...data.goods].sort((a, b) => a.name.localeCompare(b.name));
  return (
    <Stack fill>
      <Stack.Item grow>
        <Section fill scrollable title="Trade goods">
          <Table>
            <Table.Row header>
              <Table.Cell>Good</Table.Cell>
              <Table.Cell collapsing>Base price</Table.Cell>
              <Table.Cell collapsing>Crown's factor</Table.Cell>
            </Table.Row>
            {goods.map((good) => (
              <Table.Row key={good.id} className="candystripe">
                <Table.Cell>
                  {good.name}
                  {!!good.stocked && (
                    <Box inline color="label">
                      &nbsp;(stockpiled)
                    </Box>
                  )}
                </Table.Cell>
                <Table.Cell collapsing>
                  <NumberInput
                    value={good.base_price}
                    minValue={1}
                    maxValue={10000}
                    step={1}
                    width="55px"
                    onChange={(value) =>
                      act('set_good', {
                        id: good.id,
                        field: 'base',
                        amount: value,
                      })
                    }
                  />
                </Table.Cell>
                <Table.Cell collapsing>
                  <NumberInput
                    value={good.mod}
                    minValue={0.01}
                    maxValue={10}
                    step={0.05}
                    width="55px"
                    onChange={(value) =>
                      act('set_good', { id: good.id, field: 'mod', amount: value })
                    }
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
      <Stack.Item width="250px">
        <Section title="Harbor">
          <LabeledList>
            <LabeledList.Item label="Ships">{data.ships}</LabeledList.Item>
            <LabeledList.Item label="Hails left">{data.hails}</LabeledList.Item>
            <LabeledList.Item label="Standing orders">
              {data.orders}
            </LabeledList.Item>
          </LabeledList>
          <Button mt={1} onClick={() => act('reroll_ships')}>
            Reroll ships offshore
          </Button>
          <Button color="bad" onClick={() => act('clear_ships')}>
            Clear every ship
          </Button>
          <Button onClick={() => act('refill_hails')}>Refill hails</Button>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
