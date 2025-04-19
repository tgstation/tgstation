import { map } from 'common/collections';
import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { RADIO_CHANNELS } from '../constants';
import { Window } from '../layouts';

type RadioData = {
  freqlock: number;
  frequency: number;
  minFrequency: number;
  maxFrequency: number;
  listening: BooleanLike;
  broadcasting: BooleanLike;
  command: BooleanLike;
  useCommand: BooleanLike;
  subspace: BooleanLike;
  subspaceSwitchable: BooleanLike;
  channels: string[];
  radio_noises: number;
};

export const Radio = (props) => {
  const { act, data } = useBackend<RadioData>();
  const {
    freqlock,
    frequency,
    minFrequency,
    maxFrequency,
    listening,
    broadcasting,
    command,
    useCommand,
    subspace,
    subspaceSwitchable,
    radio_noises,
  } = data;
  const tunedChannel = RADIO_CHANNELS.find(
    (channel) => channel.freq === frequency,
  );
  const channels = map(data.channels, (value, key) => ({
    name: key,
    status: !!value,
  }));
  // Calculate window height
  let height = 133;
  if (subspace) {
    if (channels.length > 0) {
      height += channels.length * 25 + 8;
    } else {
      height += 24;
    }
  }
  return (
    <Window width={376} height={height}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Frequency">
              {(freqlock && (
                <Box inline color="light-gray">
                  {toFixed(frequency / 10, 1) + ' kHz'}
                </Box>
              )) || (
                <NumberInput
                  animated
                  unit="kHz"
                  step={0.2}
                  stepPixelSize={10}
                  minValue={minFrequency / 10}
                  maxValue={maxFrequency / 10}
                  value={frequency / 10}
                  format={(value) => toFixed(value, 1)}
                  onDrag={(value) =>
                    act('frequency', {
                      adjust: value - frequency / 10,
                    })
                  }
                />
              )}
              {tunedChannel && (
                <Box inline color={tunedChannel.color} ml={2}>
                  [{tunedChannel.name}]
                </Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Audio">
              <Button
                textAlign="center"
                width="37px"
                icon={listening ? 'volume-up' : 'volume-mute'}
                selected={listening}
                onClick={() => act('listen')}
              />
              <Button
                textAlign="center"
                width="37px"
                icon={broadcasting ? 'microphone' : 'microphone-slash'}
                selected={broadcasting}
                onClick={() => act('broadcast')}
              />
              {!!command && (
                <Button
                  ml={1}
                  icon="bullhorn"
                  selected={useCommand}
                  content={`High volume ${useCommand ? 'ON' : 'OFF'}`}
                  onClick={() => act('command')}
                />
              )}
              {!!subspaceSwitchable && (
                <Button
                  ml={1}
                  icon="bullhorn"
                  selected={subspace}
                  content={`Subspace Tx ${subspace ? 'ON' : 'OFF'}`}
                  onClick={() => act('subspace')}
                />
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Radio Noise Volume">
              <Slider
                onChange={(e, value) => {
                  act('set_radio_volume', {
                    volume: value,
                  });
                }}
                minValue={0}
                maxValue={100}
                step={1}
                value={radio_noises}
                stepPixelSize={10}
              />
            </LabeledList.Item>
            {!!subspace && (
              <LabeledList.Item label="Channels">
                {channels.length === 0 && (
                  <Box inline color="bad">
                    No encryption keys installed.
                  </Box>
                )}
                <Stack vertical>
                  {channels.map((channel) => (
                    <Box key={channel.name}>
                      <Button
                        icon={channel.status ? 'check-square-o' : 'square-o'}
                        selected={channel.status}
                        content={channel.name}
                        onClick={() =>
                          act('channel', {
                            channel: channel.name,
                          })
                        }
                      />
                    </Box>
                  ))}
                </Stack>
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
