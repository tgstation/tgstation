import { Button, Flex, Section, Box } from 'tgui/components';
import { Pane } from 'tgui/layouts';
import { NowPlayingWidget, useAudio } from './audio';
import { ChatPanel, ChatTabs } from './chat';
import { PingIndicator } from './ping';
import { SettingsPanel, useSettings } from './settings';
import { useLocalState } from 'tgui/backend';
import { useSelector } from 'tgui/store';

export const Panel = (props, context) => {
  const audio = useAudio(context);
  const settings = useSettings(context);
  const [audioOpen, setAudioOpen] = useLocalState(
    context, 'audioOpen', audio.playing);
  const [settingsOpen, setSettingsOpen] = useLocalState(
    context, 'settingsOpen', false);
  if (process.env.NODE_ENV !== 'production') {
    const { selectDebug, KitchenSink } = require('tgui/debug');
    const debug = useSelector(context, selectDebug);
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
          </Section>
        </Flex.Item>
      </Flex>
    </Pane>
  );
};
