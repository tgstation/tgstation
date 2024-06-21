import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Flex, Icon, Section, Slider } from '../components';
import { Window } from '../layouts';

export const VolumeMixer = (properties) => {
  const { act, data } = useBackend();
  const { channels } = data;
  return (
    <Window>
      <Window.Content>
        <Section height="100%" overflow="auto">
          {channels.map((channel, key) => (
            <Fragment key={channel.num}>
              <Box fontSize="1.25rem" color="label" mt={key > 0 && '0.5rem'}>
                {channel.name}
              </Box>
              <Box mt="0.5rem">
                <Flex>
                  <Flex.Item>
                    <Button width="24px" color="transparent">
                      <Icon
                        name="volume-off"
                        size="1.5"
                        mt="0.1rem"
                        onClick={() =>
                          act('volume', { channel: channel.num, volume: 1 })
                        }
                      />
                    </Button>
                  </Flex.Item>
                  <Flex.Item grow="1" mx="1rem">
                    <Slider
                      minValue={1}
                      maxValue={100}
                      stepPixelSize={3.13}
                      value={channel.volume}
                      onChange={(e, value) =>
                        act('volume', { channel: channel.num, volume: value })
                      }
                    />
                  </Flex.Item>
                  <Flex.Item>
                    <Button width="24px" color="transparent">
                      <Icon
                        name="volume-up"
                        size="1.5"
                        mt="0.1rem"
                        onClick={() =>
                          act('volume', { channel: channel.num, volume: 100 })
                        }
                      />
                    </Button>
                  </Flex.Item>
                </Flex>
              </Box>
            </Fragment>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
