import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Input,
  NoticeBox,
  RestrictedInput,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  name: string;
  owner_token: string;
  money: number;
  transaction_list: Transactions[];
  wanted_token: string;
};

type Transactions = {
  adjusted_money: number;
  reason: string;
};

export const NtosPay = (props) => {
  return (
    <NtosWindow width={500} height={655}>
      <NtosWindow.Content>
        <NtosPayContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosPayContent = (props) => {
  const { data } = useBackend<Data>();
  const { name } = data;

  if (!name) {
    return (
      <NoticeBox>
        Чтобы воспользоваться этим приложением, необходимо вставить свою
        ID-карту в слот для карты.
      </NoticeBox>
    );
  }

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Introduction />
      </Stack.Item>
      <Stack.Item>
        <TransferSection />
      </Stack.Item>
      <Stack.Item grow>
        <TransactionHistory />
      </Stack.Item>
    </Stack>
  );
};

/** Displays the user's name and balance. */
const Introduction = (props) => {
  const { data } = useBackend<Data>();
  const { name, owner_token, money } = data;
  return (
    <Section textAlign="center">
      <Table>
        <Table.Row>Привет, {name}.</Table.Row>
        <Table.Row>Ваш платежный токен {owner_token}.</Table.Row>
        <Table.Row>Баланс: {money}¢</Table.Row>
      </Table>
    </Section>
  );
};

/** Displays the transfer section. */
const TransferSection = (props) => {
  const { act, data } = useBackend<Data>();
  const { money, wanted_token } = data;

  const [token, setToken] = useState('');
  const [moneyToSend, setMoneyToSend] = useState(1);
  const [nameToToken, setNameToToken] = useState('');
  const [moneyToSendIsValid, setMoneyToSendIsValid] = useState(true);

  return (
    <Stack>
      <Stack.Item>
        <Section title="Перевести деньги">
          <Box>
            <Tooltip
              content="Введите платежный токен счета, на который вы хотите перевести кредиты."
              position="top"
            >
              <Input
                placeholder="Платежный токен"
                width="190px"
                onChange={setToken}
              />
            </Tooltip>
          </Box>
          <Tooltip
            content="Укажите количество кредитов для перевода."
            position="top"
          >
            <RestrictedInput
              width="83px"
              minValue={1}
              maxValue={money}
              onChange={setMoneyToSend}
              onValidationChange={setMoneyToSendIsValid}
              value={moneyToSend}
            />
          </Tooltip>
          <Button
            disabled={!moneyToSendIsValid}
            onClick={() =>
              act('Transaction', {
                token: token,
                amount: moneyToSend,
              })
            }
          >
            Отправить
          </Button>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Получить токен" width="275px" height="98px">
          <Box>
            <Input
              placeholder="Полное название счета."
              width="190px"
              onChange={setNameToToken}
            />
            <Button
              onClick={() =>
                act('GetPayToken', {
                  wanted_name: nameToToken,
                })
              }
            >
              Принять
            </Button>
          </Box>
          <Divider hidden />
          <Box nowrap>{wanted_token}</Box>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

/** Displays the transaction history. */
const TransactionHistory = (props) => {
  const { data } = useBackend<Data>();
  const { transaction_list = [] } = data;

  return (
    <Section fill title="История переводов">
      <Section fill scrollable title={<TableHeaders />}>
        <Table>
          {transaction_list.map((log, index) => (
            <Table.Row
              key={index}
              className="candystripe"
              color={log.adjusted_money < 1 ? 'red' : 'green'}
            >
              <Table.Cell width="100px">
                {log.adjusted_money > 1 ? '+' : ''}
                {log.adjusted_money}
              </Table.Cell>
              <Table.Cell textAlign="center">{log.reason}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Section>
  );
};

/** Renders a set of sticky headers */
const TableHeaders = (props) => {
  return (
    <Table>
      <Table.Row>
        <Table.Cell color="label" width="100px">
          Сумма
        </Table.Cell>
        <Table.Cell color="label" textAlign="center">
          Причина
        </Table.Cell>
      </Table.Row>
    </Table>
  );
};
