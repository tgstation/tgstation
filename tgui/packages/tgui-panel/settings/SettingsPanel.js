import { toFixed } from 'common/math';
import { Dropdown, LabeledList, NumberInput, Section, Knob } from 'tgui/components';
import { useDispatch, useSelector } from 'tgui/store';
import { updateSettings } from './actions';
import { selectSettings } from './selectors';

const THEMES = ['light', 'dark'];

export const SettingsPanel = (props, context) => {
  const {
    theme,
    fontSize,
    lineHeight,
  } = useSelector(context, selectSettings);
  const dispatch = useDispatch(context);
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Theme">
          <Dropdown
            selected={theme}
            options={THEMES}
            onSelected={value => dispatch(updateSettings({
              theme: value,
            }))} />
        </LabeledList.Item>
        <LabeledList.Item label="Font size">
          <NumberInput
            width="4em"
            step={1}
            stepPixelSize={10}
            minValue={8}
            maxValue={36}
            value={fontSize}
            unit="pt"
            format={value => toFixed(value)}
            onChange={(e, value) => dispatch(updateSettings({
              fontSize: value,
            }))} />
        </LabeledList.Item>
        <LabeledList.Item label="Line height">
          <NumberInput
            width="4em"
            step={0.01}
            stepPixelSize={2}
            minValue={1}
            maxValue={4}
            value={lineHeight}
            format={value => toFixed(value, 2)}
            onChange={(e, value) => dispatch(updateSettings({
              lineHeight: value,
            }))} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
