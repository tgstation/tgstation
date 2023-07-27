import { Window } from '../layouts';
import { useBackend } from '../backend';
import { Button, Collapsible, Icon, LabeledList, NoticeBox, ProgressBar, Section, Stack, Table, Tooltip } from '../components';
import { BooleanLike } from 'common/react';
import { LoadingScreen } from './common/LoadingToolbox';
import { TableCell, TableRow } from '../components/Table';
import { debounce } from 'common/timer';

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
  name: string;
  reward: number | string;
};

type DomainEntryProps = {
  domain: Domain;
};

type DisplayDetailsProps = {
  amount: number | string;
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

const completionDebounce = debounce(
  (act: (action: string) => void) => act('check_completion'),
  300
);

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

export const QuantumConsole = (props, context) => {
  const { data } = useBackend<Data>(context);

  return (
    <Window title="Quantum Console" width={500} height={500}>
      <Window.Content>
        {!!data.connected && !data.ready && <LoadingScreen />}
        <AccessView />
      </Window.Content>
    </Window>
  );
};

const AccessView = (props, context) => {
  const { act, data } = useBackend<Data>(context);

  if (!isConnected(data)) {
    return <NoticeBox error>No server connected!</NoticeBox>;
  }

  const {
    available_domains = [],
    generated_domain,
    ready,
    occupants,
    points,
  } = data;

  const sorted = available_domains.sort((a, b) => a.difficulty - b.difficulty);

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
                tooltip="Get a random domain for more rewards. Weighted towards your current points.">
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
              <NoticeBox info={!!generated_domain}>
                {generated_domain ?? 'Nothing loaded'}
              </NoticeBox>
            </Stack.Item>
            <Stack.Item>
              <Button.Confirm
                content="Stop Domain"
                disabled={!ready || !generated_domain}
                onClick={() => act('stop_domain')}
                tooltip="Begins shutdown. Will notify anyone connected."
              />
              <Button
                disabled={!ready || !generated_domain}
                onClick={() => completionDebounce(act)}
                tooltip="Check the send area for loot crates.">
                Check Completion
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const DomainEntry = (props: DomainEntryProps, context) => {
  const {
    domain: { cost, desc, difficulty, id, name, reward },
  } = props;
  const { act, data } = useBackend<Data>(context);
  if (!isConnected(data)) {
    return null;
  }

  const { generated_domain, ready, occupants, randomized, points } = data;

  const current = generated_domain === name;
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
          disabled={
            current || randomized || !ready || occupied || points < cost
          }
          icon={buttonIcon}
          onClick={() => act('set_domain', { id })}>
          {buttonName}
        </Button>
      }
      color={getColor(difficulty)}
      title={
        <>
          {name}
          {difficulty === Difficulty.High && <Icon name="skull" ml={1} />}
        </>
      }>
      <Stack height={5}>
        <Stack.Item color="label" grow={2}>
          {desc}
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item label="Cost">
              <DisplayDetails amount={cost} icon="coins" />
            </LabeledList.Item>
            <LabeledList.Item label="Difficulty">
              <DisplayDetails amount={difficulty} icon="skull" />
            </LabeledList.Item>
            <LabeledList.Item label="Reward">
              <DisplayDetails amount={reward} icon="star" />
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Collapsible>
  );
};

const AvatarDisplay = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  if (!isConnected(data)) {
    return null;
  }

  const { avatars = [], retries_left } = data;

  return (
    <Section
      title="Connected Clients"
      buttons={
        <>
          {retries_left}
          <Icon name="broadcast-tower" />
          <Button
            icon="sync"
            onClick={() => act('refresh')}
            tooltip="Refresh avatar data.">
            Refresh
          </Button>
        </>
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

const DisplayDetails = (props: DisplayDetailsProps, context) => {
  const { amount = 0, icon = 'star' } = props;

  if (amount === 0) {
    return <>None</>;
  }

  if (typeof amount === 'string') {
    return <>{String(amount)}</>; // don't ask
  }

  return (
    <>
      {Array.from({ length: amount }, (_, index) => (
        <Icon key={index} name={icon} />
      ))}
    </>
  );
};
