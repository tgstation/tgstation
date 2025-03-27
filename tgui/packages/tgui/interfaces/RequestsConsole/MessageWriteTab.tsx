import { sort } from 'common/collections';
import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';

import { useBackend, useLocalState } from '../../backend';
import { RequestPriority, RequestsData, RequestType } from './types';

export const MessageWriteTab = (props) => {
  const { act, data } = useBackend<RequestsData>();
  const {
    authentication_data,
    hack_state,
    assistance_consoles = [],
    supply_consoles = [],
    information_consoles = [],
  } = data;

  const sorted_assistance = sort(assistance_consoles);
  const sorted_supply = sort(supply_consoles);
  const sorted_information = sort(information_consoles);

  const resetMessage = () => {
    setMessageText('');
    setRecipient('');
    setPriority(RequestPriority.NORMAL);
    setRequestType(RequestType.ASSISTANCE);
  };
  const [messageText, setMessageText] = useLocalState('messageText', '');
  const [requestType, setRequestType] = useState(RequestType.ASSISTANCE);
  const [priority, setPriority] = useState(RequestPriority.NORMAL);
  const [recipient, setRecipient] = useState('');
  return (
    <Section>
      <Stack fill mb={2}>
        <Stack.Item grow>
          <Button
            fluid
            icon="handshake-angle"
            selected={requestType === RequestType.ASSISTANCE}
            onClick={() => {
              setRecipient('');
              setRequestType(RequestType.ASSISTANCE);
            }}
          >
            Request Assistance
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <Button
            fluid
            icon="boxes-stacked"
            selected={requestType === RequestType.SUPPLIES}
            onClick={() => {
              setRecipient('');
              setRequestType(RequestType.SUPPLIES);
            }}
          >
            Request Supplies
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <Button
            fluid
            icon="upload"
            selected={requestType === RequestType.INFORMATION}
            onClick={() => {
              setRecipient('');
              setRequestType(RequestType.INFORMATION);
            }}
          >
            Relay Information
          </Button>
        </Stack.Item>
      </Stack>
      <Box>
        {requestType === RequestType.ASSISTANCE && (
          <Dropdown
            width="100%"
            options={sorted_assistance}
            selected={recipient}
            placeholder="Pick a Recipient"
            onSelected={(value) => setRecipient(value)}
          />
        )}
        {requestType === RequestType.SUPPLIES && (
          <Dropdown
            width="100%"
            options={sorted_supply}
            selected={recipient}
            placeholder="Pick a Recipient"
            onSelected={(value) => setRecipient(value)}
          />
        )}
        {requestType === RequestType.INFORMATION && (
          <Dropdown
            width="100%"
            options={sorted_information}
            selected={recipient}
            placeholder="Pick a Recipient"
            onSelected={(value) => setRecipient(value)}
          />
        )}
      </Box>
      <Stack fill mt={2} mb={2}>
        <Stack.Item grow>
          <Button
            icon="envelope"
            content="Normal Priority"
            key={RequestPriority.NORMAL}
            fluid
            selected={priority === RequestPriority.NORMAL}
            onClick={() => setPriority(RequestPriority.NORMAL)}
          />
        </Stack.Item>
        <Stack.Item grow>
          <Button
            icon="exclamation"
            content="High Priority"
            key={RequestPriority.HIGH}
            fluid
            selected={priority === RequestPriority.HIGH}
            onClick={() => setPriority(RequestPriority.HIGH)}
          />
        </Stack.Item>
        {!!hack_state && (
          <Stack.Item grow>
            <Button
              icon="burst"
              content="EXTREME PRIORITY"
              key={RequestPriority.EXTREME}
              fluid
              selected={priority === RequestPriority.EXTREME}
              onClick={() => setPriority(RequestPriority.EXTREME)}
            />
          </Stack.Item>
        )}
      </Stack>
      <TextArea
        fluid
        height={20}
        maxLength={1025}
        value={messageText}
        onChange={(_, value) => setMessageText(value)}
        placeholder="Type your message..."
      />
      <Section>
        <Stack fill justify="space-between">
          <Stack.Item>
            <Button
              icon="paper-plane"
              disabled={!messageText || !recipient || !priority || !requestType}
              onClick={() => {
                if (!messageText || !recipient || !priority || !requestType) {
                  return;
                }

                act('send_message', {
                  message: messageText,
                  recipient: recipient,
                  request_type: requestType,
                  priority: priority,
                });
                resetMessage();
              }}
            >
              Send message
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button icon="id-card" onClick={() => act('verify_id')}>
              {authentication_data.message_verified_by || 'Not verified'}
            </Button>
            <Button icon="stamp" onClick={() => act('stamp')}>
              {authentication_data.message_stamped_by || 'Not stamped'}
            </Button>
          </Stack.Item>
        </Stack>
        <Button
          icon="trash-can"
          onClick={() => {
            act('clear_authentication');
            resetMessage();
          }}
        >
          Discard message
        </Button>
      </Section>
    </Section>
  );
};
