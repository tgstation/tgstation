import { useState } from 'react';
import {
  Button,
  Icon,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { NEW_ACCOUNT_AGE, NEW_ACCOUNT_NOTICE, sortTypes } from './constants';
import { Filters } from './Filters';
import { getConditionColor, getPingColor, numberToDays } from './helpers';
import { ShowPing } from './Ping';
import type { WhoData } from './types';

export function UserInfo(props) {
  const { act, data } = useBackend<WhoData>();
  const { user } = data;

  return (
    <Section>
      <Stack fill ml={0.5} mr={0.5}>
        <Stack.Item grow bold fontSize={1.2}>
          {user.key}{' '}
          {!!user.admin && (
            <Tooltip content={'Администратор'}>
              <Icon name="crown" color="gold" />
            </Tooltip>
          )}
        </Stack.Item>
        <Stack.Item mr={1} align="center">
          <ShowPing user={user} />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon={'arrows-rotate'}
            tooltip={'Обновить'}
            tooltipPosition={'top-end'}
            onClick={() => act('update')}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
}

export function Clients(props) {
  const { act, data } = useBackend<WhoData>();
  const { user, clients } = data;
  const { setSubjectRef } = props;

  const [sortType, setSortType] = useState(Object.keys(sortTypes)[0]);
  const [searchText, setSearchText] = useState('');
  const [moreInfo, setMoreInfo] = useState(false);

  const clientsList = Object.values(clients).flat();
  const sortedClients = clientsList
    .filter((client) =>
      client.key.toLowerCase().includes(searchText.toLowerCase()),
    )
    .sort(sortTypes[sortType]);

  return (
    <Section
      fill
      title={`Онлайн: ${clientsList.length}`}
      buttons={
        !!user.admin && (
          <>
            {!moreInfo && (
              <Button
                icon={'question'}
                tooltip={'ПКМ позволяет обсёрвить моба клиента.'}
                tooltipPosition={'bottom-end'}
              />
            )}
            <Button
              icon={moreInfo ? 'compress' : 'expand'}
              tooltip={moreInfo ? 'Меньше информации' : 'Больше информации'}
              tooltipPosition={'bottom-end'}
              onClick={() => setMoreInfo(!moreInfo)}
            />
          </>
        )
      }
    >
      <Stack fill vertical>
        <Stack.Item>
          <Filters
            sortType={sortType}
            setSortType={setSortType}
            searchText={searchText}
            setSearchText={setSearchText}
          />
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow overflowY="auto">
          {moreInfo && !!user.admin ? (
            <ClientsTable
              sortType={sortType}
              clients={sortedClients}
              setSubjectRef={setSubjectRef}
            />
          ) : (
            <ClientsCompact
              sortType={sortType}
              clients={sortedClients}
              setSubjectRef={setSubjectRef}
            />
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function ClientsTable(props) {
  const { act } = useBackend();
  const { clients, sortType, setSubjectRef } = props;

  return (
    <Table className="Who_Table">
      <Table.Row header>
        <Table.Cell>CKEY</Table.Cell>
        <Table.Cell>
          {!['Возраст аккаунта', 'Версия BYOND'].includes(sortType)
            ? 'Персонаж'
            : sortType}
        </Table.Cell>
        <Table.Cell>Состояние</Table.Cell>
        <Table.Cell>Пинг</Table.Cell>
        <Table.Cell collapsing />
      </Table.Row>
      {clients.map((client) => {
        return (
          <Table.Row
            key={client.key}
            backgroundColor={
              client.accountAge < NEW_ACCOUNT_AGE &&
              'hsla(120, 100%, 25%, 0.25)'
            }
          >
            {client.accountAge < NEW_ACCOUNT_AGE ? (
              <Tooltip content={NEW_ACCOUNT_NOTICE}>
                <Table.Cell
                  bold
                  className="Who_Table--clickable"
                  onClick={() => act('follow', { ref: client.mobRef })}
                >
                  <Icon name="baby" color="green" size={1.25} /> {client.key}
                </Table.Cell>
              </Tooltip>
            ) : (
              <Table.Cell
                bold
                className="Who_Table--clickable"
                onClick={() => act('follow', { ref: client.mobRef })}
              >
                {client.key}
              </Table.Cell>
            )}
            <Table.Cell>
              {!['Возраст аккаунта', 'Версия BYOND'].includes(sortType)
                ? client.status?.where
                : sortType === 'Версия BYOND'
                  ? client.byondVersion
                  : numberToDays(client.accountAge)}
            </Table.Cell>
            <Table.Cell color={getConditionColor(client.status.state)}>
              {client.status.state}
            </Table.Cell>
            <Table.Cell color={getPingColor(client.ping.avgPing)}>
              {Math.round(client.ping.avgPing)}ms
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                icon="bars"
                tooltip="Подробнее"
                tooltipPosition={'bottom-end'}
                onClick={() => {
                  setSubjectRef(client.mobRef);
                  act('show_more_info', { ref: client.mobRef });
                }}
              />
            </Table.Cell>
          </Table.Row>
        );
      })}
    </Table>
  );
}

function ClientsCompact(props) {
  const { act, data } = useBackend<WhoData>();
  const { clients, sortType, setSubjectRef } = props;
  return (
    <Stack wrap g={0.5}>
      {clients.map((client) => (
        <Stack.Item key={client.key}>
          <Button
            color={
              sortType === 'Пинг'
                ? getPingColor(client.ping.avgPing)
                : getConditionColor(client.status?.state)
            }
            tooltip={
              (sortType !== 'Пинг' || client.accountAge < NEW_ACCOUNT_AGE) && (
                <Stack vertical align="center">
                  {client.accountAge < NEW_ACCOUNT_AGE && (
                    <Stack.Item>{NEW_ACCOUNT_NOTICE}</Stack.Item>
                  )}
                  {sortType !== 'Пинг' && (
                    <Stack.Item>
                      <ShowPing user={client} />
                    </Stack.Item>
                  )}
                </Stack>
              )
            }
            tooltipPosition={'bottom-start'}
            onClick={() => {
              if (!data.user.admin) {
                return;
              }
              setSubjectRef(client.mobRef);
              act('show_more_info', { ref: client.mobRef });
            }}
            onContextMenu={(e) => {
              if (!data.user.admin) {
                return;
              }
              e.preventDefault();
              act('follow', { ref: client.mobRef });
            }}
          >
            <Stack align="center">
              {client.accountAge < NEW_ACCOUNT_AGE && <Icon name="baby" />}
              <Stack.Item>{client.key}</Stack.Item>
              {sortType === 'Пинг' && (
                <Stack.Item>{Math.round(client.ping.avgPing)}ms</Stack.Item>
              )}
              {sortType === 'Возраст аккаунта' && (
                <Stack.Item>{numberToDays(client.accountAge)}</Stack.Item>
              )}
              {sortType === 'Версия BYOND' && (
                <Stack.Item>{client.byondVersion}</Stack.Item>
              )}
            </Stack>
          </Button>
        </Stack.Item>
      ))}
    </Stack>
  );
}
