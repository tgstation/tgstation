/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { BlockQuote, Section } from 'tgui-core/components';
import { BoxWithSampleText } from './common';

export const meta = {
  title: 'BlockQuote',
  render: () => <Story />,
};

const Story = (props) => {
  return (
    <Section>
      <BlockQuote>
        <BoxWithSampleText />
      </BlockQuote>
    </Section>
  );
};
