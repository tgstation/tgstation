/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { useState } from 'react';

import { Button, Flex, Section } from '../components';

export const meta = {
  title: 'Flex & Sections',
  render: () => <Story />,
};

const Story = (props) => {
  const [grow, setGrow] = useState(1);
  const [direction, setDirection] = useState('column');
  const [fill, setFill] = useState(true);
  const [hasTitle, setHasTitle] = useState(true);
  return (
    <Flex height="100%" direction="column">
      <Flex.Item mb={1}>
        <Section>
          <Button
            fluid
            onClick={() =>
              setDirection(direction === 'column' ? 'row' : 'column')
            }
          >
            {`Flex direction="${direction}"`}
          </Button>
          <Button fluid onClick={() => setGrow(Number(!grow))}>
            {`Flex.Item grow={${grow}}`}
          </Button>
          <Button fluid onClick={() => setFill(!fill)}>
            {`Section fill={${String(fill)}}`}
          </Button>
          <Button
            fluid
            selected={hasTitle}
            onClick={() => setHasTitle(!hasTitle)}
          >
            {`Section title`}
          </Button>
        </Section>
      </Flex.Item>
      <Flex.Item grow={1}>
        <Flex height="100%" direction={direction}>
          <Flex.Item
            mr={direction === 'row' && 1}
            mb={direction === 'column' && 1}
            grow={grow}
          >
            <Section title={hasTitle && 'Section 1'} fill={fill}>
              Content
            </Section>
          </Flex.Item>
          <Flex.Item grow={grow}>
            <Section title={hasTitle && 'Section 2'} fill={fill}>
              Content
            </Section>
          </Flex.Item>
        </Flex>
      </Flex.Item>
    </Flex>
  );
};
