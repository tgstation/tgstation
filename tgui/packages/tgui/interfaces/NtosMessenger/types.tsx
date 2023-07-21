import { BooleanLike } from 'common/react';

export type NtMessage = {
  message: string;
  outgoing: BooleanLike;
  photo_path?: string;
  everyone: BooleanLike;
};

export type NtPicture = {
  uid: number;
  path: string;
};

export type NtMessenger = {
  name: string;
  job: string;
  ref?: string;
};

export type NtChat = {
  ref: string;
  recp: NtMessenger;
  messages: NtMessage[];
  visible: BooleanLike;
  owner_deleted: BooleanLike;
  can_reply: BooleanLike;
  message_draft: string;
  unread_messages: number;
};
