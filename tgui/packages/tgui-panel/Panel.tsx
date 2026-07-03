/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useAtom, useAtomValue } from 'jotai';
import { Pane } from 'tgui/layouts';
import { Button, Section, Stack } from 'tgui-core/components';
import { visibleAtom } from './audio/atoms';
import { NowPlayingWidget } from './audio/NowPlayingWidget';
import { ChatPanel } from './chat/ChatPanel';
import { ChatTabs } from './chat/ChatTabs';
import { useChatPersistence } from './chat/use-chat-persistence';
import { emotesAtom } from './emotes/atom'; // BANDASTATION ADD  - Emote Panel
import { EmotePanel } from './emotes/EmotePanel'; // BANDASTATION ADD  - Emote Panel
import { gameAtom } from './game/atoms';
import { useKeepAlive } from './game/use-keep-alive';
import { Notifications } from './Notifications';
import { PingIndicator } from './ping/PingIndicator';
import { ReconnectButton } from './reconnect';
import { settingsVisibleAtom } from './settings/atoms';
import { SettingsPanel } from './settings/SettingsPanel';
import { useSettings } from './settings/use-settings';

export function Panel(props) {
  const [emotes, setEmotes] = useAtom(emotesAtom); // BANDASTATION ADD  - Emote Panel
  const [audioVisible, setAudioVisible] = useAtom(visibleAtom);
  const game = useAtomValue(gameAtom);
  const { settings } = useSettings();
  const [settingsVisible, setSettingsVisible] = useAtom(settingsVisibleAtom);

  // BANDASTATION ADD  - Emote Panel
  const toggleEmotes = () =>
    setEmotes((prev) => ({
      ...prev,
      visible: !prev.visible,
    }));

  useChatPersistence();
  useKeepAlive();

  return (
    <Pane theme={settings.theme} canSuspend={false}>
      <Stack fill vertical>
        <Stack.Item>
          <Section fitted>
            <Stack mr={1} align="center">
              <Stack.Item grow>
                <ChatTabs />
              </Stack.Item>
              <Stack.Item>
                <PingIndicator />
              </Stack.Item>
              {/* BANDASTATION ADD START - Emote Panel */}
              <Stack.Item>
                <Button
                  color="grey"
                  selected={emotes.visible}
                  icon="face-grin-beam"
                  tooltip="Панель эмоций"
                  tooltipPosition="bottom-start"
                  onClick={toggleEmotes}
                />
              </Stack.Item>
              {/* BANDASTATION ADD END - Emote Panel */}
              <Stack.Item>
                <Button
                  color="grey"
                  selected={audioVisible}
                  icon="music"
                  tooltip="Проигрыватель музыки"
                  tooltipPosition="bottom-start"
                  onClick={() => setAudioVisible((v) => !v)}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon={settingsVisible ? 'times' : 'cog'}
                  selected={settingsVisible}
                  tooltip={
                    settingsVisible ? 'Закрыть настройки' : 'Открыть настройки'
                  }
                  tooltipPosition="bottom-start"
                  onClick={() => setSettingsVisible((v) => !v)}
                />
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
        {/* BANDASTATION ADD START - Emote Panel */}
        {emotes.visible && (
          <Stack.Item>
            <Section>
              <EmotePanel />
            </Section>
          </Stack.Item>
        )}
        {/* BANDASTATION ADD END - Emote Panel */}
        {audioVisible && (
          <Stack.Item>
            <Section>
              <NowPlayingWidget />
            </Section>
          </Stack.Item>
        )}
        {settingsVisible && (
          <Stack.Item>
            <SettingsPanel />
          </Stack.Item>
        )}
        <Stack.Item grow>
          <Section fill fitted position="relative">
            <Pane.Content scrollable id="chat-pane">
              <ChatPanel lineHeight={settings.lineHeight} />
            </Pane.Content>
            <Notifications>
              {game.connectionLostAt && (
                <Notifications.Item rightSlot={<ReconnectButton />}>
                  Либо вы находитесь AFK, испытываете задержку, либо соединение
                  прервано.
                </Notifications.Item>
              )}
              {game.roundRestartedAt && (
                <Notifications.Item>
                  Соединение было закрыто, так как сервер перезапускается.
                  Пожалуйста, подождите, пока вы автоматически восстановите
                  подключение.
                </Notifications.Item>
              )}
            </Notifications>
          </Section>
        </Stack.Item>
      </Stack>
    </Pane>
  );
}
