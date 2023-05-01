import { BooleanLike } from '../../common/react';
import { useBackend } from '../backend';
import { Button, ColorBox, Input, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

type EyeColorData = {
  mode: BooleanLike;
  hasOwner: BooleanLike;
  left: string;
  right: string;
};

type HighLuminosityEyesMenuData = {
  eyeColor: EyeColorData;
  lightColor: string;
  range: number;
};

const LightColorDisplay = (props, context) => {
  const { act, data } = useBackend<HighLuminosityEyesMenuData>(context);
  const { lightColor } = data;
  const light = 0;
  return (
    <Section title="Color">
      <LabeledList>
        <LabeledList.Item label="Light Color">
          <ColorBox color={lightColor} />{' '}
          <Button
            icon="palette"
            onClick={() => act('pick_color', { to_update: light })}
            tooltip="Brings up a color pick window to change the light color."
          />
          <Button
            icon="dice"
            onClick={() => act('random_color', { to_update: light })}
            tooltip="Randomizes the light color."
          />
          <Input
            value={lightColor}
            width={6}
            maxLength={7}
            onChange={(_, value) =>
              act('enter_color', { new_color: value, to_update: light })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const RangeDisplay = (props, context) => {
  const { act, data } = useBackend<HighLuminosityEyesMenuData>(context);
  const { range } = data;
  return (
    <Section title="Range">
      <LabeledList>
        <LabeledList.Item label="Light Range">
          <Button
            icon="minus-square-o"
            onClick={() => act('set_range', { new_range: range - 1 })}
            tooltip="Reduces the light range."
          />
          <Button
            icon="plus-square-o"
            onClick={() => act('set_range', { new_range: range + 1 })}
            tooltip="Increases the light range."
          />
          <NumberInput
            animated
            width="35px"
            step={1}
            stepPixelSize={5}
            value={range}
            minValue={0}
            maxValue={5}
            onDrag={(e, value) =>
              act('set_range', {
                new_range: value,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const EyeColorDisplay = (props, context) => {
  const { act, data } = useBackend<HighLuminosityEyesMenuData>(context);
  const { eyeColor } = data;
  const left = 1;
  const right = 2;
  return (
    <Section title="Eye Color">
      <LabeledList>
        <LabeledList.Item label="Matches Light Color">
          <Button.Checkbox
            checked={eyeColor.mode}
            onClick={() => act('toggle_eye_color')}
            tooltip="Toggle the eye color mode."
          />
        </LabeledList.Item>
      </LabeledList>
      {!eyeColor.mode && (
        <LabeledList>
          &nbsp;
          <LabeledList.Item label="Left Eye">
            <ColorBox color={eyeColor.left} />{' '}
            <Button
              icon="palette"
              onClick={() => act('pick_color', { to_update: left })}
              tooltip="Brings up a color pick window to change the light color."
            />
            <Button
              icon="dice"
              onClick={() => act('random_color', { to_update: left })}
              tooltip="Randomizes the light color."
            />
            <Input
              value={eyeColor.left}
              width={6}
              maxLength={7}
              onChange={(_, value) =>
                act('enter_color', { new_color: value, to_update: left })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label="Right Eye">
            <ColorBox color={eyeColor.right} />{' '}
            <Button
              icon="palette"
              onClick={() => act('pick_color', { to_update: right })}
              tooltip="Brings up a color pick window to change the light color."
            />
            <Button
              icon="dice"
              onClick={() => act('random_color', { to_update: right })}
              tooltip="Randomizes the light color."
            />
            <Input
              value={eyeColor.right}
              width={6}
              maxLength={7}
              onChange={(_, value) =>
                act('enter_color', { new_color: value, to_update: right })
              }
            />
          </LabeledList.Item>
        </LabeledList>
      )}
    </Section>
  );
};

export const HighLuminosityEyesMenu = (props, context) => {
  const { act, data } = useBackend<HighLuminosityEyesMenuData>(context);
  const { eyeColor } = data;
  return (
    <Window
      title="High Luminosity Eyes"
      width={262}
      height={eyeColor.hasOwner ? (eyeColor.mode ? 257 : 335) : 188}>
      <Window.Content scrollable>
        <LightColorDisplay />
        <RangeDisplay />
        {!!eyeColor.hasOwner && <EyeColorDisplay />}
      </Window.Content>
    </Window>
  );
};
