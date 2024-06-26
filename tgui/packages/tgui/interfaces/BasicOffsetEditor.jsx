import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Flex, Icon, Section, Slider } from '../components';
import { Window } from '../layouts';

export const BasicOffsetEditor = (properties) => {
  const { act, data } = useBackend();
  const { offsets } = data;
  return (
    <Window>
      <Window.Content>
        <Section height="100%" overflow="auto">
          {offsets.map((offset, key) => (
            <Fragment key={offset.num}>
              <Box fontSize="2rem" color="label" mt={key > 0 && '0.5rem'}>
                {offset.name}
              </Box>
              <Box mt="0.5rem">
                <Flex justify="center">
                  <Flex.Item>
                    <Box
                      fontSize="1.25rem"
                      color="label"
                      mt={key > 0 && '0.5rem'}
                    >
                      North
                    </Box>
                  </Flex.Item>
                  <Flex.Item>
                    <Button width="24px" color="transparent">
                      <Icon
                        name="volume-off"
                        size="1.5"
                        mt="0.1rem"
                        onClick={() =>
                          act('offset', {
                            name: offset.name,
                            offset: offset.north - 1,
                            direction: 'north',
                          })
                        }
                      />
                    </Button>
                  </Flex.Item>
                  <Flex.Item width="50%" mx="1rem">
                    <Slider
                      minValue={-100}
                      maxValue={100}
                      stepPixelSize={3.13}
                      value={offset.north}
                      onChange={(e, value) =>
                        act('offset', {
                          name: offset.name,
                          offset: value,
                          direction: 'north',
                        })
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
                          act('offset', {
                            name: offset.name,
                            offset: offset.north + 1,
                            direction: 'north',
                          })
                        }
                      />
                    </Button>
                  </Flex.Item>
                </Flex>
              </Box>
              <Box mt="0.5rem">
                <Flex justify="center">
                  <Flex.Item>
                    <Box
                      fontSize="1.25rem"
                      color="label"
                      mt={key > 0 && '0.5rem'}
                    >
                      South
                    </Box>
                  </Flex.Item>
                  <Flex.Item>
                    <Button width="24px" color="transparent">
                      <Icon
                        name="volume-off"
                        size="1.5"
                        mt="0.1rem"
                        onClick={() =>
                          act('offset', {
                            name: offset.name,
                            offset: offset.south - 1,
                            direction: 'south',
                          })
                        }
                      />
                    </Button>
                  </Flex.Item>
                  <Flex.Item width="50%" mx="1rem">
                    <Slider
                      minValue={-100}
                      maxValue={100}
                      stepPixelSize={3.13}
                      value={offset.south}
                      onChange={(e, value) =>
                        act('offset', {
                          name: offset.name,
                          offset: value,
                          direction: 'south',
                        })
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
                          act('offset', {
                            name: offset.name,
                            offset: offset.south + 1,
                            direction: 'south',
                          })
                        }
                      />
                    </Button>
                  </Flex.Item>
                </Flex>
              </Box>
              <Box mt="0.5rem">
                <Flex justify="center">
                  <Flex.Item>
                    <Box
                      fontSize="1.25rem"
                      color="label"
                      mt={key > 0 && '0.5rem'}
                    >
                      East
                    </Box>
                  </Flex.Item>
                  <Flex.Item>
                    <Button width="24px" color="transparent">
                      <Icon
                        name="volume-off"
                        size="1.5"
                        mt="0.1rem"
                        onClick={() =>
                          act('offset', {
                            name: offset.name,
                            offset: offset.east - 1,
                            direction: 'east',
                          })
                        }
                      />
                    </Button>
                  </Flex.Item>
                  <Flex.Item width="50%" mx="1rem">
                    <Slider
                      minValue={-100}
                      maxValue={100}
                      stepPixelSize={3.13}
                      value={offset.east}
                      onChange={(e, value) =>
                        act('offset', {
                          name: offset.name,
                          offset: value,
                          direction: 'east',
                        })
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
                          act('offset', {
                            name: offset.name,
                            offset: offset.east + 1,
                            direction: 'east',
                          })
                        }
                      />
                    </Button>
                  </Flex.Item>
                </Flex>
              </Box>
              <Box mt="0.5rem">
                <Flex justify="center">
                  <Flex.Item>
                    <Box
                      fontSize="1.25rem"
                      color="label"
                      mt={key > 0 && '0.5rem'}
                    >
                      West
                    </Box>
                  </Flex.Item>
                  <Flex.Item>
                    <Button width="24px" color="transparent">
                      <Icon
                        name="volume-off"
                        size="1.5"
                        mt="0.1rem"
                        onClick={() =>
                          act('offset', {
                            name: offset.name,
                            offset: offset.west - 1,
                            direction: 'west',
                          })
                        }
                      />
                    </Button>
                  </Flex.Item>
                  <Flex.Item width="50%" mx="1rem">
                    <Slider
                      minValue={-100}
                      maxValue={100}
                      stepPixelSize={3.13}
                      value={offset.west}
                      onChange={(e, value) =>
                        act('offset', {
                          name: offset.name,
                          offset: value,
                          direction: 'west',
                        })
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
                          act('offset', {
                            name: offset.name,
                            offset: offset.west + 1,
                            direction: 'west',
                          })
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
