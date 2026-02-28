import {
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import { capitalize } from 'tgui-core/string';
import { useSettings } from './use-settings';

const tabViews = ['default', 'classic', 'scrollable'];

function LinkedToChat() {
  return <NoticeBox color="red">Unlink Stat Panel from chat!</NoticeBox>;
}

export function SettingsStatPanel(props) {
  const { settings, updateSettings } = useSettings();
  const { statLinked, statFontSize, statTabsStyle } = settings;

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Tabs" verticalAlign="middle">
              {tabViews.map((view) => (
                <Button
                  key={view}
                  color="transparent"
                  selected={statTabsStyle === view}
                  onClick={() => updateSettings({ statTabsStyle: view })}
                >
                  {capitalize(view)}
                </Button>
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Font size">
              <Stack.Item grow>
                {statLinked ? (
                  <LinkedToChat />
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
                      updateSettings({ statFontSize: value })
                    }
                  />
                )}
              </Stack.Item>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Divider mt={2.5} />
        <Stack.Item textAlign="center">
          <Button
            fluid
            icon={statLinked ? 'unlink' : 'link'}
            color={statLinked ? 'bad' : 'good'}
            onClick={() => updateSettings({ statLinked: !statLinked })}
          >
            {statLinked ? 'Unlink from chat' : 'Link to chat'}
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
