import { Window } from '../layouts';
import { useBackend } from '../backend';
import { Button, LabeledList, NoticeBox, Section, Stack } from '../components';

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
  id: string;
  name: string;
};

/** Type guard */
const isConnected = (data: Data): data is Data & { connected: true } =>
  data.connected;

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
          <LabeledList>
            {available_domains.map(({ cost, desc, id, name }) => {
              const current = name === generated_domain;

              return (
                <LabeledList.Item
                  buttons={
                    <Button
                      disabled={current}
                      icon={current ? 'download' : 'coins'}
                      tooltip={current ? '' : `Cost: ${cost}`}
                      tooltipPositition="left"
                      onClick={() => act('set_domain', { id })}>
                      {current ? 'Deployed' : 'Purchase'}
                    </Button>
                  }
                  className="candystripe"
                  key={name}
                  label={name}>
                  {desc}
                </LabeledList.Item>
              );
            })}
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Occupants">
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
