/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { Box, Button, Section } from 'tgui-core/components';

export const meta = {
  title: 'Button',
  render: () => <Story />,
};

const COLORS_SPECTRUM = [
  'red',
  'orange',
  'yellow',
  'olive',
  'green',
  'teal',
  'blue',
  'violet',
  'purple',
  'pink',
  'brown',
  'grey',
];

const COLORS_STATES = ['good', 'average', 'bad', 'black', 'white'];

const Story = (props) => {
  return (
    <Section>
      <Box mb={1}>
        <Button content="Simple" />
        <Button selected content="Selected" />
        <Button altSelected content="Alt Selected" />
        <Button disabled content="Disabled" />
        <Button color="transparent" content="Transparent" />
        <Button icon="cog" content="Icon" />
        <Button icon="power-off" />
        <Button fluid content="Fluid" />
        <Button
          my={1}
          lineHeight={2}
          minWidth={15}
          textAlign="center"
          content="With Box props"
        />
      </Box>
      <Box mb={1}>
        {COLORS_STATES.map((color) => (
          <Button key={color} color={color} content={color} />
        ))}
        <br />
        {COLORS_SPECTRUM.map((color) => (
          <Button key={color} color={color} content={color} />
        ))}
        <br />
        {COLORS_SPECTRUM.map((color) => (
          <Box inline mx="7px" key={color} color={color}>
            {color}
          </Box>
        ))}
      </Box>
    </Section>
  );
};
