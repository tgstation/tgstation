/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';

export const meta = {
  title: 'ProgressBar',
  render: () => <Story />,
};

function Story() {
  const [progress, setProgress] = useState(0.5);
  const [color, setColor] = useState('');

  const color_data = color
    ? { color: color }
    : {
        ranges: {
          good: [0.5, Infinity],
          bad: [-Infinity, 0.1],
          average: [0, 0.5],
        } as Record<string, [number, number]>,
      };

  return (
    <Section>
      <ProgressBar {...color_data} minValue={-1} maxValue={1} value={progress}>
        Value: {Number(progress).toFixed(1)}
      </ProgressBar>
      <Box mt={1}>
        <LabeledList>
          <LabeledList.Item label="Adjust value">
            <Button onClick={() => setProgress(progress - 0.1)}>-0.1</Button>
            <Button onClick={() => setProgress(progress + 0.1)}>+0.1</Button>
          </LabeledList.Item>
          <LabeledList.Item label="Override color">
            <Input value={color} onChange={setColor} />
          </LabeledList.Item>
        </LabeledList>
      </Box>
    </Section>
  );
}
