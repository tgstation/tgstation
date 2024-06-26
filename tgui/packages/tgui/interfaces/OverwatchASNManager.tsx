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
  a_ckey: string;
  timestamp: string;
  asn: string;
};

type Data = {
  displayData: Array<OverwatchDisplayData>;
};

export const OverwatchASNManager = (props) => {
  const { act, data } = useBackend<Data>();
  const { displayData } = data;
  const [inputIP, setinputIP] = useLocalState('inputIPkey', '');
  return (
    <Window width={600} height={500} title="Overwatch ASN Panel" theme="admin">
      <Window.Content scrollable>
        <Section title="Add ASN to Overwatch Banlist">
          <Flex>
            <Flex.Item grow>
              <Input
                value={inputIP}
                placeholder="Input IP address"
                fluid
                onChange={(e, value) => {
                  setinputIP(value);
                }}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                color="green"
                content="OK"
                icon="check"
                onClick={() => {
                  if (inputIP === '') return;
                  act('asn_add_entry', {
                    ip: inputIP,
                  });
                  setinputIP('');
                }}
              />
            </Flex.Item>
          </Flex>
        </Section>
        <Section title={'ASN Ban Entries: ' + (displayData?.length || 0)}>
          {((displayData?.length || 0) !== 0 && (
            <Stack vertical>
              <Stack.Item>
                <Flex justify="space-evenly">
                  <Flex.Item grow>
                    <Box> ASN </Box>
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
                          {displayRow.asn}
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
                              act('asn_remove_entry', {
                                asn: displayRow.asn,
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
          )) || <NoticeBox fluid> No ASN Ban entries to display. </NoticeBox>}
        </Section>
      </Window.Content>
    </Window>
  );
};
