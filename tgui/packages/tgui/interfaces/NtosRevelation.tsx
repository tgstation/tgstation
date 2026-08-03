import {
  BlockQuote,
  Box,
  Button,
  Input,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  armed: BooleanLike;
  bluescreen: BooleanLike;
};

export const NtosRevelation = (props) => {
  const { act, data } = useBackend<Data>();
  const { armed, bluescreen } = data;

  return (
    <NtosWindow width={400} height={250}>
      <NtosWindow.Content>
        {!!bluescreen && <BlueScreen />}
        {!bluescreen && (
          <Section fill>
            <Stack fill direction="column">
              <Stack.Item>
                <Stack>
                  <Stack.Item style={{ lineHeight: '1.5em' }}>
                    Display Name:
                  </Stack.Item>
                  <Stack.Item grow>
                    <Input
                      fluid
                      onChange={(value) =>
                        act('PRG_obfuscate', {
                          new_name: value,
                        })
                      }
                      mb={1}
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <BlockQuote>
                  Upon arming the program, opening it again will wipe the
                  device. Make sure all sensitive data isn't backed up.
                </BlockQuote>
              </Stack.Item>
              <Stack.Item mt="auto">
                <Stack direction="column">
                  <Stack.Item>
                    <Button
                      fluid
                      style={{
                        textAlign: 'center',
                        fontSize: '20px',
                      }}
                      color={armed ? 'bad' : 'average'}
                      onClick={() => act('PRG_arm')}
                    >
                      {armed ? 'DISARM' : 'ARM'}
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button.Confirm
                      fluid
                      bold
                      confirmContent="ARE YOU SURE?"
                      textAlign="center"
                      color="bad"
                      disabled={!armed}
                      onClick={() => act('PRG_activate')}
                      style={{ marginBottom: '0px' }}
                    >
                      ACTIVATE NOW
                    </Button.Confirm>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const BlueScreen = () => {
  return (
    <Box
      width="100%"
      height="100%"
      backgroundColor="#0000aa"
      color="#ffffff"
      fontFamily="'Courier New', monospace"
      py={2}
      px={3}
    >
      <Box bold fontSize="16px">
        System Failure
      </Box>
      <Box mt={2}>
        A fatal exception 0xE has occurred at 0028:C0011E36 in VXD_SYSPURGE(01)
        + 00002B9C. The current application will be terminated.
      </Box>
      <Box mt={2}>
        * Press any key to terminate the current application.
        <br />
        You will lose any unsaved information in all applications.
      </Box>
      <Box mt={4} italic>
        Press any key to continue...
      </Box>
    </Box>
  );
};
