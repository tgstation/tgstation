import { BlockQuote, Collapsible, LabeledList, Modal, Section, Tabs } from '../components';
import { useBackend } from '../backend';
import { useLocalState } from '../backend';
import { Window } from '../layouts';

export const AccountingConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const { PlayerAccounts, AuditLog } = data;
  const USER_SCREEN = 1;
  const AUDIT_SCREEN = 2;
  const [screenmode, setScreenmode] = useLocalState(
    context,
    'tab_main',
    USER_SCREEN
  );
  return (
    <Window width={300} height={360}>
      <Window.Content scrollable>
        <MarketCrashing />
        <Tabs fluid textAlign="center">
          <Tabs.Tab
            selected={screenmode === USER_SCREEN}
            onClick={() => setScreenmode(USER_SCREEN)}>
            Users
          </Tabs.Tab>
          <Tabs.Tab
            selected={screenmode === AUDIT_SCREEN}
            onClick={() => setScreenmode(AUDIT_SCREEN)}>
            Audit
          </Tabs.Tab>
        </Tabs>
        {screenmode === USER_SCREEN && (
          <Section title="Crew Account Summary">
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
        )}
        {screenmode === AUDIT_SCREEN && (
          <Section>
            {AuditLog.map((purchase) => (
              <BlockQuote key={purchase.index} p={1}>
                <b>{purchase.account}</b> spent <b>{purchase.cost}</b> cr at{' '}
                <i>{purchase.vendor}.</i>
              </BlockQuote>
            ))}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

/** The modal menu that contains the prompts to making new channels. */
const MarketCrashing = (props, context) => {
  const { act, data } = useBackend(context);
  const [lockedmode, setLockedmode] = useLocalState(context, 'lockedmode', 1);
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
