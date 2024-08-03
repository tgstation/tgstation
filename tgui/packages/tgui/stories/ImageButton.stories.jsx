/**
 * @file
 * @copyright 2024 Aylong (https://github.com/AyIong)
 * @license MIT
 */

import { useState } from 'react';
import {
  Button,
  LabeledList,
  ImageButton,
  Input,
  Slider,
  Section,
  Stack,
} from '../components';

export const meta = {
  title: 'ImageButton',
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
  'primary',
];

const COLORS_STATES = ['good', 'average', 'bad', 'black', 'white'];

const Story = (props, context) => {
  const [fluid1, setFluid1] = useState(true);
  const [fluid2, setFluid2] = useState(false);
  const [fluid3, setFluid3] = useState(false);
  const [disabled, setDisabled] = useState(false);
  const [selected, setSelected] = useState(false);
  const [addImage, setAddImage] = useState(false);
  const [base64, setbase64] = useState('');
  const [dmIcon, setDmIcon] = useState('');
  const [dmIconState, setDmIconState] = useState('');
  const [title, setTitle] = useState('Image Button');
  const [content, setContent] = useState('You can put anything in there');
  const [imageSize, setImageSize] = useState(64);

  return (
    <>
      <Section>
        <Stack>
          <Stack.Item basis="50%">
            <LabeledList>
              {addImage ? (
                <>
                  <LabeledList.Item label="base64">
                    <Input
                      value={base64}
                      onInput={(e, value) => setbase64(value)}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="dmIcon">
                    <Input
                      value={dmIcon}
                      onInput={(e, value) => setDmIcon(value)}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="dmIconState">
                    <Input
                      value={dmIconState}
                      onInput={(e, value) => setDmIconState(value)}
                    />
                  </LabeledList.Item>
                </>
              ) : (
                <>
                  <LabeledList.Item label="Title">
                    <Input
                      value={title}
                      onInput={(e, value) => setTitle(value)}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Content">
                    <Input
                      value={content}
                      onInput={(e, value) => setContent(value)}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Image Size">
                    <Slider
                      width={10}
                      value={imageSize}
                      minValue={0}
                      maxValue={256}
                      step={1}
                      onChange={(e, value) => setImageSize(value)}
                    />
                  </LabeledList.Item>
                </>
              )}
            </LabeledList>
          </Stack.Item>
          <Stack.Item basis="50%">
            <Stack fill vertical>
              <Stack.Item grow>
                <Button.Checkbox
                  fluid
                  checked={fluid1}
                  onClick={() => setFluid1(!fluid1)}
                >
                  Fluid
                </Button.Checkbox>
              </Stack.Item>
              <Stack.Item grow>
                <Button.Checkbox
                  fluid
                  checked={disabled}
                  onClick={() => setDisabled(!disabled)}
                >
                  Disabled
                </Button.Checkbox>
              </Stack.Item>
              <Stack.Item grow>
                <Button.Checkbox
                  fluid
                  checked={selected}
                  onClick={() => setSelected(!selected)}
                >
                  Selected
                </Button.Checkbox>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
        <Stack.Item mt={1}>
          <ImageButton
            m={!fluid1 && 0}
            fluid={fluid1}
            base64={base64}
            dmIcon={dmIcon}
            dmIconState={dmIconState}
            imageSize={imageSize}
            title={title}
            tooltip={!fluid1 && content}
            disabled={disabled}
            selected={selected}
            buttonsAlt={fluid1}
            buttons={
              <Button
                fluid
                compact={!fluid1}
                color={!fluid1 && 'transparent'}
                selected={addImage}
                onClick={() => setAddImage(!addImage)}
              >
                Add Image
              </Button>
            }
          >
            {content}
          </ImageButton>
        </Stack.Item>
      </Section>
      <Section
        title="Color States"
        buttons={
          <Button.Checkbox checked={fluid2} onClick={() => setFluid2(!fluid2)}>
            Fluid
          </Button.Checkbox>
        }
      >
        {COLORS_STATES.map((color) => (
          <ImageButton
            key={color}
            fluid={fluid2}
            color={color}
            imageSize={fluid2 ? 24 : 48}
          >
            {color}
          </ImageButton>
        ))}
      </Section>
      <Section
        title="Available Colors"
        buttons={
          <Button.Checkbox checked={fluid3} onClick={() => setFluid3(!fluid3)}>
            Fluid
          </Button.Checkbox>
        }
      >
        {COLORS_SPECTRUM.map((color) => (
          <ImageButton
            key={color}
            fluid={fluid3}
            color={color}
            imageSize={fluid3 ? 24 : 48}
          >
            {color}
          </ImageButton>
        ))}
      </Section>
    </>
  );
};
