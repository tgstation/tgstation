/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Button, Flex, Section } from 'tgui/components';
import { Pane } from 'tgui/layouts';
import { NowPlayingWidget, useAudio } from './audio';
import { ChatPanel, ChatTabs } from './chat';
import { useGame } from './game';
import { Notifications } from './Notifications';
import { PingIndicator } from './ping';
import { SettingsPanel, useSettings } from './settings';

export const Panel = (props, context) => {
  // IE8-10: Needs special treatment due to missing Flex support
  if (Byond.IS_LTE_IE10) {
    return (
      <HoboPanel />
    );
  }
  const audio = useAudio(context);
  const settings = useSettings(context);
  const game = useGame(context);
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
    <Pane theme={settings.theme}>
      <Flex
        direction="column"
        height="100%">
        <Flex.Item>
          <Section fitted>
            <Flex mx={0.5} align="center">
              <Flex.Item mx={0.5} grow={1} overflowX="auto">
                <ChatTabs />
              </Flex.Item>
              <Flex.Item mx={0.5}>
                <PingIndicator />
              </Flex.Item>
              <Flex.Item mx={0.5}>
                <Button
                  color="grey"
                  selected={audio.visible}
                  icon="music"
                  tooltip="Music player"
                  tooltipPosition="bottom-left"
                  onClick={() => audio.toggle()} />
              </Flex.Item>
              <Flex.Item mx={0.5}>
                <Button
                  icon={settings.visible ? 'times' : 'cog'}
                  selected={settings.visible}
                  tooltip={settings.visible
                    ? 'Close settings'
                    : 'Open settings'}
                  tooltipPosition="bottom-left"
                  onClick={() => settings.toggle()} />
              </Flex.Item>
            </Flex>
          </Section>
        </Flex.Item>
        {audio.visible && (
          <Flex.Item mt={1}>
            <Section>
              <NowPlayingWidget />
            </Section>
          </Flex.Item>
        )}
        {settings.visible && (
          <Flex.Item mt={1}>
            <SettingsPanel />
          </Flex.Item>
        )}
        <Flex.Item mt={1} grow={1}>
          <Section fill fitted position="relative">
            <Pane.Content scrollable>
              <ChatPanel lineHeight={settings.lineHeight} />
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

const HoboPanel = (props, context) => {
  const settings = useSettings(context);
  return (
    <Pane theme={settings.theme}>
      <Pane.Content scrollable>
        <Button
          style={{
            position: 'fixed',
            top: '1em',
            right: '2em',
            'z-index': 1000,
          }}
          selected={settings.visible}
          onClick={() => settings.toggle()}>
          Settings
        </Button>
        {settings.visible && (
          <Flex.Item mt={1}>
            <SettingsPanel />
          </Flex.Item>
        ) || (
          <ChatPanel lineHeight={settings.lineHeight} />
        )}
      </Pane.Content>
    </Pane>
  );
};
