import { Section, Dropdown, Input, Box, TextArea } from '../components';
import { useBackend, useLocalState } from '../backend';
import { Button } from '../components/Button';
import { Window } from '../layouts';

export const AdminPDA = (props, context) => {
  return (
    <Window title="Send PDA Message" width={300} height={575} theme="admin">
      <Window.Content>
        <ReceiverChoice />
        <SenderInfo />
        <MessageInput />
      </Window.Content>
    </Window>
  );
};

const ReceiverChoice = (props, context) => {
  const { data } = useBackend(context);
  const { users } = data;
  const receivers = Array.from(Object.values(users));

  const [user, setUser] = useLocalState(context, 'user', '');
  const [spam, setSpam] = useLocalState(context, 'spam', false);
  const [showInvisible, setShowInvisible] = useLocalState(
    context,
    'showInvisible',
    false
  );

  return (
    <Section title="To Who?" textAlign="center">
      <Box>
        <Dropdown
          disabled={spam}
          selected={user}
          displayText={user ? users[user].username : 'Pick a user...'}
          options={receivers
            .filter((rcvr) => showInvisible || !rcvr.invisible)
            .map((rcvr) => ({
              displayText: rcvr.username,
              value: rcvr.ref,
            }))}
          width="275px"
          mb={1}
          onSelected={(value) => {
            setUser(value);
          }}
        />
      </Box>
      <Box>
        <Button.Checkbox
          checked={showInvisible}
          fluid
          onClick={() => setShowInvisible(!showInvisible)}
          content="Include invisible?"
        />
        <Button.Checkbox
          checked={spam}
          fluid
          onClick={() => setSpam(!spam)}
          content="Should it be sent to everyone?"
        />
      </Box>
    </Section>
  );
};

const SenderInfo = (props, context) => {
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

const MessageInput = (props, context) => {
  const { act } = useBackend(context);

  const [user, setUser] = useLocalState(context, 'user', '');
  const [name, setName] = useLocalState(context, 'name', '');
  const [job, setJob] = useLocalState(context, 'job', '');
  const [messageText, setMessageText] = useLocalState(context, 'message', '');
  const [spam, setSpam] = useLocalState(context, 'spam', false);
  const [force, setForce] = useLocalState(context, 'force', false);
  const [showInvisible, setShowInvisible] = useLocalState(
    context,
    'showInvisible',
    false
  );

  const tooltipText = function (name, job, message, target) {
    let reasonList = [];
    if (!target) reasonList.push('target');
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
        <Button.Checkbox
          fluid
          checked={force}
          content="Force send the message?"
          tooltip={
            'This will immediately broadcast the message, bypassing telecomms altogether.'
          }
          onClick={() => setForce(!force)}
        />
        <Button
          tooltip={
            blocked
              ? 'Fill in the following lines: ' +
              tooltipText(name, job, messageText, spam || !!user)
              : 'Send message to user(s)'
          }
          fluid
          disabled={blocked}
          icon="envelope-open-text"
          onClick={() =>
            act('sendMessage', {
              name: name,
              job: job,
              ref: user,
              message: messageText,
              spam: spam,
              include_invisible: showInvisible,
              force: force,
            })
          }>
          Send Message
        </Button>
      </Box>
    </Section>
  );
};
