import { useBackend } from '../backend';
import { toFixed } from 'common/math';
import { Box, Stack, Section, ByondUi, NumberInput, Button } from '../components';
import { Window } from '../layouts';

export const ColorMatrixEditor = (props, context) => {
  const { act, data } = useBackend(context);
  const { mapRef, currentColor } = data;
  const [
    [rr, rg, rb, ra],
    [gr, gg, gb, ga],
    [br, bg, bb, ba],
    [ar, ag, ab, aa],
    [cr, cg, cb, ca],
  ] = currentColor;
  const prefixes = ['r', 'g', 'b', 'a', 'c'];
  return (
    <Window
      title="Color Matrix Editor"
      width={600}
      height={220}>
      <Window.Content>
        <Stack fill>
          <Stack.Item align="center">
            <Stack fill vertical>
              <Stack.Item grow />
              <Stack.Item>
                <Section>
                  <Stack>
                    {[0, 1, 2, 3].map((col, key) => (
                      <Stack.Item key={key}>
                        <Stack vertical>
                          {[0, 1, 2, 3, 4].map((row, key) => (
                            <Stack.Item
                              key={key}>
                              <Box
                                inline
                                textColor="label"
                                width="2.1rem">
                                {`${prefixes[row]}${prefixes[col]}:`}
                              </Box>
                              <NumberInput
                                inline
                                value={currentColor[row*4+col]}
                                step={0.01}
                                width="50px"
                                format={value => toFixed(value, 2)}
                                onDrag={(e, value) => {
                                  let retColor = currentColor;
                                  retColor[row*4+col] = value;
                                  act("transition_color", { color: retColor });
                                }} />
                            </Stack.Item>
                          ))}
                        </Stack>
                      </Stack.Item>
                    ))}
                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item grow />
              <Stack.Item align="left">
                <Button.Confirm
                  content="Confirm"
                  confirmContent="Confirm?"
                  onClick={() => act("confirm")} />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <ByondUi
              height="100%"
              params={{
                id: mapRef,
                type: 'map',
              }} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
