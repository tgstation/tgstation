/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { useLocalState } from '../backend';
import { Box, DraggableControl, Icon, Input, Knob, LabeledList, NumberInput, Section, Slider } from '../components';

export const meta = {
  title: 'Input',
  render: () => <Story />,
};

const Story = (props, context) => {
  const [number, setNumber] = useLocalState(context, 'number', 0);
  const [text, setText] = useLocalState(context, 'text', 'Sample text');
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Input (onChange)">
          <Input value={text} onChange={(e, value) => setText(value)} />
        </LabeledList.Item>
        <LabeledList.Item label="Input (onInput)">
          <Input value={text} onInput={(e, value) => setText(value)} />
        </LabeledList.Item>
        <LabeledList.Item label="NumberInput (onChange)">
          <NumberInput
            animated
            width="40px"
            step={1}
            stepPixelSize={5}
            value={number}
            minValue={-100}
            maxValue={100}
            onChange={(e, value) => setNumber(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="NumberInput (onDrag)">
          <NumberInput
            animated
            width="40px"
            step={1}
            stepPixelSize={5}
            value={number}
            minValue={-100}
            maxValue={100}
            onDrag={(e, value) => setNumber(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Slider (onDrag)">
          <Slider
            step={1}
            stepPixelSize={5}
            value={number}
            minValue={-100}
            maxValue={100}
            onDrag={(e, value) => setNumber(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Knob (onDrag)">
          <Knob
            inline
            size={1}
            step={1}
            stepPixelSize={2}
            value={number}
            minValue={-100}
            maxValue={100}
            onDrag={(e, value) => setNumber(value)}
          />
          <Knob
            ml={1}
            inline
            bipolar
            size={1}
            step={1}
            stepPixelSize={2}
            value={number}
            minValue={-100}
            maxValue={100}
            onDrag={(e, value) => setNumber(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Rotating Icon">
          <Box inline position="relative">
            <DraggableControl
              value={number}
              minValue={-100}
              maxValue={100}
              dragMatrix={[0, -1]}
              step={1}
              stepPixelSize={5}
              onDrag={(e, value) => setNumber(value)}>
              {(control) => (
                <Box onMouseDown={control.handleDragStart}>
                  <Icon
                    size={4}
                    color="yellow"
                    name="times"
                    rotation={control.displayValue * 4}
                  />
                  {control.inputElement}
                </Box>
              )}
            </DraggableControl>
          </Box>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
