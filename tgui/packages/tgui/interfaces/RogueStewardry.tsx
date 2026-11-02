import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  Table,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import type { RogueStock } from './RogueStockpile';

type LedgerEntry = {
  amount: number;
  reason: string | null;
};

type Levy = {
  name: string;
  percent: number;
};

type Wage = {
  title: string;
  wage: number;
  floor: number;
};

type Account = {
  ref: string;
  holder: string;
  job: string | null;
  balance: number;
  estate: number;
  suspended: BooleanLike;
  max_fine: number;
  poll_owed: number;
  poll_overdue: number;
  defaulter: BooleanLike;
};

type PollClass = {
  id: string;
  name: string;
  rate: number;
  heads: number;
  taxable: number;
  flow: number;
};

type Solvency = {
  state: string;
  sequestered: BooleanLike;
  debt: number;
  wage_outlay: number;
  ftc_blocker: string | null;
  ftc_min: number;
  ftc_max: number;
  ftc_interest: number;
};

export type RogueLoan = {
  ref: string;
  debtor: string;
  lender: string;
  lender_id: string;
  borrower_id: string | null;
  principal: number;
  interest: number;
  due_day: number;
  days_left: number;
  remaining: number;
  defaulted: BooleanLike;
};

type Fund = {
  id: string;
  holder: string;
  balance: number;
  lent: number;
};

type Pledge = {
  balance: number;
  renewal: number;
  tribute: number;
  bull: BooleanLike;
  spent: number;
};

type Custom = {
  unlocked: BooleanLike;
  active: BooleanLike;
  margin: number;
  threshold: number;
  volume: number;
};

type MarketEvent = {
  name: string;
  description: string;
  shortage: BooleanLike;
  goods: string[];
  percent: number;
  days_left: number;
  progress: number;
  target: number;
};

type Blockade = {
  region: string;
  route: string;
  raiders: string;
  days: number;
};

type Market = {
  events: MarketEvent[];
  blockades: Blockade[];
  banditry_debt: number;
  banditry_losses: number;
  blockade_days: number;
};

type TradeLine = {
  id: string;
  name: string;
  today: number;
  pace: number;
  price: number;
  stocked: number;
  event: string | null;
};

type TradeRegion = {
  id: string;
  name: string;
  subtitle: string;
  blockaded: BooleanLike;
  imports: TradeLine[];
  exports: TradeLine[];
};

type CrownImport = {
  ref: string;
  name: string;
  desc: string;
  price: number;
  region: string | null;
  blockaded: BooleanLike;
  ordered: number;
};

type AutoImports = {
  goods: {
    id: string;
    name: string;
    essential: BooleanLike;
    active: BooleanLike;
    stocked: number;
  }[];
  floor: number;
  stock_floor: number;
  batch: number;
  spent: number;
  lines: string[];
  history: { dawn: number; spent: number; lines: string[] }[];
};

type Petitions = {
  categories: {
    id: string;
    label: string;
    description: string;
    cost: number;
    blockers: Record<string, string>;
  }[];
  left: number;
  payout_percent: number;
};

type Data = {
  purse: number;
  floor: number;
  ledger: LedgerEntry[];
  totals: Record<string, number>;
  solvency: Solvency;
  levies: Levy[];
  levy_locked: BooleanLike;
  poll: { classes: PollClass[]; income: number; subsidy: number };
  poll_locked: BooleanLike;
  poll_min: number;
  poll_max: number;
  carta: BooleanLike;
  wages: Wage[];
  accounts: Account[];
  loans: RogueLoan[];
  funds: Fund[];
  stocks: (RogueStock & { automatic?: BooleanLike })[];
  pledge: Pledge;
  ordinance: BooleanLike;
  custom: Custom;
  market: Market;
  regions: TradeRegion[];
  region_trade_max: number;
  crown_imports: CrownImport[];
  auto_imports: AutoImports;
  petitions: Petitions;
};

const TOTALS: [string, string][] = [
  ['rural_tax', 'Rural tax'],
  ['tariff', 'Import tariff'],
  ['poll_tax', 'Poll tax'],
  ['poll_subsidy', 'Poll subsidies'],
  ['fines', 'Fines'],
  ['tithe', 'Concordat tithe'],
  ['contract_levy', 'Contract levy'],
  ['royal_custom', 'Royal Custom'],
  ['wages', 'Wages paid'],
  ['export', 'Exports'],
  ['import', 'Imports'],
  ['trade', 'Stockpile trade'],
  ['banditry', 'Banditry losses'],
];

/** Nerve master: the Steward's treasury desk (Ratwood steward.dm, StewardTrade.tsx and TaxSetter.tsx, cut to the money loop). */
export const RogueStewardry = () => {
  const { data } = useBackend<Data>();
  const [tab, setTab] = useState('treasury');
  return (
    <Window title="Nerve Master" width={780} height={700}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                selected={tab === 'treasury'}
                onClick={() => setTab('treasury')}
              >
                Crown&apos;s Purse: {data.purse}m
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === 'poll'}
                onClick={() => setTab('poll')}
              >
                Poll tax
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === 'wages'}
                onClick={() => setTab('wages')}
              >
                Wages
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === 'accounts'}
                onClick={() => setTab('accounts')}
              >
                Accounts
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === 'loans'}
                onClick={() => setTab('loans')}
              >
                Loans
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === 'stockpile'}
                onClick={() => setTab('stockpile')}
              >
                Stockpile
              </Tabs.Tab>
            </Tabs>
            <Tabs fluid>
              <Tabs.Tab
                selected={tab === 'market'}
                onClick={() => setTab('market')}
              >
                Market
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === 'regions'}
                onClick={() => setTab('regions')}
              >
                Regions
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === 'imports'}
                onClick={() => setTab('imports')}
              >
                Crown imports
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === 'petitions'}
                onClick={() => setTab('petitions')}
              >
                Petitions
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {tab === 'treasury' && <Treasury />}
            {tab === 'poll' && <PollTax />}
            {tab === 'wages' && <Wages />}
            {tab === 'accounts' && <Accounts />}
            {tab === 'loans' && <Loans />}
            {tab === 'stockpile' && <Stockpile />}
            {tab === 'market' && <MarketPage />}
            {tab === 'regions' && <RegionsPage />}
            {tab === 'imports' && <ImportsPage />}
            {tab === 'petitions' && <PetitionsPage />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Treasury = () => {
  const { act, data } = useBackend<Data>();
  const solvency = data.solvency;
  return (
    <Stack fill vertical>
      {!!solvency?.sequestered && (
        <Stack.Item>
          <NoticeBox danger>
            The realm is sequestered: wages stand suspended and the Company
            takes the Purse&apos;s income above its reserve.
          </NoticeBox>
        </Stack.Item>
      )}
      <Stack.Item>
        <Section
          title="Crown's Purse"
          buttons={
            <>
              <Button icon="scroll" onClick={() => act('charters')}>
                Charters
              </Button>
              <Button icon="coins" onClick={() => act('withdraw')}>
                Withdraw coins
              </Button>
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Balance">
              {data.purse} mammons
            </LabeledList.Item>
            <LabeledList.Item label="Solvency">
              {solvency?.state}
            </LabeledList.Item>
            <LabeledList.Item label="Wages due at dawn">
              {solvency?.wage_outlay}m
            </LabeledList.Item>
            <LabeledList.Item
              label="Debt to the Company"
              buttons={
                <Button
                  disabled={!!solvency?.ftc_blocker}
                  tooltip={
                    solvency?.ftc_blocker ||
                    `${solvency?.ftc_min}-${solvency?.ftc_max}m at ${solvency?.ftc_interest}% interest. The next payroll the Purse cannot meet means sequestration.`
                  }
                  onClick={() => act('ftc_loan')}
                >
                  Borrow
                </Button>
              }
            >
              {solvency?.debt || 0}m
            </LabeledList.Item>
            <LabeledList.Item
              label="Purchase floor"
              buttons={<Button onClick={() => act('set_floor')}>Set</Button>}
            >
              {data.floor} mammons
            </LabeledList.Item>
            {(data.levies || []).map((levy) => (
              <LabeledList.Item
                key={levy.name}
                label={levy.name}
                buttons={
                  <Button
                    disabled={!!data.levy_locked}
                    tooltip={
                      data.levy_locked ? 'Levies change once a day.' : undefined
                    }
                    onClick={() => act('set_levy', { name: levy.name })}
                  >
                    Set
                  </Button>
                }
              >
                {levy.percent}%
              </LabeledList.Item>
            ))}
            {TOTALS.map(([key, label]) => (
              <LabeledList.Item key={key} label={label}>
                {data.totals?.[key] || 0}m
              </LabeledList.Item>
            ))}
          </LabeledList>
          <Box mt={1} color="label">
            Insert coins to deposit them in the Purse.
          </Box>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title="Ledger">
          <Table>
            {(data.ledger || []).map((entry, i) => (
              <Table.Row key={i}>
                <Table.Cell
                  collapsing
                  color={entry.amount < 0 ? 'bad' : 'good'}
                >
                  {entry.amount > 0 ? `+${entry.amount}` : entry.amount}
                </Table.Cell>
                <Table.Cell>{entry.reason}</Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

/** Ratwood TaxSetter: every class's rate is drafted here and proclaimed at once, once a day. */
const PollTax = () => {
  const { act, data } = useBackend<Data>();
  const classes = data.poll?.classes || [];
  const [draft, setDraft] = useState<Record<string, number>>({});
  const rateOf = (entry: PollClass) => draft[entry.id] ?? entry.rate;
  const changed = classes.some((entry) => rateOf(entry) !== entry.rate);
  return (
    <Section
      fill
      scrollable
      title="Poll tax, a head at every dawn"
      buttons={
        <Button
          icon="bullhorn"
          disabled={!!data.poll_locked || !changed}
          tooltip={
            data.poll_locked ? 'The poll tax changes once a day.' : undefined
          }
          onClick={() => {
            act('set_poll', { rates: draft });
            setDraft({});
          }}
        >
          Proclaim
        </Button>
      }
    >
      {!!data.carta && (
        <NoticeBox>
          The Magna Carta stands: the Crown may tax no head, only grant
          subsidies.
        </NoticeBox>
      )}
      <Table>
        <Table.Row header>
          <Table.Cell>Class</Table.Cell>
          <Table.Cell collapsing>Heads</Table.Cell>
          <Table.Cell collapsing>Taxable</Table.Cell>
          <Table.Cell collapsing>Rate</Table.Cell>
          <Table.Cell collapsing>Per dawn</Table.Cell>
        </Table.Row>
        {classes.map((entry) => (
          <Table.Row key={entry.id} className="candystripe">
            <Table.Cell>{entry.name}</Table.Cell>
            <Table.Cell collapsing>{entry.heads}</Table.Cell>
            <Table.Cell collapsing>{entry.taxable}</Table.Cell>
            <Table.Cell collapsing>
              <NumberInput
                value={rateOf(entry)}
                minValue={data.poll_min}
                maxValue={data.poll_max}
                step={1}
                width="60px"
                onChange={(value) =>
                  setDraft((old) => ({ ...old, [entry.id]: value }))
                }
              />
            </Table.Cell>
            <Table.Cell collapsing color={entry.flow < 0 ? 'bad' : 'good'}>
              {entry.flow}m
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
      <Box mt={1} color="label">
        Below zero the Crown pays the class a subsidy. Charters exempt or cap
        some classes. Income {data.poll?.income || 0}m, subsidies{' '}
        {data.poll?.subsidy || 0}m a dawn.
      </Box>
    </Section>
  );
};

const Wages = () => {
  const { act, data } = useBackend<Data>();
  return (
    <Section fill scrollable title="Daily wages, paid at dawn">
      <Table>
        {(data.wages || []).map((entry) => (
          <Table.Row key={entry.title} className="candystripe">
            <Table.Cell>{entry.title}</Table.Cell>
            <Table.Cell collapsing>
              {entry.wage}m
              {entry.floor > 0 && (
                <Box inline color="label">
                  &nbsp;(charter: {entry.floor}m)
                </Box>
              )}
            </Table.Cell>
            <Table.Cell collapsing>
              <Button onClick={() => act('set_wage', { title: entry.title })}>
                Set
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const Accounts = () => {
  const { act, data } = useBackend<Data>();
  return (
    <Section fill scrollable title="NERVELOCK accounts">
      <Table>
        <Table.Row header>
          <Table.Cell>Holder</Table.Cell>
          <Table.Cell>Role</Table.Cell>
          <Table.Cell collapsing>Balance</Table.Cell>
          <Table.Cell collapsing />
        </Table.Row>
        {(data.accounts || []).map((account) => (
          <Table.Row key={account.ref} className="candystripe">
            <Table.Cell>
              {account.holder}
              {!!account.defaulter && (
                <Box inline color="bad">
                  &nbsp;[DEFAULTER]
                </Box>
              )}
              {account.poll_owed > 0 && (
                <Box inline color="average">
                  &nbsp;[ARREARS: {account.poll_owed}m, {account.poll_overdue}d]
                </Box>
              )}
            </Table.Cell>
            <Table.Cell>
              {account.job}
              {account.estate > 0 && (
                <Box inline color="label">
                  &nbsp;(estate {account.estate}m)
                </Box>
              )}
            </Table.Cell>
            <Table.Cell collapsing>{account.balance}m</Table.Cell>
            <Table.Cell collapsing>
              <Button
                compact
                onClick={() => act('grant', { ref: account.ref })}
              >
                Grant
              </Button>
              <Button
                compact
                disabled={account.max_fine <= 0}
                tooltip={
                  account.max_fine > 0
                    ? `At most ${account.max_fine}m.`
                    : 'Fined today, shielded by a charter, or nothing to take.'
                }
                onClick={() => act('fine', { ref: account.ref })}
              >
                Fine
              </Button>
              {account.poll_owed > 0 && (
                <Button
                  compact
                  onClick={() => act('clear_arrears', { ref: account.ref })}
                >
                  Clear arrears
                </Button>
              )}
              <Button.Checkbox
                compact
                checked={!!account.suspended}
                onClick={() => act('toggle_wages', { ref: account.ref })}
              >
                Withhold wage
              </Button.Checkbox>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const Loans = () => {
  const { act, data } = useBackend<Data>();
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Funds of the realm">
          <Table>
            {(data.funds || []).map((fund) => (
              <Table.Row key={fund.id}>
                <Table.Cell>{fund.holder}</Table.Cell>
                <Table.Cell collapsing>{fund.balance}m</Table.Cell>
                <Table.Cell collapsing color="label">
                  lent {fund.lent}m
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title="Loans and indentures">
          {(data.loans || []).length === 0 ? (
            <Box color="label">No active loans.</Box>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>Debtor</Table.Cell>
                <Table.Cell>Lender</Table.Cell>
                <Table.Cell collapsing>Principal</Table.Cell>
                <Table.Cell collapsing>Due</Table.Cell>
                <Table.Cell collapsing>Owed</Table.Cell>
                <Table.Cell collapsing />
              </Table.Row>
              {data.loans.map((loan) => (
                <Table.Row
                  key={loan.ref}
                  className="candystripe"
                  color={loan.defaulted ? 'bad' : undefined}
                >
                  <Table.Cell>{loan.debtor}</Table.Cell>
                  <Table.Cell>{loan.lender}</Table.Cell>
                  <Table.Cell collapsing>
                    {loan.principal}m @ {loan.interest}%
                  </Table.Cell>
                  <Table.Cell collapsing>
                    {loan.defaulted ? 'DEFAULTED' : `day ${loan.due_day}`}
                  </Table.Cell>
                  <Table.Cell collapsing>{loan.remaining}m</Table.Cell>
                  <Table.Cell collapsing>
                    {loan.lender_id === 'crown' && !loan.borrower_id && (
                      <Button
                        compact
                        tooltip="Write off the debt and lift the defaulter's mark."
                        onClick={() => act('forgive', { ref: loan.ref })}
                      >
                        Forgive
                      </Button>
                    )}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const Stockpile = () => {
  const { act, data } = useBackend<Data>();
  return (
    <Section fill scrollable title="The Crown's stockpile">
      <Table>
        <Table.Row header>
          <Table.Cell>Good</Table.Cell>
          <Table.Cell collapsing>Stock</Table.Cell>
          <Table.Cell collapsing>Pays</Table.Cell>
          <Table.Cell collapsing>Sells</Table.Cell>
          <Table.Cell collapsing>Export</Table.Cell>
          <Table.Cell collapsing />
        </Table.Row>
        {(data.stocks || []).map((stock) => (
          <Table.Row key={stock.ref} className="candystripe">
            <Table.Cell>
              <Tooltip content={stock.desc}>
                <Box inline>{stock.name}</Box>
              </Tooltip>
              <Box inline color="label">
                &nbsp;({stock.category})
              </Box>
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                compact
                onClick={() => act('stock_limit', { ref: stock.ref })}
              >
                {stock.amount}/{stock.limit}
              </Button>
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                compact
                onClick={() => act('stock_payout', { ref: stock.ref })}
              >
                {stock.payout_price}m
              </Button>
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                compact
                onClick={() => act('stock_withdraw', { ref: stock.ref })}
              >
                {stock.withdraw_price}m
              </Button>
            </Table.Cell>
            <Table.Cell collapsing>{stock.export_price}m</Table.Cell>
            <Table.Cell collapsing>
              {!stock.automatic && (
                <Button
                  compact
                  icon="rotate"
                  tooltip="Set by hand: restore the market price."
                  onClick={() => act('stock_auto', { ref: stock.ref })}
                />
              )}
              <Button.Checkbox
                compact
                checked={!!stock.accept_enabled}
                tooltip="The Crown buys this good from sellers."
                onClick={() => act('stock_accept', { ref: stock.ref })}
              >
                Buy
              </Button.Checkbox>
              <Button.Checkbox
                compact
                checked={!stock.withdraw_disabled}
                tooltip="Anyone may buy it; otherwise only the Crown's officers."
                onClick={() => act('stock_lock', { ref: stock.ref })}
              >
                Sell
              </Button.Checkbox>
              <Button.Checkbox
                compact
                checked={!stock.autoexport_disabled}
                tooltip="Ship the surplus abroad on its own."
                onClick={() => act('stock_autoexport', { ref: stock.ref })}
              >
                Auto
              </Button.Checkbox>
              <Button
                compact
                disabled={stock.amount <= 0}
                onClick={() => act('stock_export', { ref: stock.ref })}
              >
                Export
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

/** The Burgher Pledge, the charters of trade, the economic events and the held roads (Ratwood StewardTrade market and ledger). */
const MarketPage = () => {
  const { act, data } = useBackend<Data>();
  const pledge = data.pledge;
  const custom = data.custom;
  const market = data.market;
  return (
    <Section fill scrollable>
      <Section title="Burgher Pledge">
        <LabeledList>
          <LabeledList.Item label="Pledge">
            {pledge?.balance || 0} (pays commissions and petitions, never
            coin)
          </LabeledList.Item>
          <LabeledList.Item label="Renewed at dawn">
            {pledge?.bull
              ? `${pledge.renewal}${pledge.tribute ? ` + ${pledge.tribute} of the Guild's tribute` : ''}`
              : 'never: the Golden Bull is suspended'}
          </LabeledList.Item>
          <LabeledList.Item label="Spent this round">
            {pledge?.spent || 0}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Charters of trade">
        <LabeledList>
          <LabeledList.Item label="Ordinance of the Baths">
            {data.ordinance
              ? "In force: the bathhouse's dues go to the Church."
              : "Broken: the bathhouse's dues go to the Crown."}
          </LabeledList.Item>
          <LabeledList.Item
            label="Right of Customs in Excess"
            buttons={
              !!custom?.unlocked && (
                <Button onClick={() => act('set_custom_margin')}>
                  Margin: {custom.margin}%
                </Button>
              )
            }
          >
            {custom?.unlocked
              ? 'Invoked: what buyers pay above the price of a direct import goes to the Crown.'
              : `Invoked at ${custom?.threshold || 0}m of stockpile trade (${custom?.volume || 0}m so far).`}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Economic events">
        {(market?.events || []).length === 0 ? (
          <Box color="label">The market is calm.</Box>
        ) : (
          <Table>
            {market.events.map((event) => (
              <Table.Row key={event.name} className="candystripe">
                <Table.Cell>
                  <Tooltip content={event.description}>
                    <Box inline color={event.shortage ? 'bad' : 'good'}>
                      {event.name}
                    </Box>
                  </Tooltip>
                  <Box color="label">{event.goods.join(', ')}</Box>
                </Table.Cell>
                <Table.Cell collapsing>{event.percent}% price</Table.Cell>
                <Table.Cell collapsing>
                  {event.days_left > 0
                    ? `${event.days_left} dawn${event.days_left === 1 ? '' : 's'}`
                    : 'ends at dawn'}
                </Table.Cell>
                <Table.Cell collapsing>
                  {!!event.shortage &&
                    `relief ${event.progress}/${event.target}`}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        )}
        <Box mt={1} color="label">
          A shortage ends early once the realm ships its regions enough of its
          goods.
        </Box>
      </Section>
      <Section title="Held roads">
        {(market?.blockades || []).length === 0 ? (
          <Box color="label">Every road is open.</Box>
        ) : (
          <Table>
            {market.blockades.map((blockade) => (
              <Table.Row key={blockade.region} className="candystripe">
                <Table.Cell>{blockade.region}</Table.Cell>
                <Table.Cell color="label">
                  {blockade.raiders} on the {blockade.route}
                </Table.Cell>
                <Table.Cell collapsing>{blockade.days} dawns</Table.Cell>
              </Table.Row>
            ))}
          </Table>
        )}
        <Box mt={1} color="label">
          Imports from a held road cost double, its exports fetch half, its
          orders wait. Raiders move on after {market?.blockade_days} dawns.
          Caravans lost at dawn: {market?.banditry_losses || 0}m; banditry
          debt: {market?.banditry_debt || 0}m.
        </Box>
      </Section>
    </Section>
  );
};

const TradeTable = (props: {
  region: TradeRegion;
  lines: TradeLine[];
  importing: boolean;
}) => {
  const { act } = useBackend<Data>();
  const { region, lines, importing } = props;
  if (!lines.length) {
    return <Box color="label">Nothing the stockpile keeps.</Box>;
  }
  return (
    <Table>
      <Table.Row header>
        <Table.Cell>Good</Table.Cell>
        <Table.Cell collapsing>{importing ? 'Makes' : 'Wants'}</Table.Cell>
        <Table.Cell collapsing>Next unit</Table.Cell>
        <Table.Cell collapsing>In stock</Table.Cell>
        <Table.Cell collapsing />
      </Table.Row>
      {lines.map((line) => (
        <Table.Row key={line.id} className="candystripe">
          <Table.Cell>
            {line.name}
            {line.event && (
              <Box inline color="average">
                &nbsp;({line.event})
              </Box>
            )}
          </Table.Cell>
          <Table.Cell collapsing>
            {line.today}/{line.pace}
          </Table.Cell>
          <Table.Cell collapsing>{line.price}m</Table.Cell>
          <Table.Cell collapsing>{line.stocked}</Table.Cell>
          <Table.Cell collapsing>
            <Button
              compact
              disabled={!importing && line.stocked <= 0}
              onClick={() =>
                act('region_trade', {
                  region: region.id,
                  good: line.id,
                  mode: importing ? 'import' : 'export',
                })
              }
            >
              {importing ? 'Import' : 'Export'}
            </Button>
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

/** Trade with each region by hand (Ratwood StewardTrade regions). */
const RegionsPage = () => {
  const { data } = useBackend<Data>();
  const regions = data.regions || [];
  const [picked, setPicked] = useState('');
  const region = regions.find((entry) => entry.id === picked) || regions[0];
  return (
    <Stack fill>
      <Stack.Item width="180px">
        <Section fill scrollable>
          <Tabs vertical>
            {regions.map((entry) => (
              <Tabs.Tab
                key={entry.id}
                selected={entry === region}
                color={entry.blockaded ? 'bad' : undefined}
                onClick={() => setPicked(entry.id)}
              >
                {entry.name}
                {entry.blockaded ? ' (held)' : ''}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        {region && (
          <Section fill scrollable title={region.name}>
            <Box italic color="label">
              {region.subtitle}
            </Box>
            {!!region.blockaded && (
              <NoticeBox mt={1} danger>
                Raiders hold the road: its goods cost double, it pays half.
              </NoticeBox>
            )}
            <Box mt={1} color="label">
              At most {data.region_trade_max} units at once. Every unit past
              the region&apos;s daily pace costs more, or fetches less.
            </Box>
            <Section title="Import into the stockpile">
              <TradeTable region={region} lines={region.imports} importing />
            </Section>
            <Section title="Export from the stockpile">
              <TradeTable
                region={region}
                lines={region.exports}
                importing={false}
              />
            </Section>
          </Section>
        )}
      </Stack.Item>
    </Stack>
  );
};

/** Crown imports delivered to the warehouse, and the Crown's standing imports (Ratwood steward imports and AutoImport). */
const ImportsPage = () => {
  const { act, data } = useBackend<Data>();
  const auto = data.auto_imports;
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section fill scrollable title="Crown imports, left at the warehouse">
          {(data.crown_imports || []).length === 0 && (
            <NoticeBox>Nothing the regions could send is known here.</NoticeBox>
          )}
          <Table>
            {(data.crown_imports || []).map((entry) => (
              <Table.Row key={entry.ref} className="candystripe">
                <Table.Cell>
                  <Tooltip content={entry.desc}>
                    <Box inline>{entry.name}</Box>
                  </Tooltip>
                  {entry.region && (
                    <Box inline color={entry.blockaded ? 'bad' : 'label'}>
                      &nbsp;({entry.region}
                      {entry.blockaded ? ', held road' : ''})
                    </Box>
                  )}
                </Table.Cell>
                <Table.Cell collapsing>{entry.price}m</Table.Cell>
                <Table.Cell collapsing>
                  <Button
                    disabled={entry.price > data.purse}
                    onClick={() => act('crown_import', { ref: entry.ref })}
                  >
                    Order
                  </Button>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
          <Box mt={1} color="label">
            Every order of a kind today makes the next dearer.
          </Box>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title="Standing imports"
          buttons={
            <>
              <Button onClick={() => act('auto_import_floor')}>
                Purse floor: {auto?.floor}m
              </Button>
              <Button color="bad" onClick={() => act('auto_import_stop')}>
                Stop all
              </Button>
            </>
          }
        >
          <Box color="label">
            Every treasury tick the Crown buys {auto?.batch} units of a chosen
            good below {auto?.stock_floor} in the stockpile from the cheapest
            open region. Spent today: {auto?.spent || 0}m.
          </Box>
          <Box mt={1}>
            {(auto?.goods || []).map((good) => (
              <Button.Checkbox
                key={good.id}
                checked={!!good.active}
                tooltip={`${good.stocked} in stock${good.essential ? ', an essential' : ''}`}
                onClick={() => act('auto_import', { id: good.id })}
              >
                {good.name}
              </Button.Checkbox>
            ))}
          </Box>
          {(auto?.lines || []).map((line, index) => (
            <Box key={index} color="label">
              {line}
            </Box>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

/** The Steward petitions a region's trade hall for an order, paid from the Burgher Pledge (Ratwood steward petitions). */
const PetitionsPage = () => {
  const { act, data } = useBackend<Data>();
  const regions = data.regions || [];
  const petitions = data.petitions;
  const [picked, setPicked] = useState('');
  const region = regions.find((entry) => entry.name === picked) || regions[0];
  return (
    <Section fill scrollable title="Petitions to the trade halls">
      <Box color="label">
        Burgher Pledge: {data.pledge?.balance || 0}. Petitions left today:{' '}
        {petitions?.left}. A petitioned order pays {petitions?.payout_percent}%
        of its worth.
      </Box>
      <Box mt={1}>
        Region:{' '}
        <Dropdown
          selected={region?.name || ''}
          options={regions.map((entry) => entry.name)}
          onSelected={(value) => setPicked(value)}
        />
      </Box>
      {region && (
        <Table mt={1}>
          {(petitions?.categories || []).map((category) => {
            const blocker = category.blockers?.[region.id];
            return (
              <Table.Row key={category.id} className="candystripe">
                <Table.Cell>
                  <b>{category.label}</b>
                  <Box color="label">{category.description}</Box>
                </Table.Cell>
                <Table.Cell collapsing>{category.cost} pledge</Table.Cell>
                <Table.Cell collapsing>
                  <Button
                    disabled={!!blocker}
                    tooltip={blocker || undefined}
                    onClick={() =>
                      act('petition', {
                        region: region.id,
                        category: category.id,
                      })
                    }
                  >
                    Petition
                  </Button>
                </Table.Cell>
              </Table.Row>
            );
          })}
        </Table>
      )}
    </Section>
  );
};
