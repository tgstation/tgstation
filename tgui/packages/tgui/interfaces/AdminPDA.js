import { useBackend } from '../backend';
import { Section, Dropdown, Input, Box, TextArea } from '../components';
import { Button, ButtonCheckbox } from '../components/Button';
import { Window } from '../layouts';

let windowSize;

let user;
let spam = false;

let name, job;

let messageText;

export const AdminPDA = (props, context) => {
  return (
    <Window title="Send Message on PDA" width={300} height={525} theme="admin">
      <Window.Content>
        <ReceiverChoice />
        <SenderInfo />
        <MessageInput />
      </Window.Content>
    </Window>
  );
};

export const ReceiverChoice = (props, context) => {
  const { act, data } = useBackend(context);
  const receivers = Array.from(data.users).sort();
  const spam = data.spam;

  return (
    <Section title="To Who?" textAlign="center">
      <Box>
        <Dropdown
          selected="Pick a target"
          options={receivers}
          width="275px"
          mb={1}
          onSelected={(value) => {
            user = value;
          }}
        />
      </Box>
      <Box>
        <ButtonCheckbox checked={spam} fluid onClick={() => act('setSpam')}>
          Is it spam(send message to all)?
        </ButtonCheckbox>
      </Box>
    </Section>
  );
};

export const SenderInfo = () => {
  return (
    <Section title="From Who?" textAlign="center">
      <Box fontSize="14px">
        <Input
          placeholder="Name of sender"
          fluid
          onInput={(e, value) => {
            name = value;
          }}
        />
      </Box>
      <Box fontSize="14px" pt="10px">
        <Input
          placeholder="Job/rank of sender"
          fluid
          onInput={(e, value) => {
            job = value;
          }}
        />
      </Box>
    </Section>
  );
};

export const MessageInput = (props, context) => {
  const { act } = useBackend(context);
  let blocked, reason;
  if (!name || !job || !messageText) {
    blocked = true;
  }
  reason =
    'You must input: ' +
    (name ? '' : 'name ') +
    (job ? '' : 'job ') +
    (messageText ? '' : 'message ');

  return (
    <Section title="Message" textAlign="center">
      <Box>
        <TextArea
          placeholder="Enter a message what you want to send"
          height="200px"
          mb={1}
          onInput={(e, value) => {
            messageText = value;
          }}
        />
      </Box>
      <Box>
        <Button
          tooltip={blocked ? reason : 'Send message to user(s)'}
          fluid
          disabled={blocked}
          icon="envelope-open-text"
          onClick={() =>
            act('sendMessage', {
              name: name,
              user: user,
              job: job,
              message: messageText,
            })
          }>
          Send Message
        </Button>
      </Box>
    </Section>
  );
};
