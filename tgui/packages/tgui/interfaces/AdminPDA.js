import { useBackend, useLocalState } from '../backend';
import { Section, Dropdown, Input, Box, TextArea } from '../components';
import { Button, ButtonCheckbox } from '../components/Button';
import { Window } from '../layouts';

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

  const [user, setUser] = useLocalState(context, 'user', '');
  const [spam, setSpam] = useLocalState(context, 'spam', false);

  return (
    <Section title="To Who?" textAlign="center">
      <Box>
        <Dropdown
          selected="Pick a target"
          options={receivers}
          width="275px"
          mb={1}
          onSelected={(value) => {
            setUser(value);
          }}
        />
      </Box>
      <Box>
        <ButtonCheckbox checked={spam} fluid onClick={() => setSpam(!spam)}>
          Should it be sent to everyone?
        </ButtonCheckbox>
      </Box>
    </Section>
  );
};

export const SenderInfo = (props, context) => {
  const [name, setName] = useLocalState(context, 'name', '');
  const [job, setJob] = useLocalState(context, 'job', '');

  return (
    <Section title="From Who?" textAlign="center">
      <Box fontSize="14px">
        <Input
          placeholder="Sender name..."
          fluid
          onInput={(e, value) => {
            setName(value);
          }}
        />
      </Box>
      <Box fontSize="14px" pt="10px">
        <Input
          placeholder="Sender's job..."
          fluid
          onInput={(e, value) => {
            setJob(value);
          }}
        />
      </Box>
    </Section>
  );
};

export const MessageInput = (props, context) => {
  const { act } = useBackend(context);

  const [user, setUser] = useLocalState(context, 'user', '');
  const [name, setName] = useLocalState(context, 'name', '');
  const [job, setJob] = useLocalState(context, 'job', '');
  const [messageText, setMessageText] = useLocalState(context, 'message', '');
  const [spam, setSpam] = useLocalState(context, 'spam', false);

  const tooltipText = function (name, job, message) {
    let reasonList = [];
    if (!name) reasonList.push('name');
    if (!job) reasonList.push('job');
    if (!message) reasonList.push('message text');
    return reasonList.join(', ');
  };

  const blocked = !name || !job || !messageText;

  return (
    <Section title="Message" textAlign="center">
      <Box>
        <TextArea
          placeholder="Type the message you want to send..."
          height="200px"
          mb={1}
          onInput={(e, value) => {
            setMessageText(value);
          }}
        />
      </Box>
      <Box>
        <Button
          tooltip={
            blocked
              ? 'Fill in the following lines: ' +
              tooltipText(name, job, messageText)
              : 'Send message to user(s)'
          }
          fluid
          disabled={blocked}
          icon="envelope-open-text"
          onClick={() =>
            act('sendMessage', {
              name: name,
              user: user,
              job: job,
              message: messageText,
              spam: spam,
            })
          }>
          Send Message
        </Button>
      </Box>
    </Section>
  );
};
