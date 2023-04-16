import { BooleanLike } from 'common/react';

export type RequestsData = {
  can_send_announcements: string;
  department: string;
  emergency: string;
  hack_state: BooleanLike;
  messages: RequestMessage[];
  new_message_priority: number;
  silent: BooleanLike;
  assistance_consoles: string[];
  supply_consoles: string[];
  information_consoles: string[];
};

export type RequestMessage = {
  content: string;
};
