import { NtosPayContent } from '../../tgui/interfaces/NtosPay';
import { useBackend, useSharedState } from '../../tgui/backend';
import { NtosWindow } from '../../tgui/layouts';
import { NoticeBox, Stack, Tabs, Table, Button } from '../../tgui/components';

export const NtosPayVoidcrew = (props, context) => {
  const { data } = useBackend(context);
  const NTOS_PAY = 1;
  const ALL_ACCOUNTS = 2;
  const [screenmode, setScreenmode] = useSharedState(
    context,
    'tab_main',
    NTOS_PAY
  );

  return (
    <NtosWindow>
      <NtosWindow.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs fluid textAlign="center">
              <Tabs.Tab
                color="Green"
                selected={screenmode === NTOS_PAY}
                onClick={() => setScreenmode(NTOS_PAY)}>
                Transaction History
              </Tabs.Tab>
              <Tabs.Tab
                Color="Blue"
                selected={screenmode === ALL_ACCOUNTS}
                onClick={() => setScreenmode(ALL_ACCOUNTS)}>
                All Connected Accounts
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {screenmode === NTOS_PAY && <NtosPayContent />}
            {screenmode === ALL_ACCOUNTS && <AllAccounts />}
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

type Info = {
  all_accounts: Accounts[];
  swiped_id: SwipedID[];
};

type Accounts = {
  ref: string[];
  name: string;
};

type SwipedID = {
  ref: string[];
  account: string;
};

const AllAccounts = (props, context) => {
  const { act, data } = useBackend<Info>(context);
  const { all_accounts, swiped_id } = data;

  if (!all_accounts) {
    return (
      <NoticeBox>
        You need to insert your ID card into the card slot in order to use this
        application.
      </NoticeBox>
    );
  }
  return (
    <>
      {!!swiped_id && (
        <Table>
          {swiped_id.map((id) => (
            <Table.Row key={id.ref} className="candystripe">
              <Button
                icon="card"
                content={id.account}
                tooltip="Adds the user to our bank account."
                onClick={() => act('add_account')}
              />
            </Table.Row>
          ))}
        </Table>
      )}
      <Table>
        {all_accounts.map((account) => (
          <Table.Row key={account.ref} className="candystripe">
            <Table.Cell>{account.name}</Table.Cell>
            <Button
              icon="lock"
              color="caution"
              content="Remove ID"
              tooltip="Removes the ID as a user from the bank account"
              onClick={() =>
                act('remove_account', {
                  removed_account: account.ref,
                })
              }
            />
          </Table.Row>
        ))}
      </Table>
    </>
  );
};
