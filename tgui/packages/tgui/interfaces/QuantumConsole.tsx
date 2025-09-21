import {
  Button,
  Collapsible,
  Icon,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { LoadingScreen } from './common/LoadingScreen';

type Data =
  | {
      available_domains: Domain[];
      avatars: Avatar[];
      connected: 1;
      generated_domain: string | null;
      occupants: number;
      points: number;
      randomized: BooleanLike;
      ready: BooleanLike;
      retries_left: number;
      scanner_tier: number;
      broadcasting: BooleanLike;
      broadcasting_on_cd: BooleanLike;
    }
  | {
      connected: 0;
    };

type Avatar = {
  health: number;
  name: string;
  pilot: string;
  brute: number;
  burn: number;
  tox: number;
  oxy: number;
};

type Domain = {
  announce_ghosts: BooleanLike;
  cost: number;
  desc: string;
  difficulty: number;
  id: string;
  is_modular: BooleanLike;
  has_secondary_objectives: BooleanLike;
  name: string;
  reward: number | string;
};

type DomainEntryProps = {
  domain: Domain;
};

type DisplayDetailsProps = {
  amount: number | string;
  color: string;
  icon: string;
};

enum Difficulty {
  None,
  Low,
  Medium,
  High,
}

function isConnected(data: Data): data is Data & { connected: 1 } {
  return data.connected === 1;
}

function getColor(difficulty: number) {
  switch (difficulty) {
    case Difficulty.Low:
      return 'yellow';
    case Difficulty.Medium:
      return 'average';
    case Difficulty.High:
      return 'bad';
    default:
      return 'green';
  }
}

export function QuantumConsole(props) {
  const { data } = useBackend<Data>();

  return (
    <Window title="Quantum Console" width={500} height={500}>
      <Window.Content>
        {!!data.connected && !data.ready && <LoadingScreen />}
        <AccessView />
      </Window.Content>
    </Window>
  );
}

function AccessView(props) {
  const { act, data } = useBackend<Data>();
  const [tab, setTab] = useSharedState('tab', 0);

  if (!isConnected(data)) {
    return <NoticeBox danger>No server connected!</NoticeBox>;
  }

  const {
    available_domains = [],
    broadcasting,
    broadcasting_on_cd,
    generated_domain,
    occupants,
    points,
    randomized,
    ready,
  } = data;

  const sorted = available_domains.sort((a, b) => a.cost - b.cost);

  const filtered = sorted.filter((domain) => {
    return domain.difficulty === tab;
  });

  let selected;
  if (generated_domain) {
    selected = randomized
      ? '???'
      : sorted.find(({ id }) => id === generated_domain)?.name;
  } else {
    selected = 'Nothing loaded';
  }

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          buttons={
            <Stack fill>
              <Tooltip
                content="Toggles whether you broadcast your
                  bitrun to station Entertainment Monitors."
              >
                <Button.Checkbox
                  checked={broadcasting}
                  disabled={broadcasting_on_cd}
                  onClick={() => act('broadcast')}
                >
                  Broadcast
                </Button.Checkbox>
              </Tooltip>
              <Tooltip
                content="Get a random domain for more rewards.
                  Weighted towards your current points. Minimum: 1 point."
              >
                <Button
                  disabled={
                    !ready || occupants > 0 || points < 1 || !!generated_domain
                  }
                  icon="random"
                  onClick={() => act('random_domain')}
                  mr={1}
                >
                  Randomize
                </Button>
              </Tooltip>
              <Tooltip content="Accrued points for purchasing domains.">
                <Icon color="pink" name="star" mr={1} />
                {points}
              </Tooltip>
            </Stack>
          }
          fill
          scrollable
          title="Virtual Domains"
        >
          <Tabs fluid>
            <Tabs.Tab
              backgroundColor={getColor(Difficulty.None)}
              textColor="white"
              selected={tab === 0}
              onClick={() => setTab(0)}
              icon="chevron-down"
            >
              Peaceful
            </Tabs.Tab>
            <Tabs.Tab
              backgroundColor={getColor(Difficulty.Low)}
              textColor="black"
              selected={tab === 1}
              onClick={() => setTab(1)}
              icon="chevron-down"
            >
              Easy
            </Tabs.Tab>
            <Tabs.Tab
              backgroundColor={getColor(Difficulty.Medium)}
              textColor="white"
              selected={tab === 2}
              onClick={() => setTab(2)}
              icon="chevron-down"
            >
              Medium
            </Tabs.Tab>
            <Tabs.Tab
              backgroundColor={getColor(Difficulty.High)}
              textColor="white"
              selected={tab === 3}
              onClick={() => setTab(3)}
              icon="chevron-down"
            >
              Hard <Icon name="skull" ml={1} />{' '}
            </Tabs.Tab>
          </Tabs>
          {filtered.map((domain) => (
            <DomainEntry key={domain.id} domain={domain} />
          ))}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <AvatarDisplay />
      </Stack.Item>
      <Stack.Item>
        <Section>
          <Stack fill>
            <Stack.Item grow>
              <NoticeBox info={!!generated_domain}>{selected}</NoticeBox>
            </Stack.Item>
            <Stack.Item>
              <Tooltip content="Begins shutdown. Will notify anyone connected.">
                <Button.Confirm
                  disabled={!ready || !generated_domain}
                  onClick={() => act('stop_domain')}
                >
                  Stop Domain
                </Button.Confirm>
              </Tooltip>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
}

function DomainEntry(props: DomainEntryProps) {
  const {
    domain: {
      announce_ghosts,
      cost,
      desc,
      difficulty,
      id,
      is_modular,
      has_secondary_objectives,
      name,
      reward,
    },
  } = props;
  const { act, data } = useBackend<Data>();
  if (!isConnected(data)) {
    return null;
  }

  const { generated_domain, ready, occupants, randomized, points } = data;

  const current = generated_domain === id;
  const occupied = occupants > 0;
  let buttonIcon, buttonName;
  if (randomized) {
    buttonIcon = '';
    buttonName = '???';
  } else if (current) {
    buttonIcon = 'download';
    buttonName = 'Deployed';
  } else {
    buttonIcon = 'coins';
    buttonName = 'Deploy';
  }

  const canView = name !== '???';

  return (
    <Collapsible
      buttons={
        <Tooltip content={!!generated_domain && 'Stop current domain first.'}>
          <Button
            disabled={!!generated_domain || !ready || occupied || points < cost}
            icon={buttonIcon}
            onClick={() => act('set_domain', { id })}
          >
            {buttonName}
          </Button>
        </Tooltip>
      }
      color={getColor(difficulty)}
      title={
        <>
          {name}
          {!!is_modular && canView && <Icon name="cubes" ml={1} />}
          {!!has_secondary_objectives && canView && <Icon name="gem" ml={1} />}
          {!!announce_ghosts && canView && <Icon name="ghost" ml={1} />}
        </>
      }
    >
      <Stack height={5}>
        <Stack.Item color="label" grow={4}>
          {desc}
          {!!is_modular && ' (Modular)'}
          {!!has_secondary_objectives && ' (Secondary Objective Available)'}
          {!!announce_ghosts && ' (Ghost Interaction)'}
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>
          <Table>
            <Table.Row>
              <Tooltip content="Points cost for deploying domain.">
                <DisplayDetails amount={cost} color="pink" icon="star" />
              </Tooltip>
            </Table.Row>
            <Table.Row>
              <Tooltip content="Reward for competing domain.">
                <DisplayDetails amount={reward} color="gold" icon="coins" />
              </Tooltip>
            </Table.Row>
          </Table>
        </Stack.Item>
      </Stack>
    </Collapsible>
  );
}

const AvatarDisplay = (props) => {
  const { act, data } = useBackend<Data>();
  if (!isConnected(data)) {
    return null;
  }

  const { avatars = [], generated_domain, retries_left } = data;

  return (
    <Section
      title="Connected Clients"
      buttons={
        <Stack align="center">
          {!!generated_domain && (
            <Stack.Item>
              <Tooltip content="Available bandwidth for new connections.">
                <DisplayDetails
                  color="green"
                  icon="broadcast-tower"
                  amount={retries_left}
                />
              </Tooltip>
            </Stack.Item>
          )}
          <Stack.Item>
            <Tooltip content="Refresh avatar data.">
              <Button icon="sync" onClick={() => act('refresh')}>
                Refresh
              </Button>
            </Tooltip>
          </Stack.Item>
        </Stack>
      }
    >
      <Table>
        {avatars.map(({ health, name, pilot, brute, burn, tox, oxy }) => (
          <Table.Row key={name}>
            <Table.Cell color="label">
              {pilot} as{' '}
              <span style={{ color: 'white' }}>&quot;{name}&quot;</span>
            </Table.Cell>
            <Table.Cell collapsing>
              <Stack>
                {brute === 0 && burn === 0 && tox === 0 && oxy === 0 && (
                  <Stack.Item>
                    <Icon color="green" name="check" />
                  </Stack.Item>
                )}
                <Stack.Item>
                  <Icon color={brute > 50 ? 'bad' : 'gray'} name="tint" />
                </Stack.Item>
                <Stack.Item>
                  <Icon color={burn > 50 ? 'average' : 'gray'} name="fire" />
                </Stack.Item>
                <Stack.Item>
                  <Icon
                    color={tox > 50 ? 'green' : 'gray'}
                    name="skull-crossbones"
                  />
                </Stack.Item>
                <Stack.Item>
                  <Icon color={oxy > 50 ? 'blue' : 'gray'} name="lungs" />
                </Stack.Item>
              </Stack>
            </Table.Cell>
            <Table.Cell>
              <ProgressBar
                minValue={-100}
                maxValue={100}
                ranges={{
                  good: [90, Infinity],
                  average: [50, 89],
                  bad: [-Infinity, 45],
                }}
                value={health}
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const DisplayDetails = (props: DisplayDetailsProps) => {
  const { amount = 0, color, icon = 'star' } = props;

  if (amount === 0) {
    return <Table.Cell color="label">None</Table.Cell>;
  }

  if (typeof amount === 'string') {
    return <Table.Cell color="label">{String(amount)}</Table.Cell>; // don't ask
  }

  if (amount > 4) {
    return (
      <Table.Cell>
        <Stack>
          <Stack.Item>{amount}</Stack.Item>
          <Stack.Item>
            <Icon color={color} name={icon} />
          </Stack.Item>
        </Stack>
      </Table.Cell>
    );
  }

  return (
    <Table.Cell>
      <Stack>
        {Array.from({ length: amount }, (_, index) => (
          <Stack.Item key={index}>
            <Icon color={color} name={icon} />
          </Stack.Item>
        ))}
      </Stack>
    </Table.Cell>
  );
};
