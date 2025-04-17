/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { Box, Section } from 'tgui-core/components';

export const meta = {
  title: 'Box',
  render: () => <Story />,
};

function Story() {
  return (
    <Section>
      <Box bold>bold</Box>
      <Box italic>italic</Box>
      <Box opacity={0.5}>opacity 0.5</Box>
      <Box opacity={0.25}>opacity 0.25</Box>
      <Box m={2}>m: 2</Box>
      <Box textAlign="left">left</Box>
      <Box textAlign="center">center</Box>
      <Box textAlign="right">right</Box>
    </Section>
  );
}
