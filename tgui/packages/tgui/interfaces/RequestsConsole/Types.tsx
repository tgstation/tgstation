import { BooleanLike } from 'common/react';

export type RequestsData = {
  can_send_announcements: string;
  department: string;
  emergency: string;
  hack_state: BooleanLike;
  messages: RequestMessage[];
  new_message_priority: RequestPriority;
  silent: BooleanLike;
  assistance_consoles: string[];
  supply_consoles: string[];
  information_consoles: string[];
};

export type RequestMessage = {
  content: string;
};

export enum RequestType {
  NONE = '',
  ASSISTANCE = 'assistance',
  SUPPLIES = 'supplies',
  INFORMATION = 'information',
}

export enum RequestPriority {
  NORMAL = 1,
  HIGH = 2,
  EXTREME = 3,
}

export enum RequestTabs {
  MESSAGE_VIEW = 1,
  MESSAGE_WRITE = 2,
  ANNOUNCE = 3,
}
