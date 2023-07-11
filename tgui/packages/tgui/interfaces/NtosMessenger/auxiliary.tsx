import { Dimmer, Stack, Icon, Box } from '../../components';
import { sanitizeText } from '../../sanitize';
import { BooleanLike } from 'common/react';
import { SFC } from 'inferno';

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

export type ChatMessageProps = {
  isSelf: BooleanLike;
  msg: string;
  everyone?: BooleanLike;
  photoPath?: string;
};

export const ChatMessage: SFC<ChatMessageProps> = (props: ChatMessageProps) => {
  const { msg, everyone, isSelf, photoPath } = props;
  const text = {
    __html: sanitizeText(msg),
  };

  return (
    <Box className={`NtosMessenger__ChatMessage${isSelf ? '__outgoing' : ''}`}>
      <Box
        className="NtosMessenger__ChatMessage__content"
        dangerouslySetInnerHTML={text}
      />
      {photoPath !== null && <Box as="img" src={photoPath} />}
      {everyone && (
        <Box className="NtosMessenger__ChatMessage__everyone">
          Sent to everyone
        </Box>
      )}
    </Box>
  );
};
