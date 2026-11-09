import { Component, createRef, type RefObject } from 'react';
import {
  Box,
  Button,
  Icon,
  Image,
  Input,
  Modal,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';
import type { NtMessage, NtMessenger, NtPicture } from './types';

type ChatScreenProps = {
  canReply: BooleanLike;
  chatRef?: string;
  isSilicon: BooleanLike;
  messages: NtMessage[];
  recipient: NtMessenger;
  selectedPhoto?: string;
  sendingVirus: BooleanLike;
  storedPhotos?: NtPicture[];
  unreads: number;
};

type ChatScreenState = {
  canSend: boolean;
  message: string;
  previewingImage?: string;
  selectingPhoto: boolean;
};

const READ_UNREADS_TIME_MS = 1000;
const SEND_COOLDOWN_MS = 1000;

export class ChatScreen extends Component<ChatScreenProps, ChatScreenState> {
  readUnreadsTimeout: NodeJS.Timeout | null = null;
  scrollRef: RefObject<HTMLDivElement | null>;

  state: ChatScreenState = {
    message: '',
    selectingPhoto: false,
    canSend: true,
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
    _snapshot: any,
  ) {
    if (prevProps.messages.length !== this.props.messages.length) {
      this.scrollToBottom();
      this.trySetReadTimeout();
    }
  }

  componentWillUnmount() {
    if (!this.props.chatRef) {
      return;
    }

    const { act } = useBackend();

    this.tryClearReadTimeout();

    act('PDA_saveMessageDraft', {
      ref: this.props.chatRef,
      message: this.state.message,
    });
  }

  trySetReadTimeout() {
    if (!this.props.chatRef) {
      return;
    }
    const unreadMessages = this.props.unreads;

    this.tryClearReadTimeout();

    if (unreadMessages > 0) {
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
    const { act } = useBackend();

    act('PDA_clearUnreads', { ref: this.props.chatRef });
  }

  scrollToBottom() {
    const scroll = this.scrollRef.current;
    if (scroll !== null) {
      scroll.scrollTop = scroll.scrollHeight;
    }
  }

  handleSelectPicture() {
    const { isSilicon } = this.props;
    const { act } = useBackend();
    if (isSilicon) {
      act('PDA_siliconSelectPhoto');
    } else {
      this.setState({ selectingPhoto: true });
    }
  }

  handleSendMessage() {
    if (this.state.message === '') {
      return;
    }

    const { act } = useBackend();
    const { chatRef, recipient } = this.props;

    const ref = chatRef ? chatRef : recipient.ref;

    act('PDA_sendMessage', {
      ref: ref,
      message: this.state.message,
    });

    this.setState({ message: '', canSend: false });
    setTimeout(() => this.setState({ canSend: true }), SEND_COOLDOWN_MS);
  }

  handleMessageInput(val: string) {
    this.setState({ message: val });
  }

  render() {
    const { act } = useBackend();
    const {
      canReply,
      messages,
      recipient,
      chatRef,
      selectedPhoto,
      storedPhotos,
      sendingVirus,
      unreads,
    } = this.props;
    const { message, canSend, previewingImage, selectingPhoto } = this.state;

    const filteredMessages: React.JSX.Element[] = [];

    for (let index = 0; index < messages.length; index++) {
      const message = messages[index];
      const isSwitch = !(
        index === 0 || messages[index - 1].outgoing === message.outgoing
      );

      // this code shouldn't be reached if there's no chat
      if (index === messages.length - unreads) {
        filteredMessages.push(<ChatDivider mt={isSwitch ? 3 : 1} />);
      }

      filteredMessages.push(
        <Stack.Item key={index} mt={isSwitch ? 3 : 1}>
          <ChatMessage
            outgoing={message.outgoing}
            message={message.message}
            everyone={message.everyone}
            photoPath={message.photo_path}
            timestamp={message.timestamp}
            onPreviewImage={
              message.photo_path
                ? () => this.setState({ previewingImage: message.photo_path! })
                : undefined
            }
          />
        </Stack.Item>,
      );
    }

    let sendingBar: React.JSX.Element;

    if (!canReply) {
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
            }}
          >
            <Image src={photo.path} maxHeight={10} />
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

      const buttons = canReply ? (
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
                >
                  <Image src={selectedPhoto} />
                </Button>
              </Stack.Item>
            )}
            <Stack.Item>
              <Stack fill align="center">
                <Stack.Item grow>
                  <Input
                    placeholder={`Send message to ${recipient.name}...`}
                    fluid
                    autoFocus
                    value={message}
                    maxLength={1024}
                    onChange={this.handleMessageInput}
                    onEnter={this.handleSendMessage}
                    selfClear
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
          <Button
            icon="arrow-left"
            content="Back"
            onClick={() => act('PDA_viewMessages', { ref: null })}
          />
          {chatRef && (
            <>
              <Button
                icon="box-archive"
                content="Close chat"
                onClick={() => act('PDA_closeMessages', { ref: chatRef })}
              />
              <Button.Confirm
                icon="trash-can"
                content="Delete chat"
                onClick={() => act('PDA_clearMessages', { ref: chatRef })}
              />
            </>
          )}
        </Section>

        <Stack.Item grow={1}>
          <Section
            scrollable
            fill
            fitted
            title={`${recipient.name} (${recipient.job})`}
            ref={this.scrollRef}
          >
            <Stack vertical className="NtosChatLog">
              {!!(messages.length > 0 && canReply) && (
                <>
                  <Stack.Item textAlign="center" fontSize={1}>
                    This is the beginning of your chat with {recipient.name}.
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
                  onClick={() => this.setState({ previewingImage: undefined })}
                />
              }
            >
              <Image src={previewingImage} />
            </Section>
          </Modal>
        )}
      </Stack>
    );
  }
}

type ChatMessageProps = {
  outgoing: BooleanLike;
  message: string;
  everyone: BooleanLike;
  timestamp: string;
  photoPath?: string;
  onPreviewImage?: () => void;
};

const ChatMessage = (props: ChatMessageProps) => {
  const { message, everyone, outgoing, photoPath, timestamp, onPreviewImage } =
    props;

  const messageHTML = {
    __html: `${message}`,
  };

  return (
    <Box className={`NtosChatMessage${outgoing ? '_outgoing' : ''}`}>
      <Box className="NtosChatMessage__content">
        <Box as="span" dangerouslySetInnerHTML={messageHTML} />
        <Tooltip content={timestamp} position={outgoing ? 'left' : 'right'}>
          <Icon
            className="NtosChatMessage__timestamp"
            name="clock-o"
            size={0.8}
          />
        </Tooltip>
      </Box>
      {!!everyone && (
        <Box className="NtosChatMessage__everyone">Sent to everyone</Box>
      )}
      {!!photoPath && (
        <Button
          tooltip="View image"
          className="NtosChatMessage__image"
          color="transparent"
          onClick={onPreviewImage}
        >
          <Image src={photoPath} mt={1} />
        </Button>
      )}
    </Box>
  );
};

const ChatDivider = (props: { mt: number }) => {
  return (
    <Box className="UnreadDivider" m={0} mt={props.mt}>
      <div />
      <span>Unread Messages</span>
      <div />
    </Box>
  );
};
