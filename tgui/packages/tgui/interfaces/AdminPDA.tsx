import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Input,
  Section,
  TextArea,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type UserList = Record<string, User>;

type User = {
  ref: string;
  username: string;
  invisible: BooleanLike;
};

type Data = {
  users: UserList;
};

export function AdminPDA(props) {
  const jobState = useState('');
  const nameState = useState('');
  const spamState = useState(false);
  const userState = useState('');
  const invisibleState = useState<BooleanLike>(0);

  return (
    <Window title="Send PDA Message" width={300} height={575} theme="admin">
      <Window.Content>
        <ReceiverChoice
          invisibleState={invisibleState}
          spamState={spamState}
          userState={userState}
        />
        <SenderInfo jobState={jobState} nameState={nameState} />
        <MessageInput
          invisibleState={invisibleState}
          jobState={jobState}
          nameState={nameState}
          spamState={spamState}
          userState={userState}
        />
      </Window.Content>
    </Window>
  );
}

type ReceiverProps = {
  invisibleState: [BooleanLike, (value: BooleanLike) => void];
  userState: [string, (value: string) => void];
  spamState: [boolean, (value: boolean) => void];
};

function ReceiverChoice(props: ReceiverProps) {
  const { data } = useBackend<Data>();
  const { users } = data;

  const [user, setUser] = props.userState;
  const [spam, setSpam] = props.spamState;
  const [showInvisible, setShowInvisible] = props.invisibleState;

  const receivers = Array.from(Object.values(users));
  const dropdownOptions = receivers
    .filter((rcvr) => showInvisible || !rcvr.invisible)
    .map((rcvr) => ({
      displayText: rcvr.username,
      value: rcvr.ref,
    }));

  return (
    <Section title="To Who?" textAlign="center">
      <Dropdown
        disabled={spam}
        selected={user}
        displayText={users[user]?.username}
        placeholder="Pick a user..."
        options={dropdownOptions}
        width="275px"
        mb={1}
        onSelected={(value) => {
          setUser(value);
        }}
      />
      <Box>
        <Button.Checkbox
          checked={showInvisible}
          fluid
          onClick={() => setShowInvisible(!showInvisible)}
        >
          Include invisible?
        </Button.Checkbox>
        <Button.Checkbox checked={spam} fluid onClick={() => setSpam(!spam)}>
          Should it be sent to everyone?
        </Button.Checkbox>
      </Box>
    </Section>
  );
}

type SenderInfoProps = {
  nameState: [string, (value: string) => void];
  jobState: [string, (value: string) => void];
};

function SenderInfo(props: SenderInfoProps) {
  const [_name, setName] = props.nameState;
  const [_job, setJob] = props.jobState;

  return (
    <Section title="From Who?" textAlign="center">
      <Box fontSize="14px">
        <Input placeholder="Sender name..." fluid onChange={setName} />
      </Box>
      <Box fontSize="14px" pt="10px">
        <Input placeholder="Sender's job..." fluid onChange={setJob} />
      </Box>
    </Section>
  );
}

type MessageInputProps = {
  jobState: [string, (value: string) => void];
  nameState: [string, (value: string) => void];
  spamState: [boolean, (value: boolean) => void];
  userState: [string, (value: string) => void];
  invisibleState: [BooleanLike, (value: BooleanLike) => void];
};

function getErrorText(
  name: string,
  job: string,
  message: string,
  target: boolean,
) {
  let reasonList: string[] = [];
  if (!target) reasonList.push('target');
  if (!name) reasonList.push('name');
  if (!job) reasonList.push('job');
  if (!message) reasonList.push('message text');
  return reasonList.join(', ');
}

function MessageInput(props: MessageInputProps) {
  const { act } = useBackend();

  const [messageText, setMessageText] = useState('');
  const [force, setForce] = useState(false);

  const [user] = props.userState;
  const [name] = props.nameState;
  const [job] = props.jobState;
  const [spam] = props.spamState;
  const [showInvisible] = props.invisibleState;

  const blocked = !name || !job || !messageText;

  return (
    <Section title="Message" textAlign="center">
      <Box>
        <TextArea
          fluid
          placeholder="Type the message you want to send..."
          height="200px"
          mb={1}
          onChange={setMessageText}
        />
      </Box>
      <Box>
        <Button.Checkbox
          fluid
          checked={force}
          tooltip={
            'This will immediately broadcast the message, bypassing telecomms altogether.'
          }
          onClick={() => setForce(!force)}
        >
          Force send the message?
        </Button.Checkbox>
        <Button
          tooltip={
            blocked
              ? 'Fill in the following lines: ' +
                getErrorText(name, job, messageText, spam || !!user)
              : 'Send message to user(s)'
          }
          fluid
          disabled={blocked}
          icon="envelope-open-text"
          onClick={() =>
            act('sendMessage', {
              force: force,
              include_invisible: showInvisible,
              job: job,
              message: messageText,
              name: name,
              ref: user,
              spam: spam,
            })
          }
        >
          Send Message
        </Button>
      </Box>
    </Section>
  );
}
