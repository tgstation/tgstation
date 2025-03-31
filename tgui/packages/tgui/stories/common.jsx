/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { Box } from 'tgui-core/components';

export const BoxWithSampleText = (props) => {
  return (
    <Box {...props}>
      <Box italic>Jackdaws love my big sphinx of quartz.</Box>
      <Box mt={1} bold>
        The wide electrification of the southern provinces will give a powerful
        impetus to the growth of agriculture.
      </Box>
    </Box>
  );
};
