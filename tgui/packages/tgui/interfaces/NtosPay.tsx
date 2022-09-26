import { NtosWindow } from '../layouts';
import { useBackend } from '../backend';
import { Stack, Section, Box, Button, NumberInput, Input, Table, Tooltip, NoticeBox, Divider } from '../components';

type Data = {
  name: string;
  owner_token: string;
  money: number;
  token: string;
  money_to_send: number;
  trans_list: Transactions[];
  wanted_token: string;
};

type Transactions = {
  adjusted_money: number;
  reason: string;
};
let name_to_token;

export const NtosPay = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const {
    name,
    owner_token,
    money,
    token,
    money_to_send,
    trans_list = [],
    wanted_token,
  } = data;

  if (name) {
    return (
      <NtosWindow width={495} height={655}>
        <NtosWindow.Content>
          <Stack vertical>
            <Section textAlign="center">
              <Table>
                <Table.Row>Hi, {name}.</Table.Row>
                <Table.Row>Your pay token is {owner_token}.</Table.Row>
                <Table.Row>
                  Account balance: {money} credit{money === 1 ? '' : 's'}
                </Table.Row>
              </Table>
            </Section>
          </Stack>
          <Divider hidden />

          <Stack>
            <Stack.Item>
              <Section vertical title="Transfer Money">
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
            </Stack.Item>
            <Stack.Item>
              <Section title="Know Token" width="270px" height="98px">
                <Box>
                  <Input
                    placeholder="Full name of account."
                    width="190px"
                    onChange={(e, value) => (name_to_token = value)}
                  />
                  <Button
                    content="Get it"
                    onClick={() =>
                      act('GetPayToken', {
                        wanted_name: name_to_token,
                      })
                    }
                  />
                </Box>
                <Divider hidden />
                <Box nowrap>{wanted_token}</Box>
              </Section>
            </Stack.Item>
          </Stack>

          <Divider hidden />

          <Stack vertical>
            <Section title="Transaction History">
              <Tooltip
                content="Here are last 20 logs of your transactions."
                position="auto">
                <Table>
                  <Table.Row header>
                    <Table.Cell>Balance</Table.Cell>
                    <Table.Cell textAlign="center">Reason</Table.Cell>
                  </Table.Row>
                  {trans_list.map((log) => (
                    <Table.Row
                      key={log}
                      color={log.adjusted_money < 1 ? 'red' : 'green'}>
                      <Table.Cell width="100px">
                        {/* {log.adjusted_money > 1 ? '+' : ''} */}
                        {log.adjusted_money}
                      </Table.Cell>
                      <Table.Cell textAlign="center">{log.reason}</Table.Cell>
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
    <NtosWindow width={512} height={130}>
      <NtosWindow.Content>
        <NoticeBox>
          You need to insert your ID card into the card slot in order to use
          this application.
        </NoticeBox>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
