import { useLocalStorage } from '@uidotdev/usehooks';
import { useState } from 'react';
import { Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { TICKET_MANAGER_TABS, TICKET_STATE, USER_TYPES } from './constants';
import { Ticket } from './Ticket';
import { TicketPanel } from './TicketPanel';
import type { ManagerData, TicketProps, TicketsMainPageProps } from './types';

export function TicketManager() {
  const { data } = useBackend<ManagerData>();
  const { allTickets, ticketToOpen, userType } = data;
  const [selectedTicketId, setSelectedTicketId] = useState<number | null>(
    ticketToOpen,
  );

  const selectedTicket = allTickets.find(
    (ticket: TicketProps) => ticket.number === selectedTicketId,
  );
  const userTypeName = USER_TYPES[userType] || 'Неизвестный тип пользователя';

  return (
    <Window
      title={`Менеджер тикетов - ${userTypeName}`}
      theme="ss220"
      width={550}
      height={750}
    >
      <Window.Content>
        {selectedTicket ? (
          <TicketPanel
            selectedTicket={selectedTicket}
            setSelectedTicketId={setSelectedTicketId}
          />
        ) : (
          <TicketsMainPage
            allTickets={allTickets}
            setSelectedTicketId={setSelectedTicketId}
          />
        )}
      </Window.Content>
    </Window>
  );
}

function TicketsMainPage(props: TicketsMainPageProps) {
  const { allTickets, setSelectedTicketId } = props;
  const [selectedTab, setSelectedTab] = useLocalStorage(
    'ticketManagerTab',
    TICKET_MANAGER_TABS.OpenTickets,
  );

  const selectedTickets = allTickets.filter((ticket: TicketProps) =>
    selectedTab === TICKET_MANAGER_TABS.OpenTickets
      ? ticket.state === TICKET_STATE.Open
      : ticket.state !== TICKET_STATE.Open,
  );

  const openTicketsAmount =
    selectedTab === TICKET_MANAGER_TABS.OpenTickets
      ? selectedTickets.length
      : allTickets.length - selectedTickets.length;

  const closedTicketsAmount =
    selectedTab === TICKET_MANAGER_TABS.ClosedTickets
      ? selectedTickets.length
      : allTickets.length - selectedTickets.length;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Tabs fluid textAlign="center">
          <Tabs.Tab
            icon="envelope-open-text"
            color="average"
            selected={selectedTab === TICKET_MANAGER_TABS.OpenTickets}
            onClick={() => setSelectedTab(TICKET_MANAGER_TABS.OpenTickets)}
          >
            Открытые ({openTicketsAmount})
          </Tabs.Tab>
          <Tabs.Tab
            icon="trash-can"
            color="good"
            selected={selectedTab === TICKET_MANAGER_TABS.ClosedTickets}
            onClick={() => setSelectedTab(TICKET_MANAGER_TABS.ClosedTickets)}
          >
            Закрытые ({closedTicketsAmount})
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          <Stack vertical reverse>
            {selectedTickets.map((ticket: TicketProps) => (
              <Ticket
                key={ticket.number}
                setSelectedTicketId={setSelectedTicketId}
                {...ticket}
              />
            ))}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
}
