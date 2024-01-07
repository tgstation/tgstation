import { Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { Bays } from './Bays';
import { LaunchPage } from './LaunchPage';
import { PodSounds } from './PodSounds';
import { PodStatusPage } from './PodStatusPage';
import { PresetsPage } from './PresetsPage';
import { ReverseMenu } from './ReverseMenu';
import { StylePage } from './StylePage';
import { Timing } from './Timing';
import { useCompact } from './useCompact';
import { ViewTabHolder } from './ViewTabHolder';

export function CentcomPodLauncher(props) {
  const { compact } = useCompact();

  return (
    <Window
      title="Supply Pod Menu (Use against Helen Weinstein)"
      width={compact ? 460 : 730}
      height={compact ? 360 : 440}
    >
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item shrink={0}>
            <PodStatusPage />
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item grow shrink={0} basis="14.1em">
                <Stack fill vertical>
                  <Stack.Item grow>
                    <PresetsPage />
                  </Stack.Item>
                  <Stack.Item>
                    <ReverseMenu />
                  </Stack.Item>
                  <Stack.Item>
                    <Section>
                      <LaunchPage />
                    </Section>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              {!compact && (
                <Stack.Item grow={3}>
                  <ViewTabHolder />
                </Stack.Item>
              )}
              <Stack.Item basis="8em">
                <Stack fill vertical>
                  <Stack.Item>
                    <Bays />
                  </Stack.Item>
                  <Stack.Item grow>
                    <Timing />
                  </Stack.Item>
                  {!compact && (
                    <Stack.Item>
                      <PodSounds />
                    </Stack.Item>
                  )}
                </Stack>
              </Stack.Item>
              <Stack.Item basis="11em">
                <StylePage />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
