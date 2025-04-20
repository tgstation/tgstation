import { sortBy } from 'common/collections';
import { useState } from 'react';
import {
  Box,
  Button,
  Dimmer,
  Divider,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { NtosWindow } from '../../layouts';
import { ChatScreen } from './ChatScreen';
import { NtChat, NtMessenger, NtPicture } from './types';

type NtosMessengerData = {
  can_spam: BooleanLike;
  is_silicon: BooleanLike;
  remote_silicon: BooleanLike;
  owner?: NtMessenger;
  saved_chats: Record<string, NtChat>;
  messengers: Record<string, NtMessenger>;
  sort_by_job: BooleanLike;
  alert_silenced: BooleanLike;
  alert_able: BooleanLike;
  sending_and_receiving: BooleanLike;
  open_chat: string;
  stored_photos?: NtPicture[];
  selected_photo_path?: string;
  on_spam_cooldown: BooleanLike;
  virus_attach: BooleanLike;
  sending_virus: BooleanLike;
};

export const NtosMessenger = (props) => {
  const { data } = useBackend<NtosMessengerData>();
  const {
    is_silicon,
    remote_silicon,
    saved_chats,
    stored_photos,
    selected_photo_path,
    open_chat,
    messengers,
    sending_virus,
  } = data;

  let content: React.JSX.Element;
  if (remote_silicon) {
    content = <AccessDeniedScreen />;
  } else if (open_chat !== null) {
    const openChat = saved_chats[open_chat];
    const temporaryRecipient = messengers[open_chat];

    if (!openChat && !temporaryRecipient) {
      content = <ContactsScreen />;
    } else {
      content = (
        <ChatScreen
          storedPhotos={stored_photos}
          selectedPhoto={selected_photo_path}
          isSilicon={is_silicon}
          sendingVirus={sending_virus}
          canReply={openChat ? openChat.can_reply : !!temporaryRecipient}
          messages={openChat ? openChat.messages : []}
          recipient={openChat ? openChat.recipient : temporaryRecipient}
          unreads={openChat ? openChat.unread_messages : 0}
          chatRef={openChat?.ref}
        />
      );
    }
  } else {
    content = <ContactsScreen />;
  }

  return (
    <NtosWindow width={600} height={850}>
      <NtosWindow.Content>{content}</NtosWindow.Content>
    </NtosWindow>
  );
};

const AccessDeniedScreen = (props: any) => {
  const { act, data } = useBackend<NtosMessengerData>();

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section>
          <Stack vertical textAlign="center">
            <Box bold>
              <Icon name="address-card" />
              SpaceMessenger V6.5.3
            </Box>
          </Stack>
        </Section>
      </Stack.Item>
      <NoticeBox
        color="white"
        position="relative"
        top="30%"
        fontSize="30px"
        textAlign="center"
      >
        ERROR: CONNECTION REFUSED
      </NoticeBox>
      <Stack vertical position="relative" top="35%" textAlign="left">
        <Section>
          <Box>Message from host:</Box>
          <Box>- Remote access of this application has been restricted.</Box>
          <Box>- Contact your Administrator for further assistance.</Box>
        </Section>
      </Stack>
    </Stack>
  );
};

const ContactsScreen = (props: any) => {
  const { act, data } = useBackend<NtosMessengerData>();
  const {
    owner,
    alert_silenced,
    alert_able,
    sending_and_receiving,
    saved_chats,
    messengers,
    sort_by_job,
    can_spam,
    is_silicon,
    virus_attach,
    sending_virus,
  } = data;

  const [searchUser, setSearchUser] = useState('');

  const sortByUnreads = (array: NtChat[]) =>
    sortBy(array, (chat) => chat.unread_messages);

  const searchChatByName = createSearch(
    searchUser,
    (chat: NtChat) => chat.recipient.name + chat.recipient.job,
  );
  const searchMessengerByName = createSearch(
    searchUser,
    (messenger: NtMessenger) => messenger.name + messenger.job,
  );

  const chatToButton = (chat: NtChat) => {
    return (
      <ChatButton
        key={chat.ref}
        name={`${chat.recipient.name} (${chat.recipient.job})`}
        chatRef={chat.ref}
        unreads={chat.unread_messages}
      />
    );
  };

  const messengerToButton = (messenger: NtMessenger) => {
    return (
      <ChatButton
        key={messenger.ref}
        name={`${messenger.name} (${messenger.job})`}
        chatRef={messenger.ref!}
        unreads={0}
      />
    );
  };

  const openChatsArray = sortByUnreads(Object.values(saved_chats)).filter(
    searchChatByName,
  );

  const filteredChatButtons = openChatsArray
    .filter((c) => c.visible)
    .map(chatToButton);

  const messengerButtons = Object.entries(messengers)
    .filter(
      ([ref, messenger]) =>
        openChatsArray.every((chat) => chat.recipient.ref !== ref) &&
        searchMessengerByName(messenger),
    )
    .map(([_, messenger]) => messenger)
    .map(messengerToButton)
    .concat(openChatsArray.filter((chat) => !chat.visible).map(chatToButton));

  const noId = !owner && !is_silicon;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section>
          <Stack vertical textAlign="center">
            <Box bold>
              <Icon name="address-card" mr={1} />
              SpaceMessenger V6.5.3
            </Box>
            <Box italic opacity={0.3} mt={1}>
              Bringing you spy-proof communications since 2467.
            </Box>
            <Divider hidden />
            <Box>
              <Button
                icon="bell"
                disabled={!alert_able}
                content={
                  alert_able && !alert_silenced ? 'Ringer: On' : 'Ringer: Off'
                }
                onClick={() => act('PDA_toggleAlerts')}
              />
              <Button
                icon="address-card"
                content={
                  sending_and_receiving
                    ? 'Send / Receive: On'
                    : 'Send / Receive: Off'
                }
                onClick={() => act('PDA_toggleSendingAndReceiving')}
              />
              <Button
                icon="bell"
                content="Set Ringtone"
                onClick={() => act('PDA_ringSet')}
              />
              <Button
                icon="sort"
                content={`Sort by: ${sort_by_job ? 'Job' : 'Name'}`}
                onClick={() => act('PDA_changeSortStyle')}
              />
              {!!virus_attach && (
                <Button
                  icon="bug"
                  color="bad"
                  content={`Attach Virus: ${sending_virus ? 'Yes' : 'No'}`}
                  onClick={() => act('PDA_toggleVirus')}
                />
              )}
            </Box>
          </Stack>
          <Divider hidden />
          <Stack justify="space-between">
            <Box m={0.5}>
              <Icon name="magnifying-glass" mr={1} />
              Search For User
            </Box>
            <Input
              width="220px"
              placeholder="Search by name or job..."
              value={searchUser}
              onChange={setSearchUser}
            />
          </Stack>
        </Section>
      </Stack.Item>
      {filteredChatButtons.length > 0 && (
        <Stack.Item grow={1}>
          <Stack vertical fill>
            <Section>
              <Icon name="comments" mr={1} />
              Previous Messages
            </Section>
            <Section fill scrollable>
              <Stack vertical>{filteredChatButtons}</Stack>
            </Section>
          </Stack>
        </Stack.Item>
      )}
      <Stack.Item grow={2}>
        <Stack vertical fill>
          <Section>
            <Stack>
              <Box m={0.5}>
                <Icon name="address-card" mr={1} />
                Detected Messengers
              </Box>
            </Stack>
          </Section>
          <Section fill scrollable>
            <Stack vertical pb={1} fill>
              {messengerButtons.length === 0 && (
                <Stack align="center" justify="center" fill pl={4}>
                  <Icon color="gray" name="user-slash" size={2} />
                  <Stack.Item fontSize={1.5} ml={3}>
                    No users found.
                  </Stack.Item>
                </Stack>
              )}
              {messengerButtons}
            </Stack>
          </Section>
        </Stack>
      </Stack.Item>
      {!!can_spam && (
        <Stack.Item>
          <SendToAllSection />
        </Stack.Item>
      )}
      {noId && <NoIDDimmer />}
    </Stack>
  );
};

type ChatButtonProps = {
  name: string;
  unreads: number;
  chatRef: string;
};

const ChatButton = (props: ChatButtonProps) => {
  const { act } = useBackend();
  const unreadMessages = props.unreads;
  const hasUnreads = unreadMessages > 0;
  return (
    <Button
      icon={hasUnreads && 'envelope'}
      key={props.chatRef}
      fluid
      onClick={() => {
        act('PDA_viewMessages', { ref: props.chatRef });
      }}
    >
      {hasUnreads &&
        `[${unreadMessages <= 9 ? unreadMessages : '9+'} unread message${
          unreadMessages !== 1 ? 's' : ''
        }]`}{' '}
      {props.name}
    </Button>
  );
};

const SendToAllSection = (props) => {
  const { data, act } = useBackend<NtosMessengerData>();
  const { on_spam_cooldown } = data;

  const [message, setMessage] = useState('');

  return (
    <>
      <Section>
        <Stack justify="space-between">
          <Stack.Item align="center">
            <Icon name="satellite-dish" mr={1} ml={0.5} />
            Send To All
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="arrow-right"
              disabled={on_spam_cooldown || message === ''}
              tooltip={on_spam_cooldown && 'Wait before sending more messages!'}
              onClick={() => {
                act('PDA_sendEveryone', { message: message });
                setMessage('');
              }}
            >
              Send
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
      <Section>
        <TextArea
          height={6}
          value={message}
          placeholder="Send message to everyone..."
          onChange={setMessage}
          selfClear
          onEnter={() => {
            act('PDA_sendEveryone', { message: message });
          }}
        />
      </Section>
    </>
  );
};

const NoIDDimmer = () => {
  return (
    <Dimmer>
      <Stack align="baseline" vertical>
        <Stack ml={-2}>
          <Icon color="red" name="address-card" size={10} />
        </Stack>
        <Stack.Item fontSize="18px">
          Please imprint an ID to continue.
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};
