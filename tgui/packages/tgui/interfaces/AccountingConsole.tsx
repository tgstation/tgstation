import { useState } from 'react';
import {
  BlockQuote,
  Collapsible,
  Modal,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

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

enum SCREENS {
  users,
  audit,
}

export const AccountingConsole = (props) => {
  const [screenmode, setScreenmode] = useState(SCREENS.users);

  return (
    <Window width={300} height={360}>
      <Window.Content>
        <Stack fill vertical>
          <MarketCrashing />
          <Stack.Item>
            <Tabs fluid textAlign="center">
              <Tabs.Tab
                selected={screenmode === SCREENS.users}
                onClick={() => setScreenmode(SCREENS.users)}
              >
                Users
              </Tabs.Tab>
              <Tabs.Tab
                selected={screenmode === SCREENS.audit}
                onClick={() => setScreenmode(SCREENS.audit)}
              >
                Audit
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {screenmode === SCREENS.users && <UsersScreen />}
            {screenmode === SCREENS.audit && <AuditScreen />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const UsersScreen = (props) => {
  const { data } = useBackend<Data>();
  const { PlayerAccounts } = data;

  return (
    <Section fill scrollable title="Crew Account Summary">
      {PlayerAccounts.map((account) => (
        <Collapsible
          key={account.index}
          title={account.name + ' the ' + account.job}
        >
          <Stack vertical>
            <BlockQuote>
              <Stack.Item textColor={'green'}>
                {account.balance} credit balance
              </Stack.Item>
              <Stack.Item>
                Employee has {account.modifier * 100}% pay modifier
              </Stack.Item>
            </BlockQuote>
          </Stack>
        </Collapsible>
      ))}
    </Section>
  );
};

const AuditScreen = (props) => {
  const { data } = useBackend<Data>();
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
const MarketCrashing = (props) => {
  const { data } = useBackend<Data>();

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
