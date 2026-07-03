import {
  type Dispatch,
  type SetStateAction,
  useEffect,
  useRef,
  useState,
} from 'react';
import { Button, Section, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { ChatInput } from '../common/ChatInput';
import { TICKET_STATE, TYPING_TIMEOUT } from './constants';
import { TicketAdminInteractions, TicketInteractions } from './Ticket';
import { TicketMessage } from './TicketMessage';
import { TicketPanelEmbed } from './TicketPanelEmbed';
import { TicketPanelEmoji } from './TicketPanelEmoji';
import type { ManagerData, TicketProps } from './types';

type TicketPanelProps = {
  selectedTicket: TicketProps;
  setSelectedTicketId: Dispatch<SetStateAction<number | null>>;
};

export function TicketPanel(props: TicketPanelProps) {
  const { act, data } = useBackend<ManagerData>();
  const { userKey, isAdmin, maxMessageLength, replyCooldown } = data;
  const { selectedTicket, setSelectedTicketId } = props;

  const {
    number,
    messages,
    state,
    type,
    linkedAdmin,
    writers,
    userHasStaffAccess,
  } = selectedTicket;

  const ticketOpen = state === TICKET_STATE.Open;

  const [inputMessage, setInputMessage] = useState('');
  const [showScrollButton, setShowScrollButton] = useState(false);

  const sectionRef = useRef<HTMLDivElement>(null);
  const shouldScrollRef = useRef(true);
  const firstRender = useRef(true);

  const typingTimeoutRef = useRef<NodeJS.Timeout>(null);
  const isWritingRef = useRef(false);

  function handleTyping() {
    if (!isWritingRef.current) {
      act('start_writing', { ticketId: number });
      isWritingRef.current = true;
    }

    if (typingTimeoutRef.current) {
      clearTimeout(typingTimeoutRef.current);
    }

    typingTimeoutRef.current = setTimeout(() => {
      act('stop_writing', { ticketId: number });
      isWritingRef.current = false;
    }, TYPING_TIMEOUT);
  }

  function handleEnter(value: string) {
    if (isWritingRef.current) {
      isWritingRef.current = false;
    }

    if (typingTimeoutRef.current) {
      clearTimeout(typingTimeoutRef.current);
    }

    act('reply', { ticketId: number, message: value });
    setInputMessage('');
  }

  function scrollToBottom(ignoreBottom?: boolean, nonSmooth?: boolean) {
    const section = sectionRef.current;
    if (!section) {
      return;
    }

    if (shouldScrollRef.current || ignoreBottom) {
      section.scrollTo({
        top: section.scrollHeight,
        behavior: nonSmooth ? 'auto' : 'smooth',
      });
    }
  }

  useEffect(() => {
    const section = sectionRef.current;
    if (!section) {
      return;
    }

    const handleScroll = () => {
      const isBottom =
        section.scrollHeight - section.scrollTop - section.offsetHeight <= 200;
      shouldScrollRef.current = isBottom;
      setShowScrollButton((prev) => (prev !== !isBottom ? !isBottom : prev));
    };

    section.addEventListener('scroll', handleScroll);
    return () => {
      section.removeEventListener('scroll', handleScroll);
    };
  });

  useEffect(() => {
    const nonSmooth = firstRender.current;
    firstRender.current = false;

    scrollToBottom(false, nonSmooth);
  }, [messages]);

  return (
    <Stack
      fill
      vertical
      g={0}
      className={classes(['TicketPanel', `Ticket--${type}`])}
    >
      <Stack.Item>
        <TicketTitle
          isAdmin={!!isAdmin}
          hasStaffAccess={!!userHasStaffAccess}
          selectedTicket={selectedTicket}
          setSelectedTicketId={setSelectedTicketId}
        />
      </Stack.Item>
      {!!isAdmin && <Stack.Divider />}
      <Stack.Item grow position="relative">
        <Stack.Item
          className={classes([
            'TicketPanel__ScrollButton',
            showScrollButton && 'TicketPanel__ScrollButton--active',
          ])}
        >
          <Button icon="arrow-down" onClick={() => scrollToBottom(true)}>
            К последним сообщениям
          </Button>
        </Stack.Item>
        <Section ref={sectionRef} fill scrollable>
          <Stack vertical>
            {messages.map((message) => (
              <TicketMessage
                key={message.time}
                messageHolder={message}
                hasStaffAccess={!!userHasStaffAccess}
              />
            ))}
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item style={{ zIndex: 1 }}>
        <Section>
          <TypingIndicator writers={writers} userKey={userKey} />
          <ChatInput
            value={inputMessage}
            placeholder={ticketOpen ? 'Введите сообщение...' : 'Тикет закрыт!'}
            maxLength={maxMessageLength}
            cooldown={!userHasStaffAccess && replyCooldown}
            disabled={!ticketOpen || (!userHasStaffAccess && !linkedAdmin)}
            onChange={(value) => {
              setInputMessage(value);
              handleTyping();
            }}
            onEnter={handleEnter}
            buttons={
              <>
                <TicketPanelEmbed
                  insertEmbed={(embed) => {
                    setInputMessage((prev) => prev + embed);
                  }}
                />
                <TicketPanelEmoji
                  insertEmoji={(emoji) => {
                    setInputMessage((prev) => prev + emoji);
                  }}
                />
              </>
            }
          />
        </Section>
      </Stack.Item>
    </Stack>
  );
}

type TitcketTitleProps = {
  isAdmin: boolean;
  hasStaffAccess: boolean;
  selectedTicket: TicketProps;
  setSelectedTicketId: Dispatch<SetStateAction<number | null>>;
};

function TicketTitle(props: TitcketTitleProps) {
  const { isAdmin, hasStaffAccess, selectedTicket, setSelectedTicketId } =
    props;
  const { number, initiator, state, isLinkedToCurrentAdmin } = selectedTicket;
  return (
    <Section
      fitted={!isAdmin}
      title={
        <Stack fill align="center">
          <Stack.Item fontSize={1}>
            <Button
              icon="arrow-left"
              onClick={() => setSelectedTicketId(null)}
            />
          </Stack.Item>
          <Stack.Item grow className="TicketPanel__Title">
            Тикет #{number} - {initiator}
          </Stack.Item>
          {hasStaffAccess && (
            <Stack.Item>
              <TicketInteractions
                isLinkedToCurrentAdmin={!!isLinkedToCurrentAdmin}
                ticketId={number}
                ticketState={state}
              />
            </Stack.Item>
          )}
        </Stack>
      }
    >
      {isAdmin && <TicketAdminInteractions ticketId={number} />}
    </Section>
  );
}

function TypingIndicator(props) {
  const { writers, userKey } = props;
  const others = writers.filter((writer) => writer !== userKey);

  let writersText: string = '';
  if (others.length === 1) {
    writersText = `${others[0]} печатает...`;
  }

  if (others.length === 2) {
    writersText = `${others[0]} и ${others[1]} печатают...`;
  }

  if (others.length > 2) {
    writersText = 'Несколько человек печатают...';
  }

  return (
    others.length > 0 && (
      <Stack className="TicketPanel__Writers">
        <Stack className="TicketPanel__Writers--indicator" g={0.5}>
          <div />
          <div />
          <div />
        </Stack>
        <Stack.Item grow> {writersText} </Stack.Item>
      </Stack>
    )
  );
}
