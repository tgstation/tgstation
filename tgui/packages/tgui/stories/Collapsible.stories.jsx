/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { Button, Collapsible, Section } from 'tgui-core/components';
import { BoxWithSampleText } from './common';

export const meta = {
  title: 'Collapsible',
  render: () => <Story />,
};

const Story = (props) => {
  return (
    <Section>
      <Collapsible title="Collapsible Demo" buttons={<Button icon="cog" />}>
        <BoxWithSampleText />
      </Collapsible>
    </Section>
  );
};
