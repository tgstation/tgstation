import { NtosWindow } from '../layouts';
import { useBackend } from '../backend';
import { Stack, Section, Box, Button, NumberInput, Input, Table, Tooltip, NoticeBox } from '../components';

type Data = {
  name: string;
  owner_token: string;
  money: number;
  token: string;
  money_to_send: number;
  trans_list: Transactions[];
};

type Transactions = {
  adjusted_money: number;
  reason: string;
};

export const NtosPay = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const {
    name,
    owner_token,
    money,
    token,
    money_to_send,
    trans_list = [],
  } = data;

  if (name) {
    return (
      <NtosWindow width={300} height={660}>
        <NtosWindow.Content scrollable>
          <Stack vertical>
            <Section fill textAlign="left">
              <Table>
                <Table.Row>Hi, {name}.</Table.Row>
                <Table.Row>Your pay token is {owner_token}.</Table.Row>
                <Table.Row>
                  Account balance: {money} credit{money === 1 ? '' : 's'}
                </Table.Row>
              </Table>
            </Section>
            <Section horisontal title="Transfer Money" fill>
              <Box>
                <Tooltip
                  content="Enter the pay token of the account you want to trasfer credits."
                  position="top">
                  <Input
                    placeholder="Pay Token"
                    width="190px"
                    onChange={(e, value) =>
                      act('changeValue', {
                        token: value,
                      })
                    }
                  />
                </Tooltip>
              </Box>
              <NumberInput
                animate
                unit="cr"
                value={money_to_send}
                minValue={1}
                maxValue={money}
                width="83px"
                onChange={(e, value) =>
                  act('changeValue', {
                    money_to_send: value,
                  })
                }
              />
              <Button
                content="Send credits"
                onClick={() => act('Transaction')}
              />
            </Section>
            <Section title="Transaction History">
              <Tooltip
                content="Here are last 20 logs of your transactions."
                position="auto">
                <Table>
                  <Table.Row header>
                    <Table.Cell>Balance</Table.Cell>
                    <Table.Cell>Reason</Table.Cell>
                  </Table.Row>
                  {trans_list.map((log) => (
                    <Table.Row
                      key={log.reason}
                      color={log.adjusted_money < 1 ? 'red' : 'green'}>
                      <Table.Cell width="80px">
                        {log.adjusted_money > 1 ? '+' : ''}
                        {log.adjusted_money}
                      </Table.Cell>
                      <Table.Cell>{log.reason}</Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              </Tooltip>
            </Section>
          </Stack>
        </NtosWindow.Content>
      </NtosWindow>
    );
  }
  return (
    <NtosWindow width={335} height={130}>
      <NtosWindow.Content>
        <NoticeBox>
          You need to insert your ID card into the card slot in order to use
          this application.
        </NoticeBox>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
