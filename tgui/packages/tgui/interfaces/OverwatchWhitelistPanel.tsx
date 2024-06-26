import { useBackend, useLocalState } from '../backend';
import {
  Section,
  Flex,
  Stack,
  Button,
  Box,
  Input,
  NoticeBox,
} from '../components';
import { Window } from '../layouts';

type OverwatchDisplayData = {
  ckey: string;
  timestamp: string;
  a_ckey: string;
};

type Data = {
  displayData: Array<OverwatchDisplayData>;
};

export const OverwatchWhitelistPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { displayData } = data;
  const [inputWLCkey, setInputWLCkey] = useLocalState('inputWLCkey', '');
  return (
    <Window
      width={600}
      height={500}
      title="Overwatch Whitelist Panel"
      theme="admin"
    >
      <Window.Content scrollable>
        <Section title="Add CKEY to Overwatch Whitelist">
          <Flex>
            <Flex.Item grow>
              <Input
                value={inputWLCkey}
                placeholder="Input ckey"
                fluid
                onChange={(e, value) => {
                  setInputWLCkey(value);
                }}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                color="green"
                content="OK"
                icon="check"
                onClick={() => {
                  if (inputWLCkey === '') return;
                  act('wl_add_ckey', {
                    ckey: inputWLCkey,
                  });
                  setInputWLCkey('');
                }}
              />
            </Flex.Item>
          </Flex>
        </Section>
        <Section title={'Whitelist Entries: ' + (displayData?.length || 0)}>
          {((displayData?.length || 0) !== 0 && (
            <Stack vertical>
              <Stack.Item>
                <Flex justify="space-evenly">
                  <Flex.Item grow>
                    <Box> CKEY </Box>
                  </Flex.Item>
                  <Flex.Item grow>
                    <Box> TIMESTAMP </Box>
                  </Flex.Item>
                  <Flex.Item grow>
                    <Box> ADMIN CKEY </Box>
                  </Flex.Item>
                  <Flex.Item width="4%" />
                </Flex>
              </Stack.Item>
              <Stack.Divider />
              {displayData.map((displayRow, index) => {
                return (
                  <Stack.Item key={index}>
                    <Box>
                      <Flex justify="space-around" align="center">
                        <Flex.Item grow order={1}>
                          {displayRow.ckey}
                        </Flex.Item>
                        <Flex.Item grow order={2}>
                          {displayRow.timestamp}
                        </Flex.Item>
                        <Flex.Item grow order={3}>
                          {displayRow.a_ckey}
                        </Flex.Item>
                        <Flex.Item order={4}>
                          <Button
                            icon="trash"
                            color="red"
                            onClick={() => {
                              act('wl_remove_entry', {
                                ckey: displayRow.ckey,
                              });
                            }}
                          />
                        </Flex.Item>
                      </Flex>
                    </Box>
                  </Stack.Item>
                );
              })}
            </Stack>
          )) || <NoticeBox fluid> No whitelist entries to display. </NoticeBox>}
        </Section>
      </Window.Content>
    </Window>
  );
};
