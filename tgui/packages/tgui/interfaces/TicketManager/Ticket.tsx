import type { Dispatch, SetStateAction } from 'react';
import { Button, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { useBackend } from '../../backend';
import { TICKET_STATE } from './constants';
import { toLocalTime } from './helpers';
import type { TicketProps } from './types';

export function Ticket(
  props: TicketProps & {
    setSelectedTicketId: Dispatch<SetStateAction<number | null>>;
  },
) {
  const {
    number,
    type,
    initiator,
    openedTime,
    closedTime,
    messages,
    setSelectedTicketId,
  } = props;

  return (
    <Stack
      g={0.5}
      vertical
      className={classes(['Ticket', type && `Ticket--${type}`])}
      onClick={() => setSelectedTicketId(number)}
    >
      <Stack fill className="Ticket__Header">
        <Stack.Item className="Ticket__Id">#{number}</Stack.Item>
        <Stack.Item grow className="Ticket__Initiator">
          {initiator}
        </Stack.Item>
        <Stack.Item className="Ticket__TimeStamp">
          {toLocalTime(openedTime)}
          {closedTime && ` - ${toLocalTime(closedTime)}`}
        </Stack.Item>
      </Stack>
      <Stack.Item className="Ticket__FirstMessage">
        {messages[0].message}
      </Stack.Item>
    </Stack>
  );
}

type TicketInteractionsProps = {
  isLinkedToCurrentAdmin: boolean;
  ticketId: number;
  ticketState: TICKET_STATE;
};

export function TicketInteractions(props: TicketInteractionsProps) {
  const { act } = useBackend();
  const { isLinkedToCurrentAdmin, ticketId, ticketState } = props;

  return (
    <Stack fontSize={1}>
      {ticketState !== TICKET_STATE.Open ? (
        <Stack.Item>
          <Button
            icon="eye"
            tooltip="Открыть закрытый/решённый ранее тикет"
            onClick={() => act('reopen', { ticketId: ticketId })}
          />
        </Stack.Item>
      ) : (
        <>
          <Stack.Item>
            <Button
              icon="check"
              color="good"
              tooltip="Пометить тикет как решённый"
              onClick={() => act('resolve', { ticketId: ticketId })}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="trash-can"
              color="bad"
              tooltip="Закрыть тикет"
              onClick={() => act('close', { ticketId: ticketId })}
            />
          </Stack.Item>
          {isLinkedToCurrentAdmin && (
            <Stack.Item>
              <Button.Confirm
                icon="link-slash"
                color="gray"
                tooltip="Отказаться от тикета"
                onClick={() => act('unlink', { ticketId: ticketId })}
              />
            </Stack.Item>
          )}
          <Stack.Item>
            <Button
              icon="exchange"
              tooltip="Изменить тип тикета"
              onClick={() => {
                act('convert', { ticketId: ticketId });
              }}
            />
          </Stack.Item>
        </>
      )}
    </Stack>
  );
}

export function TicketAdminInteractions(props: { ticketId: number }) {
  const { act } = useBackend();
  const { ticketId } = props;

  return (
    <Stack fill wrap textAlign="center">
      <Stack.Item grow>
        <Button
          fluid
          onClick={() => act('view_variables', { ticketId: ticketId })}
        >
          View Variables
        </Button>
      </Stack.Item>
      <Stack.Item grow>
        <Button
          fluid
          onClick={() => act('traitor_panel', { ticketId: ticketId })}
        >
          Traitor Panel
        </Button>
      </Stack.Item>
      <Stack.Item grow>
        <Button
          fluid
          onClick={() => act('player_panel', { ticketId: ticketId })}
        >
          Player Panel
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button
          color="pink"
          icon="exclamation"
          tooltip="Вывести вообщение на экран владельца тикета"
          onClick={() => act('popup', { ticketId: ticketId })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          color="purple"
          icon="phone"
          tooltip="Голос в голове"
          onClick={() => act('subtlepm', { ticketId: ticketId })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          color="red"
          icon="hand-fist"
          tooltip="Наказать"
          onClick={() => act('smite', { ticketId: ticketId })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          color="blue"
          icon="scroll"
          tooltip="Логи"
          onClick={() => act('logs', { ticketId: ticketId })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          color="grey"
          icon="ghost"
          tooltip="Наблюдать"
          onClick={() => act('follow', { ticketId: ticketId })}
        />
      </Stack.Item>
    </Stack>
  );
}
