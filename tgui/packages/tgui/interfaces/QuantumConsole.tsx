import { Window } from '../layouts';
import { useBackend } from '../backend';
import { Button, Collapsible, Icon, NoticeBox, ProgressBar, Section, Stack, Table, Tooltip } from '../components';
import { BooleanLike } from 'common/react';
import { LoadingScreen } from './common/LoadingToolbox';
import { TableCell, TableRow } from '../components/Table';

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
  cost: number;
  desc: string;
  difficulty: number;
  id: string;
  is_modular: BooleanLike;
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

const isConnected = (data: Data): data is Data & { connected: 1 } =>
  data.connected === 1;

const getColor = (difficulty: number) => {
  switch (difficulty) {
    case Difficulty.Low:
      return 'yellow';
    case Difficulty.Medium:
      return 'average';
    case Difficulty.High:
      return 'bad';
    default:
      return '';
  }
};

export const QuantumConsole = (props) => {
  const { data } = useBackend<Data>();

  return (
    <Window title="Quantum Console" width={500} height={500}>
      <Window.Content>
        {!!data.connected && !data.ready && <LoadingScreen />}
        <AccessView />
      </Window.Content>
    </Window>
  );
};

const AccessView = (props) => {
  const { act, data } = useBackend<Data>();

  if (!isConnected(data)) {
    return <NoticeBox error>No server connected!</NoticeBox>;
  }

  const {
    available_domains = [],
    generated_domain,
    ready,
    occupants,
    points,
    randomized,
  } = data;

  const sorted = available_domains.sort((a, b) => a.cost - b.cost);

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
            <>
              <Button
                disabled={
                  !ready || occupants > 0 || points < 1 || !!generated_domain
                }
                icon="random"
                onClick={() => act('random_domain')}
                mr={1}
                tooltip="Get a random domain for more rewards. Weighted towards your current points. Minimum: 1 point.">
                Randomize
              </Button>
              <Tooltip content="Accrued points for purchasing domains.">
                <Icon color="pink" name="star" mr={1} />
                {points}
              </Tooltip>
            </>
          }
          fill
          scrollable
          title="Virtual Domains">
          {sorted.map((domain) => (
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
              <Button.Confirm
                content="Stop Domain"
                disabled={!ready || !generated_domain}
                onClick={() => act('stop_domain')}
                tooltip="Begins shutdown. Will notify anyone connected."
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const DomainEntry = (props: DomainEntryProps) => {
  const {
    domain: { cost, desc, difficulty, id, is_modular, name, reward },
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

  return (
    <Collapsible
      buttons={
        <Button
          disabled={!!generated_domain || !ready || occupied || points < cost}
          icon={buttonIcon}
          onClick={() => act('set_domain', { id })}
          tooltip={!!generated_domain && 'Stop current domain first.'}>
          {buttonName}
        </Button>
      }
      color={getColor(difficulty)}
      title={
        <>
          {name}
          {difficulty === Difficulty.High && <Icon name="skull" ml={1} />}
          {!!is_modular && name !== '???' && <Icon name="cubes" ml={1} />}
        </>
      }>
      <Stack height={5}>
        <Stack.Item color="label" grow={4}>
          {desc}
          {!!is_modular && ' (Modular)'}
          {difficulty === Difficulty.High && ' (Hard)'}
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>
          <Table>
            <TableRow>
              <DisplayDetails amount={cost} color="pink" icon="star" />
            </TableRow>
            <TableRow>
              <DisplayDetails amount={difficulty} color="white" icon="skull" />
            </TableRow>
            <TableRow>
              <DisplayDetails amount={reward} color="gold" icon="coins" />
            </TableRow>
          </Table>
        </Stack.Item>
      </Stack>
    </Collapsible>
  );
};

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
            <Button
              icon="sync"
              onClick={() => act('refresh')}
              tooltip="Refresh avatar data.">
              Refresh
            </Button>
          </Stack.Item>
        </Stack>
      }>
      <Table>
        {avatars.map(({ health, name, pilot, brute, burn, tox, oxy }) => (
          <TableRow key={name}>
            <TableCell color="label">
              {pilot} as{' '}
              <span style={{ color: 'white' }}>&quot;{name}&quot;</span>
            </TableCell>
            <TableCell collapsing>
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
            </TableCell>
            <TableCell>
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
            </TableCell>
          </TableRow>
        ))}
      </Table>
    </Section>
  );
};

const DisplayDetails = (props: DisplayDetailsProps) => {
  const { amount = 0, color, icon = 'star' } = props;

  if (amount === 0) {
    return <TableCell color="label">None</TableCell>;
  }

  if (typeof amount === 'string') {
    return <TableCell color="label">{String(amount)}</TableCell>; // don't ask
  }

  if (amount > 4) {
    return (
      <TableCell>
        <Stack>
          <Stack.Item>{amount}</Stack.Item>
          <Stack.Item>
            <Icon color={color} name={icon} />
          </Stack.Item>
        </Stack>
      </TableCell>
    );
  }

  return (
    <TableCell>
      <Stack>
        {Array.from({ length: amount }, (_, index) => (
          <Stack.Item key={index}>
            <Icon color={color} name={icon} />
          </Stack.Item>
        ))}
      </Stack>
    </TableCell>
  );
};
