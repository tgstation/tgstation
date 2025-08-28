import type { BooleanLike } from 'tgui-core/react';

export type RequestsData = {
  authentication_data: AuthenticationData;
  can_send_announcements: string;
  department: string;
  emergency: string;
  hack_state: BooleanLike;
  has_mail_send_error: BooleanLike;
  is_admin_ghost_ai: BooleanLike;
  messages: RequestMessage[];
  new_message_priority: RequestPriority;
  silent: BooleanLike;
  assistance_consoles: string[];
  supply_consoles: string[];
  information_consoles: string[];
};

export type AuthenticationData = {
  message_verified_by: string[];
  message_stamped_by: string[];
  announcement_authenticated: string[];
};

export type RequestMessage = {
  content: string;
  message_stamped_by: string;
  message_verified_by: string;
  priority: RequestPriority;
  received_time: string;
  request_type: RequestType;
  sender_department: string;
  appended_list: string[];
};

export enum RequestType {
  NONE = '',
  ASSISTANCE = 'Assistance Request',
  SUPPLIES = 'Supplies Request',
  INFORMATION = 'Relay Information',
  ORE_UPDATE = 'Ore Update',
  REPLY = 'Reply',
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
