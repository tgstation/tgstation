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
    <Window title="Manipulator Interface" width={320} height={420}>
      <Window.Content>
        <Section
          title="Action panel"
          buttons={
            <Box>
              <Button
                icon="power-off"
                content={active ? 'On' : 'Off'}
                selected={active}
                onClick={() => act('on')}
              />
              <Button
                icon="eject"
                tooltip="drop item contained in manipulator"
                onClick={() => act('drop')}
              />
            </Box>
          }
        >
          <Stack.Item grow>
            <Button
              content={`type to take: ${selected_type}`}
              tooltip="changes type of item that manipulator will pick up."
              onClick={() => act('change_take_item_type')}
            />
            <Button
              content={`Mode: ${manipulate_mode}`}
              tooltip="click to change manipulator mode"
              onClick={() => act('change_mode')}
            />
          </Stack.Item>
          <Stack.Item grow>
            <Button
              content={`filter: ${item_as_filter ? `${item_as_filter}` : `no filter`}`}
              tooltip="click on this button with item in hands to add filter on this item."
              onClick={() => act('add_filter')}
            />
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
            {manipulate_mode === 'throw' && (
              <Button
                content={`Throw range: ${throw_range}`}
                tooltip="distance an object will travel when thrown"
                onClick={() => act('change_throw_range')}
              />
            )}
          </Stack.Item>
        </Section>
        <LabeledList.Item
          label="Delay Seconds"
          buttons={
            <Box>
              <Button
                width={4}
                lineHeight={2}
                align="center"
                icon="angles-left"
                onClick={() =>
                  act('changeDelay', {
                    new_delay: min_delay,
                  })
                }
              />
              <Button
                width={4}
                lineHeight={2}
                align="center"
                icon="angles-right"
                onClick={() =>
                  act('changeDelay', {
                    new_delay: max_delay,
                  })
                }
              />
            </Box>
          }
        >
          <Slider
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
        </LabeledList.Item>
        {settings_list.length >= 2 && (
          <Section fill>
            {settings_list.length >= 2 && (
              <Button
                content={'Only 1 priority'}
                selected={highest_priority}
                tooltip="manipulate only on 1 priority in priority list"
                onClick={() => act('highest_priority_change')}
              />
            )}
            <Table>
              {settings_list.map((setting) => (
                <Table.Row key={setting.name} className="candystripe">
                  <Table.Cell width={3}>
                    {setting.name} {` [priority: ${setting.priority_width}]`}
                    {setting.priority_width >= 2 && (
                      <Button
                        icon="arrow-up"
                        align="right"
                        onClick={() =>
                          act('change_priority', {
                            priority: setting.priority_width,
                          })
                        }
                      />
                    )}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
