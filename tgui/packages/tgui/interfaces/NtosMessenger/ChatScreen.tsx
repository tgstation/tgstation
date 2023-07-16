import { Stack, Section, Button, Box, Input } from '../../components';
import { Component, RefObject, createRef, SFC } from 'inferno';
import { NtChat, NtMessenger } from './types';
import { sanitizeText } from '../../sanitize';
import { BooleanLike } from 'common/react';
import { useBackend } from '../../backend';

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

export class ChatScreen extends Component<ChatScreenProps, ChatScreenState> {
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
    const { act } = useBackend(this.context);

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
    const { act } = useBackend(this.context);
    const { onReturn, chat, temp_msgr } = this.props;
    const { msg, canSend } = this.state;

    // one or the other has to exist
    const recp = chat ? chat.recp : temp_msgr!;
    const msgs = chat ? chat.messages : [];

    let lastOutgoing: boolean = false;
    let filteredMessages: JSX.Element[] = [];

    for (let index = 0; index < msgs.length; index++) {
      let message = msgs[index];

      const isSwitch = lastOutgoing !== !!message.outgoing;
      lastOutgoing = !!message.outgoing;

      filteredMessages.push(
        <Stack.Item key={index} mt={isSwitch ? 5 : 1}>
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
        </Section>

        <Stack.Item grow={1}>
          <Section
            scrollable
            fill
            fitted
            title={`${recp.name} (${recp.job})`}
            scrollableRef={this.scrollRef}>
            <Stack vertical height="auto" className="ChatLog">
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
            <Stack fill align="center">
              <Stack.Item grow={1}>
                <Input
                  placeholder={`Send message to ${recp.name}...`}
                  fluid
                  autoFocus
                  width="100%"
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

export type ChatMessageProps = {
  outgoing: BooleanLike;
  msg: string;
  everyone?: BooleanLike;
  photoPath?: string;
};

export const ChatMessage: SFC<ChatMessageProps> = (props: ChatMessageProps) => {
  const { msg, everyone, outgoing, photoPath } = props;
  const text = {
    __html: sanitizeText(msg),
  };

  return (
    <Box className={`ChatMessage${outgoing ? '_outgoing' : ''}`}>
      <Box className="ChatMessage__content" dangerouslySetInnerHTML={text} />
      {photoPath !== null && <Box as="img" src={photoPath} />}
      {!!everyone && (
        <Box className="ChatMessage__everyone">Sent to everyone</Box>
      )}
    </Box>
  );
};
