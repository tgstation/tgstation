/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { Blink, Section } from '../components';

export const meta = {
  title: 'Blink',
  render: () => <Story />,
};

const Story = (props) => {
  return (
    <Section>
      <Blink>Blink</Blink>
    </Section>
  );
};
