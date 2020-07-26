import { toFixed } from 'common/math';
import { useLocalState } from 'tgui/backend';
import { Box, Button, Flex, LabeledList, NumberInput, Section, Tabs } from 'tgui/components';
import { Pane } from 'tgui/layouts';
import { useDispatch, useSelector } from 'tgui/store';
import { changeChatPage, Chat, selectChatPages, selectCurrentChatPage } from './chat';
import { PingIndicator } from './ping';
import { selectSettings, updateSettings } from './settings';

export const PanelRoot = (props, context) => {
  const [showSettings, setShowSettings] = useLocalState(
    context, 'showSettings', false);
  const { fontSize, lineHeight } = useSelector(context, selectSettings);
  const pages = useSelector(context, selectChatPages);
  const currentPage = useSelector(context, selectCurrentChatPage);
  const dispatch = useDispatch(context);
  return (
    <Pane fontSize={fontSize + 'pt'}>
      <Flex
        direction="column"
        height="100%">
        <Flex.Item>
          <Section fitted>
            <Flex align="center">
              <Flex.Item mx={1} grow={1}>
                <Tabs textAlign="center">
                  {pages.map(page => (
                    <Tabs.Tab
                      key={page.id}
                      selected={page === currentPage}
                      rightSlot={(
                        <Box fontSize="0.9em">
                          {page.count}
                        </Box>
                      )}
                      onClick={() => dispatch(changeChatPage(page))}>
                      {page.name}
                    </Tabs.Tab>
                  ))}
                </Tabs>
              </Flex.Item>
              <Flex.Item mx={1}>
                <PingIndicator />
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
          <Flex.Item position="relative" grow={1}>
            <Pane.Content scrollable>
              <Settings />
            </Pane.Content>
          </Flex.Item>
        ) || (
          <Flex.Item mt={1} grow={1}>
            <Section fill fitted position="relative">
              <Pane.Content scrollable>
                <Chat lineHeight={lineHeight} />
              </Pane.Content>
            </Section>
          </Flex.Item>
        )}
      </Flex>
    </Pane>
  );
};

export const Settings = (props, context) => {
  const { fontSize, lineHeight } = useSelector(context, selectSettings);
  const dispatch = useDispatch(context);
  return (
    <Section>
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
