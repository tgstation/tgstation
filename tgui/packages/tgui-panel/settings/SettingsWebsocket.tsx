import {
  Button,
  Input,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import { chatRenderer } from 'tgui-panel/chat/renderer';
import {
  wsDisconnect,
  wsReconnect,
  wsUpdate,
} from 'tgui-panel/websocket/helpers';
import { useSettings } from './use-settings';

export function SettingsWebsocket(props) {
  const { settings, updateSettings } = useSettings();
  const { statLinked, statFontSize, statTabsStyle } = settings;

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Websocket Client">
              <Button.Checkbox
                checked={settings.websocketEnabled}
                color="transparent"
                onClick={() => {
                  const websocketEnabled = !settings.websocketEnabled;
                  updateSettings({ websocketEnabled });
                  wsUpdate(websocketEnabled);
                }}
              >
                Enabled
              </Button.Checkbox>
              <Button
                icon={'question'}
                onClick={() => {
                  chatRenderer.processBatch([
                    {
                      html:
                        '<div class="boxed_message"><b>Websocket Information</b><br><span class="notice">' +
                        'Quick rundown. This connects to the specified websocket server, and ' +
                        'forwards all data/payloads from the server, to the websocket. Allowing ' +
                        'you to have in-game actions reflect in other services, or the real ' +
                        'world, (ex. Reactive RGB, haptics, play effects/animations in vtubing ' +
                        'software, etc). You can find more information ' +
                        '<a href="https://github.com/tgstation/tgstation/pull/96241">here in the pull request.</a></span></div>',
                    },
                  ]);
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Websocket Server">
              <Stack.Item>
                <Stack>
                  <Input
                    width={'100%'}
                    value={settings.websocketServer}
                    placeholder="localhost:4242"
                    onChange={(value) =>
                      updateSettings({
                        websocketServer: value,
                      })
                    }
                  />
                </Stack>
              </Stack.Item>
            </LabeledList.Item>
            <LabeledList.Item label="Websocket Controls">
              <Button
                ml={0.5}
                icon={'globe'}
                color={'good'}
                onClick={wsReconnect}
              >
                Force Reconnect
              </Button>
              <Button
                ml={0.5}
                icon={'globe'}
                color={'bad'}
                onClick={wsDisconnect}
              >
                Force Disconnect
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
