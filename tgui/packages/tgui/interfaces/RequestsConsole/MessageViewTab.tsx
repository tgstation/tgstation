import { useBackend } from '../../backend';
import { BlockQuote, Section, Stack } from '../../components';
import { RequestsData } from './Types';

export const MessageViewTab = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  const { messages = [] } = data;
  return (
    <Section fill scrollable>
      {!!messages.length && (
        <Stack vertical>
          {messages.map((message) => (
            <Stack.Item>
              <BlockQuote>{message.content}</BlockQuote>
            </Stack.Item>
          ))}
        </Stack>
      )}
    </Section>
  );
};
