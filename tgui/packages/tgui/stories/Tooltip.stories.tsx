/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { ComponentProps } from 'react';
import { Box, Button, Floating, Section, Tooltip } from 'tgui-core/components';

export const meta = {
  title: 'Tooltip',
  render: () => <Story />,
};

type Placement = ComponentProps<typeof Floating>['placement'];

const positions = [
  'top',
  'left',
  'right',
  'bottom',
  'bottom-start',
  'bottom-end',
] as Placement[];

function Story() {
  return (
    <Section>
      <Box>
        <Tooltip content="Tooltip text.">
          <Box inline position="relative" mr={1}>
            Box (hover me).
          </Box>
        </Tooltip>
        <Button tooltip="Tooltip text.">Button</Button>
      </Box>
      <Box mt={1}>
        {positions.map((position) => (
          <Button
            key={position}
            color="transparent"
            tooltip="Tooltip text."
            tooltipPosition={position}
          >
            {position}
          </Button>
        ))}
      </Box>
    </Section>
  );
}
