import { Button, NoticeBox, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { RequestPriority, type RequestsData } from './types';

export const RequestsConsoleHeader = (props) => {
  const { act, data } = useBackend<RequestsData>();
  const { has_mail_send_error, new_message_priority } = data;
  return (
    <Stack.Item mb={1}>
      {!!has_mail_send_error && <ErrorNoticeBox />}
      {!!new_message_priority && <MessageNoticeBox />}
      <EmergencyBox />
    </Stack.Item>
  );
};

const EmergencyBox = (props) => {
  const { act, data } = useBackend<RequestsData>();
  const { emergency } = data;
  return (
    <>
      {!!emergency && (
        <NoticeBox danger>
          {emergency} has been dispatched to this location
        </NoticeBox>
      )}
      {!emergency && (
        <Stack fill>
          <Stack.Item grow>
            <Button
              fluid
              color="red"
              icon="shield"
              content="Call Security"
              onClick={() =>
                act('set_emergency', {
                  emergency: 'Security',
                })
              }
            />
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              color="red"
              icon="screwdriver-wrench"
              content="Call Engineering"
              onClick={() =>
                act('set_emergency', {
                  emergency: 'Engineering',
                })
              }
            />
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              color="red"
              icon="suitcase-medical"
              content="Call Medical"
              onClick={() =>
                act('set_emergency', {
                  emergency: 'Medical',
                })
              }
            />
          </Stack.Item>
        </Stack>
      )}
    </>
  );
};

const ErrorNoticeBox = (props) => {
  return (
    <NoticeBox danger>{'Error occured while sending a message!'}</NoticeBox>
  );
};

const MessageNoticeBox = (props) => {
  const { data } = useBackend<RequestsData>();
  const { new_message_priority } = data;
  return (
    <NoticeBox>
      {'You have new unread '}
      {new_message_priority === RequestPriority.HIGH && 'PRIORITY '}
      {new_message_priority === RequestPriority.EXTREME && 'EXTREME PRIORITY '}
      {'messages'}
    </NoticeBox>
  );
};
