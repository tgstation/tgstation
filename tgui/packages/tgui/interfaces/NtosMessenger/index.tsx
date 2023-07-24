import { Box, Button, Icon, Section, Stack, Input, TextArea, Dimmer, Divider } from '../../components';
import { useBackend, useLocalState } from '../../backend';
import { createSearch } from 'common/string';
import { BooleanLike } from 'common/react';
import { NtosWindow } from '../../layouts';
import { SFC } from 'inferno';

import { NtChat, NtMessenger, NtPicture } from './types';
import { ChatScreen } from './ChatScreen';

type NtosMessengerData = {
  can_spam: BooleanLike;
  is_silicon: BooleanLike;
  owner: NtMessenger | null;
  saved_chats: Record<string, NtChat>;
  messengers: Record<string, NtMessenger>;
  sort_by_job: BooleanLike;
  alert_silenced: BooleanLike;
  alert_able: BooleanLike;
  sending_and_receiving: BooleanLike;
  open_chat: string;
  stored_photos?: NtPicture[];
  selected_photo_path: string | null;
  on_spam_cooldown: BooleanLike;
  virus_attach: BooleanLike;
  sending_virus: BooleanLike;
};

export const NtosMessenger = (_props: any, context: any) => {
  const { act, data } = useBackend<NtosMessengerData>(context);
  const {
    is_silicon,
    saved_chats,
    stored_photos,
    selected_photo_path,
    open_chat,
    messengers,
  } = data;

  let content: JSX.Element;
  if (open_chat !== null) {
    content = (
      <ChatScreen
        chat={saved_chats[open_chat]}
        temp_msgr={messengers[open_chat]}
        storedPhotos={stored_photos}
        selectedPhoto={selected_photo_path}
        onReturn={() => act('PDA_viewMessages', { ref: null })}
        isSilicon={is_silicon}
      />
    );
  } else {
    content = <ContactsScreen />;
  }

  return (
    <NtosWindow width={600} height={850}>
      <NtosWindow.Content>{content}</NtosWindow.Content>
    </NtosWindow>
  );
};

const ContactsScreen = (_props: any, context: any) => {
  const { act, data } = useBackend<NtosMessengerData>(context);
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

  // you are not ready for this garbage o7

  const [searchUser, setSearchUser] = useLocalState<string>(
    context,
    'searchUser',
    ''
  );

  let savedChatsArray = Object.values(saved_chats);
  savedChatsArray.sort((a, b) => b.unread_messages - a.unread_messages);

  if (searchUser.length > 0) {
    const chatSearch = createSearch(
      searchUser,
      (chat: NtChat) => chat.recp.name + chat.recp.job
    );

    savedChatsArray = savedChatsArray.filter(chatSearch);
  }

  const chatToButton = (chat) => {
    return (
      <ChatButton
        key={chat.ref}
        name={`${chat.recp.name} (${chat.recp.job})`}
        chatRef={chat.ref}
        unreads={chat.unread_messages}
      />
    );
  };

  const filteredChatButtons = savedChatsArray
    .filter((c) => c.visible)
    .map(chatToButton);

  const chatButtons = savedChatsArray.map(chatToButton);

  let messengerButtons = [...chatButtons];
  const filteredMessengers = Object.assign({}, messengers);

  savedChatsArray.forEach((chat) => {
    if (chat.recp.ref) delete filteredMessengers[chat.recp.ref];
  });

  let filteredMessengerArray = Object.values(filteredMessengers);

  if (searchUser.length > 0) {
    const msgrSearch = createSearch(
      searchUser,
      (messengers: NtMessenger) => messengers.name + messengers.job
    );

    filteredMessengerArray = filteredMessengerArray.filter(msgrSearch);
  }

  messengerButtons = messengerButtons.concat(
    filteredMessengerArray.map((msgr) => {
      // assume that the msgr has a ref if they are in GLOB.TabletMessengers
      return (
        <ChatButton
          key={msgr.ref}
          name={`${msgr.name} (${msgr.job})`}
          chatRef={msgr.ref!}
          unreads={0}
        />
      );
    })
  );

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
                onClick={() => act('PDA_sAndR')}
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
              onInput={(_e: any, value: string) => setSearchUser(value)}
            />
          </Stack>
        </Section>
      </Stack.Item>
      {filteredChatButtons.length > 0 && (
        <Stack.Item>
          <Stack fill vertical>
            <Stack vertical>
              <Section fill>
                <Icon name="comments" mr={1} />
                Previous Messages
              </Section>
            </Stack>
            <Section maxHeight={20} scrollable mt={1}>
              <Stack vertical>{filteredChatButtons}</Stack>
            </Section>
          </Stack>
        </Stack.Item>
      )}
      <Stack.Item grow>
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
            <Stack vertical pb={1}>
              {messengerButtons.length === 0 && 'No users found'}
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

const ChatButton: SFC<ChatButtonProps> = (props: ChatButtonProps, ctx: any) => {
  const { act } = useBackend(ctx);
  const unread_msgs = props.unreads;
  const has_unreads = unread_msgs > 0;
  return (
    <Button
      icon={has_unreads && 'envelope'}
      key={props.chatRef}
      fluid
      onClick={() => {
        act('PDA_viewMessages', { ref: props.chatRef });
      }}>
      {has_unreads &&
        `[${unread_msgs <= 9 ? unread_msgs : '9+'} unread message${
          unread_msgs !== 1 ? 's' : ''
        }]`}{' '}
      {props.name}
    </Button>
  );
};

const SendToAllSection = (_: any, context: any) => {
  const { data, act } = useBackend<NtosMessengerData>(context);
  const { on_spam_cooldown } = data;

  const [msg, setMsg] = useLocalState(context, 'everyoneMessage', '');

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
              disabled={on_spam_cooldown || msg === ''}
              tooltip={on_spam_cooldown && 'Wait before sending more messages!'}
              tooltipPosition="auto-start"
              onClick={() => {
                act('PDA_sendEveryone', { msg: msg });
                setMsg('');
              }}>
              Send
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
      <Section>
        <TextArea
          height={6}
          value={msg}
          placeholder="Send message to everyone..."
          onInput={(_: any, v: string) => setMsg(v)}
        />
      </Section>
    </>
  );
};

export const NoIDDimmer: SFC = () => {
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
