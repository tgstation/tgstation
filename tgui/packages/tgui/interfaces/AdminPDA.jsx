import { useBackend, useLocalState } from '../backend';
import { Box, Dropdown, Input, Section, TextArea } from '../components';
import { Button } from '../components/Button';
import { Window } from '../layouts';

export const AdminPDA = (props) => {
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

const ReceiverChoice = (props) => {
  const { data } = useBackend();
  const { users } = data;
  const receivers = Array.from(Object.values(users));

  const [user, setUser] = useLocalState('user', '');
  const [spam, setSpam] = useLocalState('spam', false);
  const [showInvisible, setShowInvisible] = useLocalState(
    'showInvisible',
    false,
  );

  return (
    <Section title="To Who?" textAlign="center">
      <Box>
        <Dropdown
          disabled={spam}
          selected={user}
          displayText={users[user]?.username}
          placeholder="Pick a user..."
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

const SenderInfo = (props) => {
  const [name, setName] = useLocalState('name', '');
  const [job, setJob] = useLocalState('job', '');

  return (
    <Section title="From Who?" textAlign="center">
      <Box fontSize="14px">
        <Input
          placeholder="Sender name..."
          fluid
          onChange={(e, value) => {
            setName(value);
          }}
        />
      </Box>
      <Box fontSize="14px" pt="10px">
        <Input
          placeholder="Sender's job..."
          fluid
          onChange={(e, value) => {
            setJob(value);
          }}
        />
      </Box>
    </Section>
  );
};

const MessageInput = (props) => {
  const { act } = useBackend();

  const [user, setUser] = useLocalState('user', '');
  const [name, setName] = useLocalState('name', '');
  const [job, setJob] = useLocalState('job', '');
  const [messageText, setMessageText] = useLocalState('message', '');
  const [spam, setSpam] = useLocalState('spam', false);
  const [force, setForce] = useLocalState('force', false);
  const [showInvisible, setShowInvisible] = useLocalState(
    'showInvisible',
    false,
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
          onChange={(e, value) => {
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
          }
        >
          Send Message
        </Button>
      </Box>
    </Section>
  );
};
