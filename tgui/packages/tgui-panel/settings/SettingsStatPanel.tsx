import { toFixed } from 'common/math';
import { capitalize } from 'common/string';
import { useDispatch, useSelector } from 'tgui/backend';
import {
  Button,
  LabeledList,
  Section,
  Slider,
  Stack,
  NoticeBox,
} from 'tgui/components';

import { updateSettings } from './actions';
import { selectSettings } from './selectors';

const TabsViews = ['default', 'classic', 'nowrap'];

export function SettingsStatPanel(props) {
  const { statLinked, statFontSize, statTabsStyle } =
    useSelector(selectSettings);
  const dispatch = useDispatch();

  return (
    <Stack fill vertical>
      <Section fill>
        <Stack fill vertical>
          <Stack.Item grow>
            <LabeledList>
              <LabeledList.Item label="Tabs" verticalAlign="middle">
                <Stack.Item grow>
                  {TabsViews.map((view) => (
                    <Button
                      key={view}
                      color="transparent"
                      selected={statTabsStyle === view}
                      onClick={() =>
                        dispatch(updateSettings({ statTabsStyle: view }))
                      }
                    >
                      {capitalize(view)}
                    </Button>
                  ))}
                </Stack.Item>
              </LabeledList.Item>
              <LabeledList.Item label="Font size">
                <Stack.Item grow>
                  {statLinked ? (
                    <NoticeBox color="red" fontSize={0.95}>
                      Unlink Stat Panel from chat!
                    </NoticeBox>
                  ) : (
                    <Slider
                      width="100%"
                      step={1}
                      stepPixelSize={20}
                      minValue={8}
                      maxValue={32}
                      value={statFontSize}
                      unit="px"
                      format={(value) => toFixed(value)}
                      onChange={(e, value) =>
                        dispatch(updateSettings({ statFontSize: value }))
                      }
                    />
                  )}
                </Stack.Item>
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item textAlign="center">
            <Button
              fluid
              icon="link"
              color={statLinked ? 'bad' : 'good'}
              onClick={() =>
                dispatch(updateSettings({ statLinked: !statLinked }))
              }
            >
              {statLinked ? 'Unlink from chat' : 'Link to chat'}
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
    </Stack>
  );
}
