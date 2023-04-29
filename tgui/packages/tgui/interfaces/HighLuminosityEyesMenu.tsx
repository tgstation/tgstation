import { useBackend } from '../backend';
import { Button, ColorBox, Input, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

type HighLuminosityEyesMenuData = {
  eye_color: EyeColorData;
  range: number;
};

type EyeColorData = {
  right: string;
  left: string;
};

const ColorDisplay = (props, context) => {
  const { act, data } = useBackend<HighLuminosityEyesMenuData>(context);
  const { eye_color } = data;
  return (
    <Section title="Color">
      <LabeledList>
        <LabeledList.Item label="Light Color">
          <ColorBox color={eye_color.right} />{' '}
          <Button
            icon="palette"
            onClick={() => act('pick_color')}
            tooltip="Brings up a color pick window to change the light color."
          />
          <Button
            icon="dice"
            onClick={() => act('random_color')}
            tooltip="Randomizes the light color."
          />
          <Input
            value={eye_color.right}
            width={6}
            maxLength={7}
            onChange={(_, value) => act('enter_color', { new_color: value })}
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

export const HighLuminosityEyesMenu = (props, context) => {
  return (
    <Window title="High Luminosity Eyes" width={262} height={188}>
      <Window.Content scrollable>
        <ColorDisplay />
        <RangeDisplay />
      </Window.Content>
    </Window>
  );
};
