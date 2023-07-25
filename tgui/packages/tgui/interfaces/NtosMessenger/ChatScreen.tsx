import { Stack, Section, Button, Box, Input, Modal } from '../../components';
import { Component, RefObject, createRef, SFC } from 'inferno';
import { NtChat, NtMessenger, NtPicture } from './types';
import { sanitizeText } from '../../sanitize';
import { BooleanLike } from 'common/react';
import { useBackend } from '../../backend';

type ChatScreenProps = {
  onReturn: () => void;
  // if one doesn't exist, assume the other one does
  chat?: NtChat;
  temp_msgr?: NtMessenger;
  storedPhotos?: NtPicture[];
  selectedPhoto: string | null;
  isSilicon: BooleanLike;
  sendingVirus: BooleanLike;
};

type ChatScreenState = {
  msg: string;
  selectingPhoto: boolean;
  canSend: boolean;
  previewingImage: string | null;
};

const READ_UNREADS_TIME_MS = 3000;
const SEND_COOLDOWN_MS = 1000;

export class ChatScreen extends Component<ChatScreenProps, ChatScreenState> {
  scrollRef: RefObject<HTMLDivElement>;
  readUnreadsTimeout: NodeJS.Timeout | null;

  state: ChatScreenState = {
    msg: '',
    selectingPhoto: false,
    canSend: true,
    previewingImage: null,
  };

  constructor(props: ChatScreenProps) {
    super(props);

    this.scrollRef = createRef();

    this.scrollToBottom = this.scrollToBottom.bind(this);
    this.handleMessageInput = this.handleMessageInput.bind(this);
    this.handleSelectPicture = this.handleSelectPicture.bind(this);
    this.handleSendMessage = this.handleSendMessage.bind(this);
    this.trySetReadTimeout = this.trySetReadTimeout.bind(this);
    this.tryClearReadTimeout = this.tryClearReadTimeout.bind(this);
    this.clearUnreads = this.clearUnreads.bind(this);
  }

  componentDidMount() {
    this.scrollToBottom();
    this.trySetReadTimeout();
  }

  componentDidUpdate(
    prevProps: ChatScreenProps,
    _prevState: ChatScreenState,
    _snapshot: any
  ) {
    if (prevProps.chat?.messages.length !== this.props.chat?.messages.length) {
      this.scrollToBottom();
      this.trySetReadTimeout();
    }
  }

  componentWillUnmount() {
    const { act } = useBackend(this.context);

    const chat = this.props.chat;
    if (!chat) return;

    this.tryClearReadTimeout();

    act('PDA_saveMessageDraft', {
      ref: chat.ref,
      msg: this.state.msg,
    });
  }

  trySetReadTimeout() {
    const chat = this.props.chat;

    this.tryClearReadTimeout();

    if (chat && chat.unread_messages > 0) {
      this.readUnreadsTimeout = setTimeout(() => {
        this.clearUnreads();
        this.readUnreadsTimeout = null;
      }, READ_UNREADS_TIME_MS);
    }
  }

  tryClearReadTimeout() {
    if (this.readUnreadsTimeout) {
      clearTimeout(this.readUnreadsTimeout);
      this.readUnreadsTimeout = null;
    }
  }

  clearUnreads() {
    const { act } = useBackend(this.context);
    const chat = this.props.chat;
    act('PDA_clearUnreads', { ref: chat!.ref });
  }

  scrollToBottom() {
    const scroll = this.scrollRef.current;
    if (scroll !== null) {
      scroll.scrollTop = scroll.scrollHeight;
    }
  }

  handleSelectPicture() {
    const { isSilicon } = this.props;
    const { act } = useBackend(this.context);
    if (isSilicon) {
      act('PDA_siliconSelectPhoto');
    } else {
      this.setState({ selectingPhoto: true });
    }
  }

  handleSendMessage() {
    if (this.state.msg === '') return;
    const { act } = useBackend(this.context);
    const { temp_msgr, chat } = this.props;

    let ref = chat ? chat.ref : temp_msgr!.ref!;

    act('PDA_sendMessage', {
      ref: ref,
      msg: this.state.msg,
    });

    this.setState({ msg: '', canSend: false });
    setTimeout(() => this.setState({ canSend: true }), SEND_COOLDOWN_MS);
  }

  handleMessageInput(_: any, val: string) {
    this.setState({ msg: val });
  }

  render() {
    const { act } = useBackend(this.context);
    const {
      onReturn,
      chat,
      temp_msgr,
      selectedPhoto,
      storedPhotos,
      sendingVirus,
    } = this.props;
    const { msg, canSend, previewingImage, selectingPhoto } = this.state;

    // one or the other has to exist
    const recp = chat ? chat.recp : temp_msgr!;
    const msgs = chat ? chat.messages : [];

    let lastOutgoing: boolean = false;
    let filteredMessages: JSX.Element[] = [];

    for (let index = 0; index < msgs.length; index++) {
      const message = msgs[index];
      const isSwitch = lastOutgoing !== !!message.outgoing;
      lastOutgoing = !!message.outgoing;

      // this code shouldn't be reached if there's no chat
      if (index === msgs.length - chat!.unread_messages) {
        filteredMessages.push(<ChatDivider mt={isSwitch ? 3 : 1} />);
      }

      filteredMessages.push(
        <Stack.Item key={index} mt={isSwitch ? 3 : 1}>
          <ChatMessage
            outgoing={message.outgoing}
            msg={message.message}
            everyone={message.everyone}
            photoPath={message.photo_path}
            onPreviewImage={
              message.photo_path
                ? () => this.setState({ previewingImage: message.photo_path! })
                : undefined
            }
          />
        </Stack.Item>
      );
    }

    let sendingBar: JSX.Element;

    if (chat && !chat.can_reply) {
      sendingBar = (
        <Section fill>
          <Box width="100%" italic color="gray" ml={1}>
            You cannot reply to this user.
          </Box>
        </Section>
      );
    } else if (selectingPhoto) {
      const photos = storedPhotos!.map((photo) => (
        <Stack.Item key={photo.uid}>
          <Button
            pt={1}
            selected={selectedPhoto === photo.path}
            onClick={() => {
              act('PDA_selectPhoto', { uid: photo.uid });
              this.setState({ selectingPhoto: false });
            }}>
            <Box as="img" src={photo.path} maxHeight={10} />
          </Button>
        </Stack.Item>
      ));

      sendingBar = (
        <Section fill>
          <Button
            icon="arrow-left"
            content="Back"
            onClick={() => this.setState({ selectingPhoto: false })}
          />
          {photos.length > 0 ? (
            <Section scrollableHorizontal>
              <Stack fill>{photos}</Stack>
            </Section>
          ) : (
            <Box as="span" ml={1}>
              No photos found
            </Box>
          )}
        </Section>
      );
    } else {
      const attachmentButton = sendingVirus ? (
        <Button
          tooltip="ERROR: File signature is unverified. Please contact an NT support intern."
          icon="triangle-exclamation"
          color="red"
        />
      ) : (
        <Button
          tooltip="Add attachment"
          icon="image"
          onClick={this.handleSelectPicture}
        />
      );

      const buttons =
        temp_msgr || chat?.can_reply ? (
          <>
            <Stack.Item>{attachmentButton}</Stack.Item>
            <Stack.Item>
              <Button
                tooltip="Send"
                icon="arrow-right"
                onClick={this.handleSendMessage}
                disabled={!canSend}
              />
            </Stack.Item>
          </>
        ) : (
          ''
        );

      sendingBar = (
        <Section fill>
          <Stack vertical>
            {selectedPhoto && (
              <Stack.Item>
                <Button
                  pt={1}
                  onClick={() => act('PDA_clearPhoto')}
                  tooltip="Remove attachment"
                  tooltipPosition="auto-end">
                  <Box as="img" src={selectedPhoto} />
                </Button>
              </Stack.Item>
            )}
            <Stack.Item>
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
                {buttons}
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
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
            <Stack vertical className="NtosChatLog">
              {!!chat?.can_reply && (
                <>
                  <Stack.Item textAlign="center" fontSize={1}>
                    This is the beginning of your chat with {recp.name}.
                  </Stack.Item>
                  <Stack.Divider />
                </>
              )}

              {filteredMessages}
            </Stack>
          </Section>
        </Stack.Item>

        <Stack.Item>{sendingBar}</Stack.Item>
        {previewingImage && (
          <Modal className="NtosChatLog__ImagePreview">
            <Section
              title="Photo Preview"
              buttons={
                <Button
                  icon="arrow-left"
                  content="Back"
                  tooltipPosition="left"
                  onClick={() => this.setState({ previewingImage: null })}
                />
              }>
              <Box as="img" src={previewingImage} />
            </Section>
          </Modal>
        )}
      </Stack>
    );
  }
}

type ChatMessageProps = {
  outgoing: BooleanLike;
  msg: string;
  everyone: BooleanLike;
  photoPath?: string;
  onPreviewImage?: () => void;
};

const ChatMessage: SFC<ChatMessageProps> = (props: ChatMessageProps) => {
  const { msg, everyone, outgoing, photoPath, onPreviewImage } = props;
  const text = {
    __html: sanitizeText(msg),
  };

  return (
    <Box className={`NtosChatMessage${outgoing ? '_outgoing' : ''}`}>
      <Box
        className="NtosChatMessage__content"
        dangerouslySetInnerHTML={text}
      />
      {photoPath !== null && (
        <Button
          tooltip="View image"
          className="NtosChatMessage__image"
          color="transparent"
          onClick={onPreviewImage}>
          <Box as="img" src={photoPath} mt={1} />
        </Button>
      )}
      {!!everyone && (
        <Box className="NtosChatMessage__everyone">Sent to everyone</Box>
      )}
    </Box>
  );
};

const ChatDivider: SFC<{ mt: number }> = (props) => {
  return (
    <Box className="UnreadDivider" m={0} mt={props.mt}>
      <div />
      <span>Unread Messages</span>
      <div />
    </Box>
  );
};
