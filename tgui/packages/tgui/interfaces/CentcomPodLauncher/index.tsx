import { Section, Stack } from 'tgui-core/components';

import { Window } from '../../layouts';
import { useCompact } from './hooks';
import { PodBays } from './PodBays';
import { PodLaunch } from './PodLaunch';
import { PodSounds } from './PodSounds';
import { PodStatusPage } from './PodStatusPage';
import { PresetsPage } from './PresetsPage';
import { ReverseMenu } from './ReverseMenu';
import { StylePage } from './StylePage';
import { Timing } from './Timing';
import { ViewTabHolder } from './ViewTabHolder';

export function CentcomPodLauncher(props) {
  const [compact] = useCompact();

  return (
    <Window
      height={compact ? 360 : 440}
      title="Supply Pod Menu (Use against Helen Weinstein)"
      width={compact ? 460 : 730}
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
                      <PodLaunch />
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
                    <PodBays />
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
