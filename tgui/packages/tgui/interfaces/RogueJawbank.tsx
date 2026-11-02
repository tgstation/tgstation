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
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import type { RogueLoan } from './RogueStewardry';

type LedgerEntry = {
  amount: number;
  reason: string | null;
};

type Limits = {
  personal_min: number;
  personal_max: number;
  indenture_min: number;
  indenture_max: number;
  term_max: number;
};

type Agent = {
  ref: string;
  name: string;
  job: string | null;
};

type Patronage = {
  agents: Agent[];
  cap: number;
  cooldown: number;
  explanation: string;
};

type Bathhouse = {
  master: BooleanLike;
  worker_limit: number;
  agent_limit: number;
  workers_suspended: BooleanLike;
  agents_suspended: BooleanLike;
  remaining: number | null;
};

type Ordinance = {
  active: BooleanLike;
  can_set: BooleanLike;
  cooldown: number;
  tithe: number;
};

type Data = {
  ordinance?: Ordinance;
  holder: string;
  label: string;
  authority: string;
  can_view: BooleanLike;
  can_lend: BooleanLike;
  withdraw_limit: number;
  day: number;
  last_loan_day: number;
  balance?: number;
  rule?: string;
  ledger?: LedgerEntry[];
  outstanding?: number;
  loans?: RogueLoan[];
  indenture?: RogueLoan | null;
  rates?: number[];
  limits?: Limits;
  targets?: { id: string; label: string }[];
  patronage?: Patronage;
  bathhouse?: Bathhouse;
};

/** JAWBANK: the coffers of an institution (Ratwood vaultbank.dm and the Institutional tab of the MeisterPanel). */
export const RogueJawbank = () => {
  const { data } = useBackend<Data>();
  const [tab, setTab] = useState('coffers');
  if (!data.can_view) {
    return (
      <Window
        title={data.holder}
        width={420}
        height={data.ordinance?.can_set ? 330 : 200}
      >
        <Window.Content>
          <NoticeBox>
            The coffers of {data.label} are sealed. Only {data.authority} may
            open them. Insert coins to feed it.
          </NoticeBox>
          {!!data.ordinance?.can_set && <OrdinanceSection />}
        </Window.Content>
      </Window>
    );
  }
  return (
    <Window title={data.holder} width={600} height={600}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                selected={tab === 'coffers'}
                onClick={() => setTab('coffers')}
              >
                Coffers: {data.balance}m
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === 'loans'}
                onClick={() => setTab('loans')}
              >
                Loans
              </Tabs.Tab>
              {!!data.patronage && (
                <Tabs.Tab
                  selected={tab === 'patronage'}
                  onClick={() => setTab('patronage')}
                >
                  Patronage
                </Tabs.Tab>
              )}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {tab === 'coffers' && <Coffers />}
            {tab === 'loans' && <Loans />}
            {tab === 'patronage' && <PatronageTab />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** The Ordinance of the Baths: the Church's sanction over the stews, set by the Bishop or the Bathmaster (Ratwood atm_tgui.dm). */
const OrdinanceSection = () => {
  const { act, data } = useBackend<Data>();
  const ordinance = data.ordinance;
  if (!ordinance) {
    return null;
  }
  return (
    <Section
      title="Ordinance of the Baths"
      buttons={
        !!ordinance.can_set && (
          <Button
            icon="stamp"
            disabled={ordinance.cooldown > 0}
            tooltip={
              ordinance.cooldown > 0
                ? `The seal is still warm: ${Math.ceil(ordinance.cooldown / 60)} more minutes.`
                : undefined
            }
            onClick={() => act('ordinance')}
          >
            {ordinance.active ? 'Break the seal' : 'Set the seal'}
          </Button>
        )
      }
    >
      <Box color={ordinance.active ? 'good' : 'average'}>
        {ordinance.active
          ? "In force: the bathhouse's tariffs and a tithe of its sales and hoard go to the Church."
          : "Broken: the bathhouse's tariffs go to the Crown."}
      </Box>
      <Box color="label">Tithed to the Church so far: {ordinance.tithe}m.</Box>
    </Section>
  );
};

const Coffers = () => {
  const { act, data } = useBackend<Data>();
  const [amount, setAmount] = useState(10);
  const limit = data.withdraw_limit;
  return (
    <Stack fill vertical>
      {!!data.ordinance && (
        <Stack.Item>
          <OrdinanceSection />
        </Stack.Item>
      )}
      <Stack.Item>
        <Section title={data.holder}>
          <LabeledList>
            <LabeledList.Item label="Balance">
              {data.balance} mammons
            </LabeledList.Item>
            <LabeledList.Item label="Lent out">
              {data.outstanding || 0} mammons
            </LabeledList.Item>
            <LabeledList.Item label="I may draw">
              {limit} mammons
            </LabeledList.Item>
          </LabeledList>
          {!!data.rule && (
            <Box mt={1} color="label">
              {data.rule}
            </Box>
          )}
          <Stack align="center" mt={1}>
            <Stack.Item>
              <NumberInput
                value={amount}
                minValue={1}
                maxValue={Math.max(1, limit)}
                step={1}
                width="70px"
                onChange={(value) => setAmount(value)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="coins"
                disabled={limit <= 0}
                onClick={() =>
                  act('withdraw', { amount: Math.min(amount, limit) })
                }
              >
                Withdraw coins
              </Button>
            </Stack.Item>
            {!!data.bathhouse && (
              <Stack.Item>
                <Button
                  tooltip="From my NERVELOCK account into the coffers."
                  onClick={() => act('deposit', { amount })}
                >
                  Deposit from account
                </Button>
              </Stack.Item>
            )}
          </Stack>
          <Box mt={1} color="label">
            Insert coins to deposit them.
          </Box>
        </Section>
      </Stack.Item>
      {!!data.bathhouse && (
        <Stack.Item>
          <BathhouseTerms />
        </Stack.Item>
      )}
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

const BathhouseTerms = () => {
  const { act, data } = useBackend<Data>();
  const bath = data.bathhouse;
  if (!bath) {
    return null;
  }
  if (!bath.master) {
    return (
      <Section title="Terms of the Bathhouse">
        I may still draw {bath.remaining || 0}m today.
      </Section>
    );
  }
  return (
    <Section title="Terms of the Bathhouse">
      <LabeledList>
        <LabeledList.Item
          label="Attendants a day"
          buttons={
            <Button.Checkbox
              checked={!!bath.workers_suspended}
              onClick={() => act('bath_suspend', { group: 'worker' })}
            >
              Suspend
            </Button.Checkbox>
          }
        >
          <NumberInput
            value={bath.worker_limit}
            minValue={0}
            maxValue={10000}
            step={5}
            width="70px"
            onChange={(value) =>
              act('bath_limit', { group: 'worker', amount: value })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item
          label="Agents a day"
          buttons={
            <Button.Checkbox
              checked={!!bath.agents_suspended}
              onClick={() => act('bath_suspend', { group: 'agent' })}
            >
              Suspend
            </Button.Checkbox>
          }
        >
          <NumberInput
            value={bath.agent_limit}
            minValue={0}
            maxValue={10000}
            step={5}
            width="70px"
            onChange={(value) =>
              act('bath_limit', { group: 'agent', amount: value })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const Loans = () => {
  const { act, data } = useBackend<Data>();
  const indenture = data.indenture;
  const [repay, setRepay] = useState(100);
  return (
    <Stack fill vertical>
      {!!data.can_lend && (
        <Stack.Item>
          <DraftWrit />
        </Stack.Item>
      )}
      {!!indenture && (
        <Stack.Item>
          <Section title={`Indenture owed to ${indenture.lender}`}>
            <Box>
              {indenture.remaining}m owed,{' '}
              {indenture.defaulted
                ? 'DEFAULTED'
                : `due at the dawn of day ${indenture.due_day}`}
              .
            </Box>
            {!!data.can_lend && (
              <Stack align="center" mt={1}>
                <Stack.Item>
                  <NumberInput
                    value={repay}
                    minValue={1}
                    maxValue={Math.max(1, indenture.remaining)}
                    step={10}
                    width="70px"
                    onChange={(value) => setRepay(value)}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    onClick={() => act('repay_indenture', { amount: repay })}
                  >
                    Repay from the coffers
                  </Button>
                </Stack.Item>
              </Stack>
            )}
          </Section>
        </Stack.Item>
      )}
      <Stack.Item grow>
        <Section fill scrollable title="Loans of these coffers">
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
              </Table.Row>
              {(data.loans || []).map((loan) => (
                <Table.Row key={loan.ref} className="candystripe">
                  <Table.Cell>{loan.debtor}</Table.Cell>
                  <Table.Cell>{loan.lender}</Table.Cell>
                  <Table.Cell collapsing>
                    {loan.principal}m @ {loan.interest}%
                  </Table.Cell>
                  <Table.Cell collapsing>
                    {loan.defaulted ? 'DEFAULTED' : `day ${loan.due_day}`}
                  </Table.Cell>
                  <Table.Cell collapsing>{loan.remaining}m</Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const DraftWrit = () => {
  const { act, data } = useBackend<Data>();
  const limits = data.limits;
  const rates = data.rates || [];
  const targets = data.targets || [];
  const [kind, setKind] = useState('personal');
  const [amount, setAmount] = useState(100);
  const [term, setTerm] = useState(1);
  const [rate, setRate] = useState(rates[0] ?? 10);
  const [target, setTarget] = useState(targets[0]?.id || '');
  if (!limits) {
    return null;
  }
  const personal = kind === 'personal';
  const low = personal ? limits.personal_min : limits.indenture_min;
  const high = personal ? limits.personal_max : limits.indenture_max;
  const principal = Math.min(Math.max(amount, low), high);
  const total = Math.floor(principal * (1 + (rate / 100) * Math.max(1, term)));
  const closed = data.day > data.last_loan_day;
  const targetLabel =
    targets.find((entry) => entry.id === target)?.label || 'none';
  return (
    <Section
      title="Draft a writ"
      buttons={
        <>
          <Button selected={personal} onClick={() => setKind('personal')}>
            Loan
          </Button>
          <Button selected={!personal} onClick={() => setKind('indenture')}>
            Indenture
          </Button>
        </>
      }
    >
      {closed && (
        <NoticeBox>
          No new loans may be drawn after day {data.last_loan_day}.
        </NoticeBox>
      )}
      <LabeledList>
        {!personal && (
          <LabeledList.Item label="To">
            <Dropdown
              selected={targetLabel}
              options={targets.map((entry) => entry.label)}
              onSelected={(value) =>
                setTarget(
                  targets.find((entry) => entry.label === value)?.id || '',
                )
              }
            />
          </LabeledList.Item>
        )}
        <LabeledList.Item label="Principal">
          <NumberInput
            value={principal}
            minValue={low}
            maxValue={high}
            step={10}
            width="70px"
            onChange={(value) => setAmount(value)}
          />{' '}
          ({low}-{high}m)
        </LabeledList.Item>
        <LabeledList.Item label="Term">
          <NumberInput
            value={term}
            minValue={1}
            maxValue={limits.term_max}
            step={1}
            width="50px"
            onChange={(value) => setTerm(value)}
          />{' '}
          days
        </LabeledList.Item>
        <LabeledList.Item label="Interest a day">
          {rates.map((entry) => (
            <Button
              key={entry}
              selected={entry === rate}
              onClick={() => setRate(entry)}
            >
              {entry}%
            </Button>
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Total due">{total}m</LabeledList.Item>
      </LabeledList>
      <Button
        mt={1}
        icon="file-signature"
        disabled={closed || (!personal && !target)}
        onClick={() =>
          act(personal ? 'draft_loan' : 'draft_indenture', {
            amount: principal,
            term: term,
            rate: rate,
            target: target,
          })
        }
      >
        Sign the writ
      </Button>
    </Section>
  );
};

const PatronageTab = () => {
  const { act, data } = useBackend<Data>();
  const patronage = data.patronage;
  if (!patronage) {
    return null;
  }
  return (
    <Section
      fill
      scrollable
      title={`Agents of ${data.label}: ${patronage.agents.length}/${patronage.cap}`}
      buttons={
        <Button
          icon="file-signature"
          disabled={
            patronage.cooldown > 0 || patronage.agents.length >= patronage.cap
          }
          tooltip={
            patronage.cooldown > 0
              ? `The seal is still warm: ${patronage.cooldown}s.`
              : undefined
          }
          onClick={() => act('draft_patronage')}
        >
          Draft a writ
        </Button>
      }
    >
      <Box mb={1} color="label" preserveWhitespace>
        {patronage.explanation}
      </Box>
      <Table>
        {patronage.agents.map((agent) => (
          <Table.Row key={agent.ref} className="candystripe">
            <Table.Cell>{agent.name}</Table.Cell>
            <Table.Cell>{agent.job}</Table.Cell>
            <Table.Cell collapsing>
              <Button
                compact
                color="bad"
                onClick={() => act('revoke_patron', { ref: agent.ref })}
              >
                Strike off
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
