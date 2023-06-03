import { useBackend, useLocalState } from '../backend';
import { createSearch } from 'common/string';
import {
  Box,
  Button,
  Dimmer,
  Icon,
  Section,
  Stack,
  Input,
  TextArea,
} from '../components';
import { NtosWindow } from '../layouts';
import { Component, createRef, InfernoNode, RefObject } from 'inferno';
import { sanitizeText } from '../sanitize';

type NtMessage = {
  name: string;
  job: string;
  contents: string;
  outgoing: boolean;
  sender: string;
  automated: boolean;
  photo_path: string;
  photo: string;
  everyone: boolean;
  targets: string[];
  target_details: string[];
};

type NtMessenger = {
  name: string;
  job: string;
  ref: string;
};

type NtMessengers = Record<string, NtMessenger>;

type NtosMessengerData = {
  owner: string;
  sort_by_job: boolean;
  is_silicon: boolean;
  ringer_status: boolean;
  can_spam: boolean;
  virus_attach: boolean;
  sending_virus: boolean;
  sending_and_receiving: boolean;
  viewing_messages_of: NtMessenger;
  photo: string;
  messages: NtMessage[];
  messengers: NtMessengers;
};

type CurrentChat = NtMessenger | null;

const NoIDDimmer = () => {
  return (
    <Stack>
      <Stack.Item>
        <Dimmer>
          <Stack align="baseline" vertical>
            <Stack.Item>
              <Stack ml={-2}>
                <Stack.Item>
                  <Icon color="red" name="address-card" size={10} />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item fontSize="18px">
              Please imprint an ID to continue.
            </Stack.Item>
          </Stack>
        </Dimmer>
      </Stack.Item>
    </Stack>
  );
};

export const NtosMessenger = (props: any, context: any) => {
  const { act, data } = useBackend<NtosMessengerData>(context);
  const { messages, viewing_messages_of } = data;

  let content: JSX.Element;
  if (viewing_messages_of !== null) {
    let filteredMsgs = messages.filter((msg) =>
      msg.outgoing
        ? msg.targets.includes(viewing_messages_of.ref)
        : viewing_messages_of.ref === msg.sender
    );
    content = (
      <ChatScreen
        msgs={filteredMsgs}
        recp={viewing_messages_of}
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

const ContactsScreen = (props: any, context: any) => {
  const { act, data } = useBackend<NtosMessengerData>(context);
  const {
    owner,
    ringer_status,
    sending_and_receiving,
    messengers,
    sort_by_job,
    can_spam,
    is_silicon,
    photo,
    virus_attach,
    sending_virus,
  } = data;

  const messengerArray = Object.entries(messengers).map(([k, v]) => {
    v.ref = k;
    return v;
  });

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
      <Section>
        <Stack vertical textAlign="center">
          <Box bold>
            <Icon name="address-card" mr={1} />
            SpaceMessenger V6.5.1
          </Box>
          <Box italic opacity={0.3} mt={1}>
            Bringing you spy-proof communications since 2467.
          </Box>
          <Box mt={2}>
            <Button
              icon="bell"
              content={ringer_status ? 'Ringer: On' : 'Ringer: Off'}
              onClick={() => act('PDA_ringer_status')}
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
      <Stack vertical>
        <Section fill textAlign="center">
          <Icon name="address-card" mr={1} />
          Detected Messengers
          <Input
            width="220px"
            placeholder="Search by name or job..."
            value={searchUser}
            onInput={(e: any, value: string) => setSearchUser(value)}
            mx={1}
            ml={27}
          />
        </Section>
      </Stack>
      <Stack vertical fill mt={1}>
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
        {!!can_spam && <SendToAllModal />}
      </Stack>
      {noId && <NoIDDimmer />}
    </Stack>
  );
};

type ChatMessageProps = {
  sender: string | null;
  msg: string;
  everyone?: boolean;
  photo_path?: string;
};

const ChatMessage = (props: ChatMessageProps) => {
  const { msg, everyone, sender, photo_path } = props;
  const text = {
    __html: sanitizeText(msg),
  };
  return (
    <Box
      pr={1}
      pl={1}
      pt={1}
      backgroundColor="#151515"
      maxWidth={30}
      style={{
        border: '1px solid #202020',
        'border-radius': '3px',
        display: 'inline-flex',
      }}>
      <Section title={sender} textAlign="left" minWidth={10}>
        <Box
          style={{ 'word-wrap': 'break-word' }}
          dangerouslySetInnerHTML={text}
        />
        {photo_path !== null && <Box mt={1} mr={3} as="img" src={photo_path} />}
        {everyone && (
          <Box textColor="grey" fontSize="0.7em" mt={1}>
            Sent to everyone
          </Box>
        )}
      </Section>
    </Box>
  );
};

type ChatScreenProps = {
  onReturn: () => void;
  recp: NtMessenger;
  msgs: NtMessage[];
};

type ChatScreenState = {
  msg: string;
  canSend: boolean;
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

  componentDidMount(): void {
    this.scrollToBottom();
  }

  componentDidUpdate(
    prevProps: ChatScreenProps,
    prevState: ChatScreenState,
    snapshot: any
  ): void {
    if (prevProps.msgs.length !== this.props.msgs.length) {
      this.scrollToBottom();
    }
  }

  scrollToBottom(): void {
    const scroll = this.scrollRef.current;
    if (scroll !== null) {
      scroll.scrollTop = scroll.scrollHeight;
    }
  }

  handleSendMessage(): void {
    const { act } = useBackend<NtosMessengerData>(this.context);
    act('PDA_sendMessage', {
      ref: this.props.recp.ref,
      name: this.props.recp.name,
      job: this.props.recp.job,
      msg: this.state.msg,
    });
    this.setState({ msg: '', canSend: false });
    setTimeout(() => this.setState({ canSend: true }), 1000);
  }

  handleMessageInput(_: any, val: string): void {
    this.setState({ msg: val });
  }

  render(): InfernoNode | undefined {
    const { act } = useBackend<NtosMessengerData>(this.context);
    const { recp, onReturn, msgs } = this.props;
    const { msg, canSend } = this.state;

    let lastMsgRef = '';
    let filteredMessages: JSX.Element[] = [];

    for (let index = 0; index < msgs.length; index++) {
      let message = msgs[index];

      const isSwitch = lastMsgRef !== message.sender;
      lastMsgRef = message.sender;

      filteredMessages.push(
        <Stack.Item
          key={index}
          mt={isSwitch ? 1 : 0.5}
          shrink={0}
          textAlign={message.outgoing ? 'right' : ''}>
          <ChatMessage
            sender={isSwitch ? (message.outgoing ? 'You' : recp.name) : null}
            msg={message.contents}
            everyone={!!message.everyone}
            photo_path={message.photo_path}
          />
        </Stack.Item>
      );
    }

    return (
      <Stack vertical fill>
        <Stack.Item>
          <Section fill>
            <Button icon="arrow-left" content="Back" onClick={onReturn} />
            <Button.Confirm
              icon="trash-can"
              content="Delete chat"
              onClick={() => act('PDA_clearMessages', { ref: recp.ref })}
            />
          </Section>
        </Stack.Item>

        <Stack.Item grow={1}>
          <Section
            scrollable
            fill
            title={`${recp.name} (${recp.job})`}
            scrollableRef={this.scrollRef}>
            <Stack vertical justify="flex-end" fill>
              <Stack.Item textAlign="center" fontSize={1} color="gray">
                This is the beginning of your chat with {recp.name}.
              </Stack.Item>
              <Stack.Divider />
              {filteredMessages}
              {/* mb/pb doesnt work with flex-end, this'll have to do */}
              <Stack.Item height={1} />
            </Stack>
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section>
            <Stack fill>
              <Stack.Item grow={1}>
                <Input
                  placeholder={`Send message to ${recp.name}...`}
                  fluid
                  autofocus
                  justify
                  id="input"
                  value={msg}
                  maxLength={1024}
                  onInput={this.handleMessageInput}
                  onEnter={this.handleSendMessage}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="arrow-right"
                  onClick={this.handleSendMessage}
                  disabled={!canSend}
                />
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    );
  }
}

const SendToAllModal = (_: any, context: any) => {
  const { act } = useBackend(context);

  const [msg, setMsg] = useLocalState<string>(context, 'everyoneMessage', '');

  return (
    <>
      <Section>
        <Stack justify="space-between">
          <Stack.Item align="center">
            <Icon name="satellite-dish" mr={1} />
            Send To All
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="arrow-right"
              disabled={msg === ''}
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
