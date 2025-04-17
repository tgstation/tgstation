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

function Story() {
  return (
    <Section>
      <BlockQuote>
        <BoxWithSampleText />
      </BlockQuote>
    </Section>
  );
}
