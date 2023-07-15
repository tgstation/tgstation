import { BooleanLike } from 'common/react';

type NtMessage = {
  message: string;
  outgoing: BooleanLike;
  photo_path?: string;
  everyone: BooleanLike;
};

type NtMessenger = {
  name: string;
  job: string;
  ref?: string;
};

type NtChat = {
  ref: string;
  recp: NtMessenger;
  messages: NtMessage[];
  visible: BooleanLike;
  owner_deleted: BooleanLike;
  can_reply: BooleanLike;
  message_draft: string;
  unread_messages: number;
};

export { NtMessage, NtMessenger, NtChat };
