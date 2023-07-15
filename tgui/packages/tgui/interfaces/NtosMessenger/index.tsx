import { useBackend, useLocalState } from '../../backend';
import { createSearch } from 'common/string';
import { Box, Button, Icon, Section, Stack, Input, TextArea } from '../../components';
import { NtosWindow } from '../../layouts';
import { Component, createRef, RefObject } from 'inferno';
import { BooleanLike } from 'common/react';

import { NtChat, NtMessenger } from './types';
import { ChatMessage, NoIDDimmer } from './auxiliary';

type NtosMessengerData = {
  can_spam: BooleanLike;
  is_silicon: BooleanLike;
  owner: NtMessenger | null;
  saved_chats: Record<string, NtChat>;
  messengers: Record<string, NtMessenger>;
  sort_by_job: BooleanLike;
  alert_silenced: BooleanLike;
  sending_and_receiving: BooleanLike;
  open_chat: string;
  photo: string;
  on_spam_cooldown: BooleanLike;
  virus_attach: BooleanLike;
  sending_virus: BooleanLike;
};

export const NtosMessenger = (_props: any, context: any) => {
  const { act, data } = useBackend<NtosMessengerData>(context);
  const { saved_chats, open_chat, messengers } = data;

  let content: JSX.Element;
  if (open_chat !== null) {
    content = (
      <ChatScreen
        chat={saved_chats[open_chat]}
        temp_msgr={messengers[open_chat]}
        onReturn={() => act('PDA_viewMessages', { ref: null })}
      />
    );
  } else {
    content = <ContactsScreen />;
  }

  return (
    <NtosWindow width={600} height={800}>
      <NtosWindow.Content>{content}</NtosWindow.Content>
    </NtosWindow>
  );
};

const ContactsScreen = (_props: any, context: any) => {
  const { act, data } = useBackend<NtosMessengerData>(context);
  const {
    owner,
    alert_silenced,
    sending_and_receiving,
    saved_chats,
    messengers,
    sort_by_job,
    can_spam,
    is_silicon,
    photo,
    virus_attach,
    sending_virus,
  } = data;

  const filteredMessengers = Object.assign({}, messengers);
  const savedChatsArray = Object.values(saved_chats);
  savedChatsArray.forEach((chat) => {
    if (chat.recp.ref) delete filteredMessengers[chat.recp.ref];
  });
  const messengerArray = Object.values(filteredMessengers);
  savedChatsArray.sort((a, b) => a.unread_messages - b.unread_messages);

  const [searchUser, setSearchUser] = useLocalState<string>(
    context,
    'searchUser',
    ''
  );

  const search = createSearch(
    searchUser,
    (messengers: NtMessenger) => messengers.name + messengers.job
  );

  let users =
    searchUser.length > 0 ? messengerArray.filter(search) : messengerArray;

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
            <Box mt={2}>
              <Button
                icon="bell"
                content={alert_silenced ? 'Ringer: On' : 'Ringer: Off'}
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
              {!!is_silicon && (
                <Button
                  icon="camera"
                  content="Attach Photo"
                  onClick={() => act('PDA_selectPhoto')}
                />
              )}
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
        </Section>
      </Stack.Item>
      {!!photo && (
        <Stack vertical>
          <Section fill textAlign="center">
            <Icon name="camera" mr={1} />
            Current Photo
          </Section>
          <Section align="center" mb={1}>
            <Button onClick={() => act('PDA_clearPhoto')}>
              <Box mt={1} as="img" src={photo} />
            </Button>
          </Section>
        </Stack>
      )}
      {savedChatsArray.length > 0 && (
        <Stack.Item>
          <Stack fill vertical>
            <Stack vertical>
              <Section fill>
                <Icon name="comments" mr={1} />
                Previous Messages
              </Section>
            </Stack>
            <Section maxHeight={20} scrollable mt={1}>
              <Stack vertical>
                {savedChatsArray.map((chat) => {
                  const unread_msgs = chat.unread_messages;
                  const has_unreads = unread_msgs > 0;
                  return (
                    <Button
                      icon={has_unreads && 'envelope'}
                      key={chat.ref}
                      fluid
                      onClick={() => {
                        act('PDA_viewMessages', { ref: chat.ref });
                      }}>
                      {has_unreads &&
                        `[${unread_msgs} unread message${
                          unread_msgs !== 1 ? 's' : ''
                        }]`}{' '}
                      {chat.recp.name} ({chat.recp.job})
                    </Button>
                  );
                })}
              </Stack>
            </Section>
          </Stack>
        </Stack.Item>
      )}
      <Stack.Item grow>
        <Stack vertical fill>
          <Section>
            <Stack justify="space-between">
              <Box m={0.5}>
                <Icon name="address-card" mr={1} />
                Detected Messengers
              </Box>

              <Input
                width="220px"
                placeholder="Search by name or job..."
                value={searchUser}
                onInput={(_e: any, value: string) => setSearchUser(value)}
              />
            </Stack>
          </Section>
          <Section fill scrollable>
            <Stack vertical pb={1}>
              {users.length === 0 && 'No users found'}
              {users.map((messenger) => (
                <Button
                  key={messenger.ref}
                  fluid
                  onClick={() => {
                    act('PDA_viewMessages', { ref: messenger.ref });
                  }}>
                  {messenger.name} ({messenger.job})
                </Button>
              ))}
            </Stack>
          </Section>
        </Stack>
      </Stack.Item>
      <Stack.Item>{!!can_spam && <SendToAllModal />}</Stack.Item>
      {noId && <NoIDDimmer />}
    </Stack>
  );
};

type ChatScreenProps = {
  onReturn: () => void;
  // if one doesn't exist, assume the other one does
  chat?: NtChat;
  temp_msgr?: NtMessenger;
};

type ChatScreenState = {
  msg: string;
  canSend: BooleanLike;
};

class ChatScreen extends Component<ChatScreenProps, ChatScreenState> {
  scrollRef: RefObject<HTMLDivElement>;

  state: ChatScreenState = {
    msg: '',
    canSend: true,
  };

  constructor(props: ChatScreenProps) {
    super(props);

    this.scrollRef = createRef();

    this.scrollToBottom = this.scrollToBottom.bind(this);
    this.handleMessageInput = this.handleMessageInput.bind(this);
    this.handleSendMessage = this.handleSendMessage.bind(this);
  }

  componentDidMount() {
    this.scrollToBottom();
  }

  componentDidUpdate(
    prevProps: ChatScreenProps,
    _prevState: ChatScreenState,
    _snapshot: any
  ) {
    if (prevProps.chat?.messages.length !== this.props.chat?.messages.length) {
      this.scrollToBottom();
    }
  }

  componentWillUnmount() {
    const { act } = useBackend(this.context);

    const chat = this.props.chat;
    if (!chat) return;

    act('PDA_saveMessageDraft', {
      ref: chat.ref,
      msg: this.state.msg,
    });
  }

  scrollToBottom() {
    const scroll = this.scrollRef.current;
    if (scroll !== null) {
      scroll.scrollTop = scroll.scrollHeight;
    }
  }

  handleSendMessage() {
    if (this.state.msg === '') return;
    const { act } = useBackend<NtosMessengerData>(this.context);

    let ref = this.props.chat
      ? this.props.chat.ref
      : this.props.temp_msgr!.ref!;

    act('PDA_sendMessage', {
      ref: ref,
      msg: this.state.msg,
    });

    this.setState({ msg: '', canSend: false });
    setTimeout(() => this.setState({ canSend: true }), 1000);
  }

  handleMessageInput(_: any, val: string) {
    this.setState({ msg: val });
  }

  render() {
    const { act } = useBackend<NtosMessengerData>(this.context);
    const { onReturn, chat, temp_msgr } = this.props;
    const { msg, canSend } = this.state;

    // one or the other has to exist
    const recp = chat ? chat.recp : temp_msgr!;
    const msgs = chat ? chat.messages : [];

    let lastOutgoing: boolean = false;
    let filteredMessages: JSX.Element[] = [];

    for (let index = 0; index < msgs.length; index++) {
      let message = msgs[index];

      const isSwitch = lastOutgoing !== message.outgoing;
      lastOutgoing = !!message.outgoing;

      filteredMessages.push(
        <Stack.Item key={index} mt={isSwitch ? 2 : 0.5}>
          <ChatMessage
            outgoing={message.outgoing}
            msg={message.message}
            everyone={message.everyone}
            photoPath={message.photo_path}
          />
        </Stack.Item>
      );
    }

    return (
      <Stack vertical fill>
        <Section>
          <Button icon="arrow-left" content="Back" onClick={onReturn} />
          {chat && (
            <>
              <Button
                icon="box-archive"
                content="Close chat"
                onClick={() => act('PDA_closeMessages', { ref: chat.ref })}
              />
              <Button.Confirm
                icon="trash-can"
                content="Delete chat"
                onClick={() => act('PDA_clearMessages', { ref: chat.ref })}
              />
            </>
          )}
          <Button.Confirm
            icon="user-xmark"
            content="Block user"
            onClick={() =>
              act('PDA_blockMessenger', {
                ref: chat?.recp.ref ?? temp_msgr!.ref,
              })
            }
          />
        </Section>

        <Stack.Item grow={1}>
          <Section
            scrollable
            fill
            fitted
            title={`${recp.name} (${recp.job})`}
            scrollableRef={this.scrollRef}>
            <Stack vertical fill className="NtosMessenger__ChatLog">
              <Stack.Item textAlign="center" fontSize={1}>
                This is the beginning of your chat with {recp.name}.
              </Stack.Item>
              <Stack.Divider />
              {filteredMessages}
            </Stack>
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section fill>
            <Stack fill>
              <Input
                placeholder={`Send message to ${recp.name}...`}
                fluid
                autofocus
                width="100%"
                justify
                id="input"
                value={msg}
                maxLength={1024}
                onInput={this.handleMessageInput}
                onEnter={this.handleSendMessage}
              />
              <Button
                icon="arrow-right"
                onClick={this.handleSendMessage}
                disabled={!canSend}
              />
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    );
  }
}

const SendToAllModal = (_: any, context: any) => {
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
              tooltip={
                on_spam_cooldown
                  ? 'Wait before sending more messages!'
                  : undefined
              }
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
          height={5}
          value={msg}
          placeholder="Send message to everyone..."
          onInput={(_: any, v: string) => setMsg(v)}
        />
      </Section>
    </>
  );
};
