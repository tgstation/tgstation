import {
  Box,
  Button,
  LabeledList,
  Section,
  Slider,
  Stack,
  Table,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type ManipulatorData = {
  active: BooleanLike;
  drop_after_use: BooleanLike;
  empty_hand_use: BooleanLike;
  highest_priority: BooleanLike;
  manipulate_mode: string;
  settings_list: PrioritySettings[];
  throw_range: number;
  item_as_filter: string;
  selected_type: string;
  delay_step: number;
  delay_value: number;
  min_delay: number;
  max_delay: number;
};

type PrioritySettings = {
  name: string;
  priority_width: number;
};

export const BigManipulator = (props) => {
  const { data, act } = useBackend<ManipulatorData>();
  const {
    active,
    manipulate_mode,
    settings_list,
    drop_after_use,
    empty_hand_use,
    highest_priority,
    throw_range,
    item_as_filter,
    selected_type,
    delay_step,
    delay_value,
    min_delay,
    max_delay,
  } = data;
  return (
    <Window title="Manipulator Interface" width={320} height={340}>
      <Window.Content>
        <Section
          title="Action Panel"
          buttons={
            <Button
              icon="power-off"
              selected={active}
              content={active ? 'On' : 'Off'}
              onClick={() => act('on')}
            />
          }
        >
          <Stack
            style={{
              lineHeight: '2em',
              marginBottom: '0px',
            }}
          >
            <Stack.Item grow>
              <Stack>
                <Stack.Item
                  style={{
                    marginRight: '10px',
                  }}
                >
                  Delay:
                </Stack.Item>
                <Stack style={{ width: '100%' }}>
                  <Stack.Item>
                    <Button
                      icon="backward-step"
                      onClick={() =>
                        act('changeDelay', {
                          new_delay: min_delay,
                        })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item grow>
                    {' '}
                    <Slider
                      style={{
                        marginTop: '-5px',
                      }}
                      step={delay_step}
                      my={1}
                      value={delay_value}
                      minValue={min_delay}
                      maxValue={max_delay}
                      unit="sec."
                      onDrag={(e, value) =>
                        act('changeDelay', {
                          new_delay: value,
                        })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="forward-step"
                      onClick={() =>
                        act('changeDelay', {
                          new_delay: max_delay,
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Button
                content={'Drop'}
                icon="eject"
                tooltip="Disengage the claws, dropping the held item"
                onClick={() => act('drop')}
              />
            </Stack.Item>
          </Stack>

          <Stack.Item grow>
            {manipulate_mode === 'use' && (
              <Section fill>
                <Button
                  content="Drop Use"
                  tooltip="drop item after use. othewise manipulator will use this item after cooldown."
                  selected={drop_after_use}
                  onClick={() => act('drop_use_change')}
                />
                <Button
                  content="Empty Hand Use"
                  tooltip="if activated monkey will be work with items with using empty hand."
                  selected={empty_hand_use}
                  onClick={() => act('empty_use_change')}
                />
              </Section>
            )}
          </Stack.Item>
        </Section>
        <Section title={'Configuration'}>
          <Table>
            <Table.Row
              className="candystripe"
              style={{
                height: '2em',
                padding: '20px',
                lineHeight: '2em',
              }}
            >
              <Table.Cell>
                <Box
                  style={{
                    marginLeft: '5px',
                  }}
                >
                  Interaction Mode
                </Box>
              </Table.Cell>
              <Table.Cell
                style={{
                  width: 'min-content',
                  whiteSpace: 'nowrap',
                  textAlign: 'right',
                }}
              >
                <Button
                  content={manipulate_mode.toUpperCase()}
                  tooltip="Cycle through interaction modes"
                  onClick={() => act('change_mode')}
                />
              </Table.Cell>
            </Table.Row>
            {manipulate_mode === 'throw' && (
              <Table.Row
                className="candystripe"
                style={{
                  height: '2em',
                  padding: '20px',
                  lineHeight: '2em',
                }}
              >
                <Table.Cell>
                  <Box
                    style={{
                      marginLeft: '5px',
                    }}
                  >
                    Throwing Range
                  </Box>
                </Table.Cell>
                <Table.Cell
                  style={{
                    width: 'min-content',
                    whiteSpace: 'nowrap',
                    textAlign: 'right',
                  }}
                >
                  <Button
                    content={`${throw_range} TILE${throw_range > 1 ? 'S' : ''}`}
                    tooltip="Cycle the distance an object will travel when thrown"
                    onClick={() => act('change_throw_range')}
                  />
                </Table.Cell>
              </Table.Row>
            )}

            <Table.Row
              className="candystripe"
              style={{
                height: '2em',
                paddingLeft: '20px',
                lineHeight: '2em',
              }}
            >
              <Table.Cell grow width={'100%'}>
                <Box
                  style={{
                    marginLeft: '5px',
                  }}
                >
                  Interaction Filter
                </Box>
              </Table.Cell>
              <Table.Cell
                style={{
                  width: 'min-content',
                  whiteSpace: 'nowrap',
                  textAlign: 'right',
                }}
              >
                <Button
                  content={selected_type.toUpperCase()}
                  tooltip="Cycle through types of items to filter"
                  onClick={() => act('change_take_item_type')}
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row
              className="candystripe"
              style={{
                height: '2em',
                paddingLeft: '20px',
                lineHeight: '2em',
              }}
            >
              <Table.Cell grow width={'100%'}>
                <Box
                  style={{
                    marginLeft: '5px',
                  }}
                >
                  Item Filter
                </Box>
              </Table.Cell>
              <Table.Cell
                style={{
                  width: 'min-content',
                  whiteSpace: 'nowrap',
                  textAlign: 'right',
                }}
              >
                <Button
                  content={item_as_filter ? item_as_filter : 'NO FILTER'}
                  tooltip={
                    <Box>
                      Click while holding an item to
                      <Box /> set filtering type
                    </Box>
                  }
                  onClick={() => act('add_filter')}
                  tooltipPosition="left"
                />
              </Table.Cell>
            </Table.Row>
            {manipulate_mode != 'throw' && (
              <Table.Row
                className="candystripe"
                style={{
                  height: '2em',
                  paddingLeft: '20px',
                  lineHeight: '2em',
                }}
              >
                <Table.Cell grow width={'100%'}>
                  <Box
                    style={{
                      marginLeft: '5px',
                    }}
                  >
                    Use First Dropoff Point Only
                  </Box>
                </Table.Cell>
                <Table.Cell
                  style={{
                    width: 'min-content',
                    whiteSpace: 'nowrap',
                    textAlign: 'right',
                  }}
                >
                  <Button
                    content={highest_priority ? 'TRUE' : 'FALSE'}
                    selected={highest_priority}
                    tooltip="Only interact with the highest dropoff point in the list"
                    onClick={() => act('highest_priority_change')}
                  />
                </Table.Cell>
              </Table.Row>
            )}
          </Table>
        </Section>
        {manipulate_mode != 'throw' && (
          <Section>
            <Table>
              {settings_list.map((setting) => (
                <Table.Row
                  key={setting.name}
                  className="candystripe"
                  style={{
                    height: '2em',
                    paddingLeft: '20px',
                    lineHeight: '2em',
                  }}
                >
                  <Table.Cell
                    style={{
                      paddingLeft: '2px',
                      width: '2em',
                    }}
                  >
                    <Button
                      icon="arrow-up"
                      onClick={() =>
                        act('change_priority', {
                          priority: setting.priority_width,
                        })
                      }
                    />
                  </Table.Cell>
                  <Table.Cell>
                    <Box>{setting.name}</Box>
                  </Table.Cell>
                  <Table.Cell>{setting.priority_width}</Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
