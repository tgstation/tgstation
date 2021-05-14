import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dimmer, Icon, Section, Stack } from '../components';
import { Window } from '../layouts';

export const MatrixMathTester = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    broken,
    moving,
    destinations,
  } = data;
  return (
    <Window
      title="Nobody Wants to Learn Matrix Math"
      width={300}
      height={300}>
      <Window.Content>
        <Section>
          <Stack vertical>
            <Stack.Item>
              <Stack fill>
                <Stack.Item grow>
                  a
                </Stack.Item>
                <Stack.Item grow>
                  d
                </Stack.Item>
                <Stack.Item grow>
                  0
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack fill>
                <Stack.Item grow>
                  b
                </Stack.Item>
                <Stack.Item grow>
                  e
                </Stack.Item>
                <Stack.Item grow>
                  0
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack fill>
                <Stack.Item grow>
                  c
                </Stack.Item>
                <Stack.Item grow>
                  f
                </Stack.Item>
                <Stack.Item grow>
                  1
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
