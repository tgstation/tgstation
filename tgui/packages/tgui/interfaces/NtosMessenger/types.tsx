import { BooleanLike } from 'common/react';

type NtMessage = {
  contents: string;
  outgoing: BooleanLike;
  photo_path: string;
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
};

type NtMessengers = Record<string, NtMessenger>;

export { NtMessage, NtMessenger, NtMessengers, NtChat };
