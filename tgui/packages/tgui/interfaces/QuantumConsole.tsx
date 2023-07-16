import { Window } from '../layouts';
import { useBackend } from '../backend';
import { Button, Collapsible, Icon, LabeledList, NoticeBox, Section, Stack, Tooltip } from '../components';
import { BooleanLike } from 'common/react';

type Data =
  | {
      available_domains: Domain[];
      avatars: Avatar[];
      connected: 1;
      generated_domain: string;
      loading: BooleanLike;
      occupants: number;
      points: number;
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
  reward: number;
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

/** Type guard */
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
  return (
    <Window title="Quantum Console" width={500} height={500}>
      <Window.Content>
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
    loading,
    occupants,
    points,
  } = data;

  const sorted = available_domains.sort((a, b) => a.difficulty - b.difficulty);

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          buttons={
            <Tooltip content="Accrued points for purchasing domains.">
              <Icon color="pink" name="star" mr={1} />
              {points}
            </Tooltip>
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
                disabled={!!loading || !generated_domain || occupants > 0}
                onClick={() => act('stop_domain')}>
                Stop Domain
              </Button>
              <Button
                disabled={!!loading || !generated_domain}
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

  const { generated_domain, loading, occupants, points, scanner_tier } = data;

  const canView = difficulty <= scanner_tier;
  const canViewRewards = difficulty <= scanner_tier + 1;
  const current = generated_domain === name;
  const occupied = occupants > 0;

  return (
    <Collapsible
      buttons={
        <Button
          disabled={current || !!loading || occupied || points < cost}
          icon={current ? 'download' : 'coins'}
          onClick={() => act('set_domain', { id })}>
          Deploy{current && 'ed'}
        </Button>
      }
      color={getColor(difficulty)}
      title={
        <>
          {canView ? name : '???'}
          {difficulty === Difficulty.High && <Icon name="skull" ml={1} />}
        </>
      }>
      <Stack height={5}>
        <Stack.Item color="label" grow={2}>
          {canView
            ? desc
            : 'Limited scanning capabilities. Cannot infer domain details.'}
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
            {canViewRewards && (
              <LabeledList.Item label="Reward">
                <DisplayDetails amount={reward} icon="star" />
              </LabeledList.Item>
            )}
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
      <LabeledList>
        {avatars.map(({ health, name, pilot }) => (
          <LabeledList.Item key={name} label={pilot}>
            &quot;{name}&quot; | {health} health
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

const DisplayDetails = (props, context) => {
  const { amount = 0, icon = 'star' } = props;

  if (amount === 0) {
    return <>None</>;
  }

  return (
    <>
      {Array.from({ length: amount }, (_, index) => (
        <Icon key={index} name={icon} />
      ))}
    </>
  );
};
