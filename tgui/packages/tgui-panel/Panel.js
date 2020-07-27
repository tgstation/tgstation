import { Button, Flex, Section } from 'tgui/components';
import { Pane } from 'tgui/layouts';
import { ChatPanel, ChatTabs } from './chat';
import { PingIndicator } from './ping';
import { SettingsPanel, useSettings } from './settings';

export const Panel = (props, context) => {
  const settings = useSettings(context);
  return (
    <Pane
      theme={settings.theme}
      fontSize={settings.fontSize + 'pt'}>
      <Flex
        direction="column"
        height="100%">
        <Flex.Item>
          <Section fitted>
            <Flex align="center">
              <Flex.Item mx={1} grow={1}>
                <ChatTabs />
              </Flex.Item>
              <Flex.Item mx={1}>
                <PingIndicator />
              </Flex.Item>
              <Flex.Item mx={1}>
                <Button
                  icon="cog"
                  onClick={() => settings.toggle()} />
              </Flex.Item>
            </Flex>
          </Section>
        </Flex.Item>
        {settings.visible && (
          <Flex.Item position="relative" grow={1}>
            <Pane.Content scrollable>
              <SettingsPanel />
            </Pane.Content>
          </Flex.Item>
        ) || (
          <Flex.Item mt={1} grow={1}>
            <Section fill fitted position="relative">
              <Pane.Content scrollable>
                <ChatPanel
                  lineHeight={settings.lineHeight} />
              </Pane.Content>
            </Section>
          </Flex.Item>
        )}
      </Flex>
    </Pane>
  );
};
