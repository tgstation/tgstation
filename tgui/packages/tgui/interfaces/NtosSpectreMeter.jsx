import { Box, Button, Icon, ProgressBar, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

export const NtosSpectreMeter = (props) => {
  const { act, data } = useBackend();
  const { auto_mode, spook_value, on_cooldown } = data;
  return (
    <NtosWindow width={400} height={180}>
      <NtosWindow.Content>
        <Section title="Spectre-Meter">
          <Box>
            <Button
              inline
              icon="cog"
              content={auto_mode ? 'Auto' : 'Manual'}
              onClick={() => act('toggle_mode')}
              selected={auto_mode}
              tooltip="Toggle automatic scanning. Can be noisy"
            />
            <Button
              inline
              icon="magnifying-glass"
              content="Scan"
              disabled={auto_mode || on_cooldown}
              tooltip="Has cooldown of about 2 seconds"
              onClick={() => act('manual_scan')}
            />
          </Box>
          <ProgressBar
            value={spook_value}
            maxValue={100}
            ranges={{
              good: [0, 33],
              average: [33, 66],
              bad: [66, 100],
              purple: [100, Infinity],
            }}
          >
            <Box
              lineHeight={1.6}
              fontSize={1.5}
              textAlign="center"
              fontFamily="Comic Sans MS"
              fluid
            >
              <Icon spin name="ghost" />
              {` Spookiness: ${spook_value}% `}
              <Icon spin name="ghost" />
            </Box>
          </ProgressBar>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
