import { toFixed } from 'common/math';
import { useLocalState } from 'tgui/backend';
import { Button, Flex, LabeledList, NumberInput, Section } from 'tgui/components';
import { Pane } from 'tgui/layouts';
import { useDispatch, useSelector } from 'tgui/store';
import { Chat } from './chat';
import { selectSettings, updateSettings } from './settings';
import { selectPing } from './ping';

export const PanelRoot = (props, context) => {
  const [showSettings, setShowSettings] = useLocalState(
    context, 'showSettings', false);
  const { fontSize, lineHeight } = useSelector(context, selectSettings);
  const ping = useSelector(context, selectPing);
  const dispatch = useDispatch(context);
  return (
    <Pane fontSize={fontSize + 'pt'}>
      <Pane.Content>
        <Flex
          direction="column"
          height="100%">
          <Flex.Item>
            <Section m={0}>
              <Flex m={-1} align="baseline">
                <Flex.Item mx={1} grow={1}>
                  <Button selected>
                    Main
                  </Button>
                </Flex.Item>
                <Flex.Item mx={1}>
                  <Button color="transparent">
                    {ping.time || '--'} ms
                  </Button>
                </Flex.Item>
                <Flex.Item mx={1}>
                  <Button
                    icon="cog"
                    onClick={() => setShowSettings(!showSettings)} />
                </Flex.Item>
              </Flex>
            </Section>
          </Flex.Item>
          {showSettings && (
            <Flex.Item mt={1}>
              <Settings />
            </Flex.Item>
          )}
          <Flex.Item mt={1} grow={1} basis={0}>
            <Section fill overflowY="scroll">
              <Chat lineHeight={lineHeight} />
            </Section>
          </Flex.Item>
        </Flex>
      </Pane.Content>
    </Pane>
  );
};

export const Settings = (props, context) => {
  const { fontSize, lineHeight } = useSelector(context, selectSettings);
  const dispatch = useDispatch(context);
  return (
    <Section title="Settings">
      <LabeledList>
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
