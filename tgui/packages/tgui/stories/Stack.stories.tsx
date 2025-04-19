/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { Box, Section, Stack } from 'tgui-core/components';

export const meta = {
  title: 'Stack',
  render: () => <Story />,
};

function Filler() {
  return (
    <Box inline width={1} height={1}>
      A
    </Box>
  );
}

function SmallStackItems() {
  return (
    <>
      <Stack.Item>
        <Filler />
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>
        <Filler />
      </Stack.Item>
    </>
  );
}

function Story() {
  return (
    <Section fill>
      <Stack fill className="debug-layout">
        <SmallStackItems />
        <Stack.Item grow>
          <Stack fill vertical zebra>
            <SmallStackItems />
            <Stack.Item>
              <Stack fill>
                <SmallStackItems />
                <Stack.Item grow />
                <SmallStackItems />
                <SmallStackItems />
              </Stack>
            </Stack.Item>
            <Stack.Item grow />
            <SmallStackItems />
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
