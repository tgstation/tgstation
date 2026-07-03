export const CONNECTED = 'CLIENT_CONNECTED';
export const DISCONNECTED = 'CLIENT_DISCONNECTED';
export const TICKET_LOG = 'ADMIN_TICKET_LOG';

export const TYPING_TIMEOUT = 5000;

export const USER_TYPES = ['Игрок', 'Ментор', 'Админ'];

export enum TICKET_STATE {
  Open = 0,
  Closed = 1,
  Resolved = 2,
}

export enum TICKET_MANAGER_TABS {
  OpenTickets = 0,
  ClosedTickets = 1,
}
