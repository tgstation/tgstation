/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useSelector } from 'common/redux';
import { useLocalState } from 'tgui/backend';
import { Button, Flex, Section } from 'tgui/components';
import { Pane } from 'tgui/layouts';
import { NowPlayingWidget, useAudio } from './audio';
import { ChatPanel, ChatTabs } from './chat';
import { useGame } from './game';
import { Notifications } from './Notifications';
import { PingIndicator } from './ping';
import { SettingsPanel, useSettings } from './settings';

export const Panel = (props, context) => {
  const audio = useAudio(context);
  const settings = useSettings(context);
  const game = useGame(context);
  const [audioOpen, setAudioOpen] = useLocalState(
    context, 'audioOpen', audio.playing);
  const [settingsOpen, setSettingsOpen] = useLocalState(
    context, 'settingsOpen', false);
  if (process.env.NODE_ENV !== 'production') {
    const { useDebug, KitchenSink } = require('tgui/debug');
    const debug = useDebug(context);
    if (debug.kitchenSink) {
      return (
        <KitchenSink panel />
      );
    }
  }
  return (
    <Pane
      theme={settings.theme}
      fontSize={settings.fontSize + 'px'}>
      <Flex
        direction="column"
        height="100%">
        <Flex.Item>
          <Section fitted>
            <Flex mx={0.5} align="center">
              <Flex.Item mx={0.5} grow={1}>
                <ChatTabs />
              </Flex.Item>
              <Flex.Item mx={0.5}>
                <PingIndicator />
              </Flex.Item>
              <Flex.Item mx={0.5}>
                <Button
                  color="grey"
                  selected={audioOpen || audio.playing}
                  icon="music"
                  onClick={() => setAudioOpen(!audioOpen)} />
              </Flex.Item>
              <Flex.Item mx={0.5}>
                <Button
                  icon="cog"
                  selected={settingsOpen}
                  onClick={() => setSettingsOpen(!settingsOpen)} />
              </Flex.Item>
            </Flex>
          </Section>
        </Flex.Item>
        {audioOpen && (
          <Flex.Item mt={1}>
            <Section>
              <NowPlayingWidget />
            </Section>
          </Flex.Item>
        )}
        {settingsOpen && (
          <Flex.Item mt={1}>
            <SettingsPanel />
          </Flex.Item>
        )}
        <Flex.Item mt={1} grow={1}>
          <Section fill fitted position="relative">
            <Pane.Content scrollable>
              <ChatPanel
                lineHeight={settings.lineHeight} />
            </Pane.Content>
            <Notifications>
              {game.connectionLostAt && (
                <Notifications.Item
                  rightSlot={(
                    <Button
                      color="white"
                      onClick={() => Byond.command('.reconnect')}>
                      Reconnect
                    </Button>
                  )}>
                  You are either AFK, experiencing lag or the connection
                  has closed.
                </Notifications.Item>
              )}
              {game.roundRestartedAt && (
                <Notifications.Item>
                  The connection has been closed because the server is
                  restarting. Please wait while you automatically reconnect.
                </Notifications.Item>
              )}
            </Notifications>
          </Section>
        </Flex.Item>
      </Flex>
    </Pane>
  );
};
