import {
  BlockQuote,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../../backend';
import {
  type RequestMessage,
  RequestPriority,
  type RequestsData,
  RequestType,
} from './types';

export const MessageViewTab = (props) => {
  const { act, data } = useBackend<RequestsData>();
  const { messages = [] } = data;
  return (
    <Section fill scrollable>
      <Stack vertical>
        {messages.map((message) => (
          <MessageDisplay key={message.received_time} message={message} />
        ))}
      </Stack>
    </Section>
  );
};

const MessageDisplay = (props: { message: RequestMessage }) => {
  const { act } = useBackend();
  const { message } = props;
  const append_list_keys = message.appended_list
    ? Object.keys(message.appended_list)
    : [];
  return (
    <Stack.Item>
      <Section
        title={
          message.request_type +
          ' from ' +
          message.sender_department +
          ', ' +
          message.received_time
        }
      >
        {message.priority === RequestPriority.HIGH && (
          <NoticeBox>High Priority</NoticeBox>
        )}
        {message.priority === RequestPriority.EXTREME && (
          <NoticeBox danger>!!!Extreme Priority!!!</NoticeBox>
        )}
        <BlockQuote>
          {decodeHtmlEntities(message.content)}
          {!!message.appended_list && !!append_list_keys.length && (
            <LabeledList>
              {append_list_keys.map((list_key) => (
                <LabeledList.Item key={list_key} label={list_key}>
                  {message.appended_list[list_key]}
                </LabeledList.Item>
              ))}
            </LabeledList>
          )}
        </BlockQuote>
        <LabeledList>
          <LabeledList.Item label="Message Verified By">
            {message.message_verified_by || 'Not Verified'}
          </LabeledList.Item>
          <LabeledList.Item label="Message Stamped By">
            {message.message_stamped_by || 'Not Stamped'}
          </LabeledList.Item>
        </LabeledList>
        {message.request_type !== RequestType.ORE_UPDATE && (
          <Section>
            <Button
              icon="reply"
              content="Quick Reply"
              onClick={() => {
                act('quick_reply', {
                  reply_recipient: message.sender_department,
                });
              }}
            />
          </Section>
        )}
      </Section>
    </Stack.Item>
  );
};
