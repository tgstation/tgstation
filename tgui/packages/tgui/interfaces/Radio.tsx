import { map } from 'common/collections';
import { toFixed } from 'common/math';
import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, NumberInput, Section, Stack } from '../components';
import { RADIO_CHANNELS } from '../constants';
import { Window } from '../layouts';

type Data = {
  broadcasting: BooleanLike;
  channels: {
    [key: string]: number;
  };
  command: BooleanLike;
  freqlock: BooleanLike;
  frequency: number;
  headset: BooleanLike;
  listening: BooleanLike;
  maxFrequency: number;
  minFrequency: number;
  subspace: BooleanLike;
  subspaceSwitchable: BooleanLike;
  useCommand: BooleanLike;
};

export const Radio = (props) => {
  const { act, data } = useBackend<Data>();
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
  } = data;

  const tunedChannel = RADIO_CHANNELS.find(
    (channel) => channel.freq === frequency
  );

  const channels = map((value: BooleanLike, key: string) => ({
    name: key,
    status: !!value,
  }))(data.channels);
  // Calculate window height
  let height = 109;
  if (subspace) {
    if (channels.length > 0) {
      height += channels.length * 21 + 6;
    } else {
      height += 24;
    }
  }

  return (
    <Window width={360} height={height}>
      <Window.Content>
        <Section fill>
          <LabeledList>
            <LabeledList.Item label="Frequency">
              <Stack align="center">
                <Stack.Item>
                  {(freqlock && (
                    <Box inline color="light-gray">
                      {toFixed(frequency / 10, 1) + ' kHz'}
                    </Box>
                  )) || (
                    <NumberInput
                      animate
                      unit="kHz"
                      step={0.2}
                      stepPixelSize={10}
                      minValue={minFrequency / 10}
                      maxValue={maxFrequency / 10}
                      value={frequency / 10}
                      format={(value) => toFixed(value, 1)}
                      onDrag={(e, value) =>
                        act('frequency', {
                          adjust: value - frequency / 10,
                        })
                      }
                    />
                  )}
                </Stack.Item>
                <Stack.Item>
                  {tunedChannel && (
                    <Box color={tunedChannel.color}>[{tunedChannel.name}]</Box>
                  )}
                </Stack.Item>
              </Stack>
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
            {!!subspace && (
              <LabeledList.Item label="Channels">
                {channels.length === 0 && (
                  <Box inline color="bad">
                    No encryption keys installed.
                  </Box>
                )}
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
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
