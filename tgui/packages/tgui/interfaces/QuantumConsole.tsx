import { Window } from '../layouts';
import { useBackend } from '../backend';
import { Button, Collapsible, Icon, LabeledList, NoticeBox, ProgressBar, Section, Stack, Table, Tooltip } from '../components';
import { BooleanLike } from 'common/react';
import { LoadingScreen } from './common/LoadingToolbox';
import { TableCell, TableRow } from '../components/Table';
import { logger } from '../logging';

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
      scanner_tier: number;
    }
  | {
      connected: 0;
    };

type Avatar = {
  health: number;
  name: string;
  pilot: string;
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
                disabled={!ready || occupants > 0 || !!generated_domain}
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
            <Stack.Item grow>Loaded: {generated_domain ?? 'None'}</Stack.Item>
            <Stack.Item>
              <Button
                disabled={!ready || !generated_domain || occupants > 0}
                onClick={() => act('stop_domain')}>
                Stop Domain
              </Button>
              <Button
                disabled={!ready || !generated_domain}
                onClick={() => act('check_completion')}>
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
    buttonIcon = 'question';
    buttonName = '???';
  } else if (current) {
    buttonIcon = 'download';
    buttonName = 'Deployed';
  } else {
    buttonIcon = 'coins';
    buttonName = 'Deploy';
  }

  logger.log(generated_domain);

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

  const { avatars = [] } = data;

  return (
    <Section
      title="Connected Clients"
      buttons={
        <Button
          icon="sync"
          onClick={() => act('refresh')}
          tooltip="Refresh avatar data">
          Refresh
        </Button>
      }>
      <Table>
        {avatars.map(({ health, name, pilot }) => (
          <TableRow key={name}>
            <TableCell color="label">{pilot}:</TableCell>
            <TableCell collapsing>&quot;{name}&quot;</TableCell>
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

type DisplayDetailsProps = {
  amount: number | string;
  icon: string;
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
