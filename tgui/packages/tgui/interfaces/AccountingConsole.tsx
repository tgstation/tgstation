import { BlockQuote, Collapsible, LabeledList, Modal, Section, Stack, Tabs } from '../components';
import { useBackend } from '../backend';
import { useLocalState } from '../backend';
import { Window } from '../layouts';
import { BooleanLike } from 'common/react';

type Data = {
  PlayerAccounts: PlayerAccount[];
  AuditLog: AuditLog[];
  Crashing: BooleanLike;
};

type PlayerAccount = {
  index: number;
  name: string;
  balance: number;
  job: string;
  modifier: number;
};

type AuditLog = {
  index: number;
  account: number;
  cost: number;
  vendor: string;
};

type Screens = 'users' | 'audit';

export const AccountingConsole = (props, context) => {
  const [screenmode, setScreenmode] = useLocalState<Screens>(
    context,
    'tab_main',
    'users'
  );

  return (
    <Window width={300} height={360}>
      <Window.Content>
        <Stack fill vertical>
          <MarketCrashing />
          <Stack.Item>
            <Tabs fluid textAlign="center">
              <Tabs.Tab
                selected={screenmode === 'users'}
                onClick={() => setScreenmode('users')}>
                Users
              </Tabs.Tab>
              <Tabs.Tab
                selected={screenmode === 'audit'}
                onClick={() => setScreenmode('audit')}>
                Audit
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {screenmode === 'users' && <UsersScreen />}
            {screenmode === 'audit' && <AuditScreen />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const UsersScreen = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { PlayerAccounts } = data;

  return (
    <Section fill scrollable title="Crew Account Summary">
      {PlayerAccounts.map((account) => (
        <Collapsible fill key={account.index} title={account.name}>
          <LabeledList>
            <LabeledList.Item label="Occupation">
              {account.job}
            </LabeledList.Item>
            <LabeledList.Item label="Balance">
              {account.balance}
            </LabeledList.Item>
            <LabeledList.Item label="Pay Modifier">
              {account.modifier * 100}%
            </LabeledList.Item>
          </LabeledList>
        </Collapsible>
      ))}
    </Section>
  );
};

const AuditScreen = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { AuditLog } = data;

  return (
    <Section fill scrollable>
      {AuditLog.map((purchase) => (
        <BlockQuote key={purchase.index} p={1}>
          <b>{purchase.account}</b> spent <b>{purchase.cost}</b> cr at{' '}
          <i>{purchase.vendor}.</i>
        </BlockQuote>
      ))}
    </Section>
  );
};

/** The modal menu that contains the prompts to making new channels. */
const MarketCrashing = (props, context) => {
  const { data } = useBackend<Data>(context);

  const { Crashing } = data;
  if (!Crashing) {
    return null;
  }
  return (
    <Modal textAlign="center" mr={1.5}>
      <blink>OH GOD THE ECONOMY IS RUINED.</blink>
    </Modal>
  );
};
