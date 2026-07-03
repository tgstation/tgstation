import type { Dispatch } from 'react';
import type { BooleanLike } from 'tgui-core/react';

export type ManagerData = {
  emojis: Record<string, null>; // That's FUCKING CURSED SHIT
  userKey: string;
  ticketToOpen: number;
  maxMessageLength: number;
  replyCooldown: number;
  isAdmin: BooleanLike;
  userType: number;
  allTickets: TicketProps[];
};

export type TicketProps = {
  number: number;
  state: number;
  initiator: string;
  type: string;
  openedTime: string;
  closedTime: string;
  linkedAdmin: string;
  writers: string[];
  messages: MessageProps[];
  userHasStaffAccess: BooleanLike;
  isLinkedToCurrentAdmin: BooleanLike;
};

export type MessageProps = {
  sender: string;
  message: string;
  time: string;
};

export type TicketsMainPageProps = {
  allTickets: TicketProps[];
  setSelectedTicketId: Dispatch<number>;
};
