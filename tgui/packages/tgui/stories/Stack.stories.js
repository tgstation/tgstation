/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { Box, Section, Stack } from '../components';

export const meta = {
  title: 'Stack',
  render: () => <Story />,
};

const Filler = () => (
  <Box inline width={1} height={1}>
    A
  </Box>
);

const SmallStackItems = () => (
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

const Story = (props, context) => {
  return (
    <Section fill>
      <Stack fill className="debug-layout">
        <SmallStackItems />
        <Stack.Item grow={1}>
          <Stack fill vertical>
            <SmallStackItems />
            <Stack.Item>
              <Stack fill>
                <SmallStackItems />
                <Stack.Item grow={1} />
                <SmallStackItems />
                <SmallStackItems />
              </Stack>
            </Stack.Item>
            <Stack.Item grow={1} />
            <SmallStackItems />
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
