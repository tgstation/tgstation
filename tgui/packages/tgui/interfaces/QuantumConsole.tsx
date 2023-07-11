import { Window } from '../layouts';
import { useBackend } from '../backend';
import { Button, Icon, LabeledList, NoticeBox, Section, Stack, Table } from '../components';
import { TableCell, TableRow } from '../components/Table';

type Data =
  | {
      connected: true;
      available_domains: Domain[];
      generated_domain: string;
      occupants: Occupant[];
    }
  | {
      connected: false;
    };

type Occupant = {
  health: number;
  name: string;
};

type Domain = {
  cost: number;
  desc: string;
  difficulty: number;
  id: string;
  name: string;
  reward: number;
};

/** Type guard */
const isConnected = (data: Data): data is Data & { connected: true } =>
  data.connected;

const getColor = (difficulty: number) => {
  switch (difficulty) {
    case 2:
      return 'average';
    case 3:
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

  const { available_domains = [], generated_domain, occupants = [] } = data;

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section fill title="Virtual Domains">
          <Table>
            {available_domains.map(
              ({ cost, desc, difficulty, id, name, reward }) => {
                const current = name === generated_domain;

                return (
                  <>
                    <TableRow className="candystripe" key={name}>
                      <TableCell color={getColor(difficulty)}>
                        {difficulty === 4 && <Icon name="skull" />} {name}
                      </TableCell>
                      <TableCell>{desc}</TableCell>
                      <TableCell>
                        <Button
                          disabled={current}
                          icon={current ? 'download' : 'coins'}
                          tooltip={current ? '' : `Cost: ${cost}`}
                          tooltipPositition="left"
                          onClick={() => act('set_domain', { id })}>
                          {current ? 'Deployed' : 'Purchase'}
                        </Button>
                      </TableCell>
                    </TableRow>
                    <TableRow>
                      <TableCell>Difficulty: {difficulty}</TableCell>
                      <TableCell>Reward: {reward}</TableCell>
                      <TableCell>Cost: {cost}</TableCell>
                    </TableRow>
                  </>
                );
              }
            )}
          </Table>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Connected Clients">
          <LabeledList>
            {occupants.map(({ health, name }) => (
              <LabeledList.Item className="candystripe" key={name} label={name}>
                Something
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section>Generated Domain: {generated_domain ?? 'None'}</Section>
      </Stack.Item>
    </Stack>
  );
};
