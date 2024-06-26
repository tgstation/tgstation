import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  Section,
  Divider,
  Flex,
  Box,
  BlockQuote,
  Input,
  LabeledList,
  Button,
} from '../components';

export const NifSoulPoem = (props) => {
  const { act, data } = useBackend();
  const {
    name_to_send,
    text_to_send,
    messages = [],
    receiving_data,
    transmitting_data,
  } = data;
  return (
    <Window width={500} height={700}>
      <Window.Content scrollable>
        <Section title="Messages">
          {messages.map((message) => (
            <Flex.Item key={message.key}>
              <Box textAlign="center" fontSize="14px">
                <b>{message.sender_name} </b>
                <Button
                  icon="trash"
                  tooltip={'Delete this message'}
                  onClick={() =>
                    act('remove_message', { message_to_remove: message })
                  }
                />
              </Box>
              <Divider />
              <Box>{message.message}</Box>
              <br />
              <BlockQuote>Time Recieved: {message.timestamp}</BlockQuote>
            </Flex.Item>
          ))}
        </Section>
        <Section title="Settings">
          <LabeledList>
            <LabeledList.Item label={'Display Name'}>
              <Input
                value={name_to_send}
                onInput={(e, value) => act('change_name', { new_name: value })}
                width="100%"
              />
            </LabeledList.Item>
            <LabeledList.Item label={'Message'}>
              <Input
                value={text_to_send}
                onInput={(e, value) =>
                  act('change_message', { new_message: value })
                }
                width="100%"
              />
            </LabeledList.Item>
            <LabeledList.Item label="Toggle transmitting">
              <Button
                fluid
                onClick={() => act('toggle_transmitting', {})}
                color={transmitting_data ? 'green' : 'red'}
              >
                {transmitting_data ? 'True' : 'False'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Toggle receiving">
              <Button
                fluid
                onClick={() => act('toggle_receiving', {})}
                color={receiving_data ? 'green' : 'red'}
              >
                {receiving_data ? 'True' : 'False'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
