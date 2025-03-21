import {
  Box,
  Button,
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

const MasterControls = () => {
  const { act, data } = useBackend<ManipulatorData>();
  const { delay_step, delay_value, min_delay, max_delay } = data;
  return (
    <Stack>
      <Stack.Item>Delay:</Stack.Item>
      <Stack.Item>
        {' '}
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
        <Slider
          style={{ marginTop: '-5px' }}
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
      <Stack.Item>
        {' '}
        <Button
          content="Drop"
          icon="eject"
          tooltip="Disengage the claws, dropping the held item"
          onClick={() => act('drop')}
        />
      </Stack.Item>
    </Stack>
  );
};

type ConfigRowProps = {
  label: string;
  content: string;
  onClick: () => void;
  tooltip: string;
  selected?: BooleanLike;
};

const ConfigRow = (props: ConfigRowProps) => {
  const { label, content, onClick, tooltip, selected = false } = props;

  return (
    <Table.Row
      className="candystripe"
      style={{
        height: '2em',
        padding: '20px',
        lineHeight: '2em',
      }}
    >
      <Table.Cell>
        <Box style={{ marginLeft: '5px' }}>{label}</Box>
      </Table.Cell>
      <Table.Cell
        style={{
          width: 'min-content',
          whiteSpace: 'nowrap',
          textAlign: 'right',
        }}
      >
        <Button
          content={content}
          tooltip={tooltip}
          onClick={onClick}
          selected={!!selected}
        />
      </Table.Cell>
    </Table.Row>
  );
};

export const BigManipulator = () => {
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
  } = data;

  return (
    <Window title="Manipulator Interface" width={320} height={410}>
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
          <Box
            style={{
              lineHeight: '1.8em',
              marginBottom: '-5px',
            }}
          >
            <MasterControls />
          </Box>
        </Section>

        <Section title="Configuration">
          <Table>
            <ConfigRow
              label="Interaction Mode"
              content={manipulate_mode.toUpperCase()}
              onClick={() => act('change_mode')}
              tooltip="Cycle through interaction modes"
            />

            {manipulate_mode === 'throw' && (
              <ConfigRow
                label="Throwing Range"
                content={`${throw_range} TILE${throw_range > 1 ? 'S' : ''}`}
                onClick={() => act('change_throw_range')}
                tooltip="Cycle the distance an object will travel when thrown"
              />
            )}

            <ConfigRow
              label="Interaction Filter"
              content={selected_type.toUpperCase()}
              onClick={() => act('change_take_item_type')}
              tooltip="Cycle through types of items to filter"
            />
            {manipulate_mode === 'use' && (
              <ConfigRow
                label="Worker Interactions"
                content={empty_hand_use ? 'EMPTY' : 'SINGLE'}
                onClick={() => act('empty_use_change')}
                tooltip={
                  empty_hand_use
                    ? 'Interact with an empty hand'
                    : 'Drop the item after a single interaction cycle'
                }
                selected={!!empty_hand_use}
              />
            )}
            <ConfigRow
              label="Item Filter"
              content={item_as_filter ? item_as_filter : 'NONE'}
              onClick={() => act('add_filter')}
              tooltip="Click while holding an item to set filtering type"
            />

            {manipulate_mode !== 'throw' && (
              <ConfigRow
                label="Use First Dropoff Point Only"
                content={highest_priority ? 'TRUE' : 'FALSE'}
                onClick={() => act('highest_priority_change')}
                tooltip="Only interact with the highest dropoff point in the list"
                selected={!!highest_priority}
              />
            )}
          </Table>
        </Section>

        {manipulate_mode !== 'throw' && (
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
                  <Table.Cell>{setting.name}</Table.Cell>
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
