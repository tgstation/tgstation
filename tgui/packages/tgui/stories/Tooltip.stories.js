/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { Box, Button, Section, Tooltip } from '../components';

export const meta = {
  title: 'Tooltip',
  render: () => <Story />,
};

const Story = props => {
  const positions = [
    'top',
    'left',
    'right',
    'bottom',
    'bottom-left',
    'bottom-right',
  ];
  return (
    <Section>
      <Box>
        <Box inline position="relative" mr={1}>
          Box (hover me).
          <Tooltip content="Tooltip text." />
        </Box>
        <Button
          tooltip="Tooltip text."
          content="Button" />
      </Box>
      <Box mt={1}>
        {positions.map(position => (
          <Button
            key={position}
            color="transparent"
            tooltip="Tooltip text."
            tooltipPosition={position}
            content={position} />
        ))}
      </Box>
    </Section>
  );
};
