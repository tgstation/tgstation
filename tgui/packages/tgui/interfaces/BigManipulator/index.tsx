import { useEffect, useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  Modal,
  Section,
  Slider,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';

import type { InteractionPoint, ManipulatorData } from './types';

const taskingSchedules = ['Round Robin', 'Strict Robin', 'Prefer First'];

const taskingScheduleIcons = {
  'Round Robin': 'list-ol',
  'Strict Robin': 'arrows-spin',
  'Prefer First': 'arrow-down-1-9',
};

const buttonNumberToIcon = {
  1: '',
  2: 'arrow-up',
  3: '',
  4: 'arrow-left',
  5: 'arrows-to-dot',
  6: 'arrow-right',
  7: '',
  8: 'arrow-down',
  9: '',
};

const MasterControls = () => {
  const { act, data } = useBackend<ManipulatorData>();
  const {
    delay_step,
    speed_multiplier,
    min_speed_multiplier,
    max_speed_multiplier,
  } = data;
  return (
    <Stack>
      <Stack.Item>Speed:</Stack.Item>
      <Stack.Item>
        {' '}
        <Button
          icon="backward-step"
          onClick={() =>
            act('adjust_interaction_speed', {
              new_speed: min_speed_multiplier,
            })
          }
        />
      </Stack.Item>
      <Stack.Item grow>
        <Slider
          style={{ marginTop: '-5px' }}
          lineHeight={1}
          step={0.1}
          my={1}
          value={speed_multiplier}
          minValue={min_speed_multiplier}
          maxValue={max_speed_multiplier}
          unit="x"
          stepPixelSize={20}
          onDrag={(e, value) =>
            act('adjust_interaction_speed', {
              new_speed: value,
            })
          }
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="forward-step"
          onClick={() =>
            act('adjust_interaction_speed', {
              new_speed: max_speed_multiplier,
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
          onClick={() => act('drop_held_atom')}
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
  const { label, content, onClick, ...rest } = props;
  const { tooltip = '', selected = false } = rest;

  console.log('ConfigRow render:', { label, content, selected });

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

const PointSection = (props: {
  title: string;
  points: InteractionPoint[];
  onAdd: () => void;
  act: (action: string, params?: Record<string, any>) => void;
}) => {
  const { data } = useBackend<ManipulatorData>();
  const { title, points, onAdd, act } = props;
  const [editingPoint, setEditingPoint] = useState<InteractionPoint | null>(
    null,
  );
  const [editingIndex, setEditingIndex] = useState<number | null>(null);

  const isPickup = title === 'Pickup Points';
  const currentTasking = isPickup ? data.pickup_tasking : data.dropoff_tasking;
  const currentIcon = taskingScheduleIcons[currentTasking] || 'clipboard-list';

  const cycleTaskingSchedule = () => {
    const currentIndex = taskingSchedules.indexOf(currentTasking);
    const nextIndex = (currentIndex + 1) % taskingSchedules.length;
    const newTasking = taskingSchedules[nextIndex];
    act('cycle_tasking_schedule', {
      new_schedule: newTasking,
      is_pickup: isPickup,
    });
  };

  const adjustPoint = (pointId: string, param: string, value?: any) => {
    act('adjust_point_param', { pointId, param, value });
  };

  const handleEditPoint = (point: InteractionPoint, index: number) => {
    setEditingPoint(point);
    setEditingIndex(index);
  };

  useEffect(() => {
    if (editingPoint && editingIndex !== null) {
      const currentPoints = isPickup ? data.pickup_points : data.dropoff_points;
      const updatedPoint = currentPoints.find((p) => p.id === editingPoint.id);
      if (updatedPoint) {
        setEditingPoint(updatedPoint);
      }
    }
  }, [
    data.pickup_points,
    data.dropoff_points,
    editingPoint?.id,
    editingIndex,
    isPickup,
  ]);

  const handleDirectionClick = (buttonNumber: number) => {
    if (!editingPoint || editingIndex === null) return;

    adjustPoint(editingPoint.id, 'move_to', {
      buttonNumber,
      is_pickup: title === 'Pickup Points',
    });
  };

  const getPointButtonNumber = (point: InteractionPoint): number | null => {
    if (!point || !point.turf) return null;

    const [pointX, pointY] = point.turf.split(',').map(Number);
    const [baseX, baseY] = data.manipulator_position.split(',').map(Number);

    const dx = pointX - baseX;
    const dy = pointY - baseY;

    if (dx === -1 && dy === 1) return 1;
    if (dx === 0 && dy === 1) return 2;
    if (dx === 1 && dy === 1) return 3;
    if (dx === -1 && dy === 0) return 4;
    if (dx === 0 && dy === 0) return 5;
    if (dx === 1 && dy === 0) return 6;
    if (dx === -1 && dy === -1) return 7;
    if (dx === 0 && dy === -1) return 8;
    if (dx === 1 && dy === -1) return 9;

    return null;
  };

  const getFilteringModeText = (mode: number) => {
    switch (mode) {
      case 1:
        return 'ITEMS';
      case 2:
        return 'CLOSETS';
      case 3:
        return 'HUMANS';
      default:
        return 'UNKNOWN';
    }
  };

  const formatFilters = (filters: string[]) => {
    if (!filters || filters.length === 0) return '—';
    if (filters.length <= 2) return filters.join(', ');
    const shown = filters.slice(0, 2).join(', ');
    const remaining = filters.length - 2;
    return `${shown} and ${remaining} more...`;
  };

  return (
    <>
      <Section
        title={title}
        buttons={
          <>
            <Button
              tooltip="Cycle tasking schedule"
              onClick={cycleTaskingSchedule}
              icon={currentIcon}
              color="transparent"
            >
              {currentTasking}
            </Button>{' '}
            <Button icon="plus" color="transparent" onClick={onAdd} />
          </>
        }
      >
        <Stack vertical>
          {points.map((point, index) => (
            <Stack.Item
              key={index}
              style={{
                padding: '5px',
              }}
              className="candystripe"
            >
              <Box>
                <Stack>
                  <Stack.Item grow>
                    <Box>
                      <Box bold>
                        {point.name} <Button icon="edit" color="transparent" />
                      </Box>
                      <Box color="label">Mode: {point.mode.toUpperCase()}</Box>
                      <Box
                        color="label"
                        style={{
                          maxWidth: '280px',
                          whiteSpace: 'nowrap',
                          overflow: 'hidden',
                          textOverflow: 'ellipsis',
                          display: 'block',
                        }}
                      >
                        Filters: {formatFilters(point.item_filters)}
                      </Box>
                    </Box>
                  </Stack.Item>
                  <Stack vertical>
                    <Stack.Item>
                      <Button
                        icon="gear"
                        color="transparent"
                        onClick={() => handleEditPoint(point, index)}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="trash"
                        color="transparent"
                        onClick={() =>
                          adjustPoint(
                            point.id,
                            'remove_point',
                            isPickup && 'SOMETHING',
                          )
                        }
                      />
                    </Stack.Item>
                  </Stack>
                </Stack>
              </Box>
            </Stack.Item>
          ))}
        </Stack>
      </Section>

      {editingPoint && editingIndex !== null && (
        <Modal
          style={{
            padding: '6px',
            width: '340px',
            boxSizing: 'initial',
          }}
        >
          <Section
            title="Point Properties"
            buttons={
              <Button
                icon="xmark"
                color="bad"
                onClick={() => {
                  setEditingPoint(null);
                  setEditingIndex(null);
                }}
              />
            }
          >
            <Stack>
              <Stack.Item>
                <Box
                  style={{
                    display: 'grid',
                    gridTemplateColumns: '1fr 1fr 1fr',
                    gridTemplateRows: '1fr 1fr 1fr',
                    height: '60px',
                    width: '60px',
                    gap: '2px',
                    rowGap: '2px',
                    marginRight: '10px',
                  }}
                >
                  {[1, 2, 3, 4, 5, 6, 7, 8, 9].map((buttonNumber) => {
                    const isCenter = buttonNumber === 5;
                    const currentButton = getPointButtonNumber(editingPoint);
                    const isCurrentButton = currentButton === buttonNumber;

                    return (
                      <Button
                        key={buttonNumber}
                        disabled={isCenter}
                        color={isCurrentButton ? 'good' : 'default'}
                        onClick={() =>
                          !isCenter && handleDirectionClick(buttonNumber)
                        }
                        style={{
                          margin: '0px',
                          textAlign: 'center',
                          padding: '0px',
                        }}
                        icon={buttonNumberToIcon[buttonNumber]}
                      />
                    );
                  })}
                </Box>
              </Stack.Item>
              <Stack.Item grow>
                <Table>
                  {title === 'Pickup Points' ? (
                    <>
                      <ConfigRow
                        label="Object Type"
                        content={getFilteringModeText(
                          editingPoint.filtering_mode,
                        )}
                        onClick={() =>
                          adjustPoint(
                            editingPoint.id,
                            'cycle_pickup_point_type',
                          )
                        }
                        tooltip="Cycle the pickup type"
                      />
                      <ConfigRow
                        label="Use Item Filters"
                        content={editingPoint.filters_status ? 'TRUE' : 'FALSE'}
                        onClick={() =>
                          adjustPoint(editingPoint.id, 'toggle_filter_skip')
                        }
                        tooltip="Toggle filter usage"
                      />
                    </>
                  ) : (
                    <>
                      <ConfigRow
                        label="Mode"
                        content={editingPoint.mode.toUpperCase()}
                        onClick={() =>
                          adjustPoint(
                            editingPoint.id,
                            'cycle_dropoff_point_interaction',
                          )
                        }
                        tooltip="Change dropoff mode"
                      />
                      <ConfigRow
                        label="Overflow"
                        content={editingPoint.overflow_status}
                        onClick={() =>
                          adjustPoint(editingPoint.id, 'cycle_overflow_status')
                        }
                        tooltip="Cycle overflow status"
                      />
                      <ConfigRow
                        label="Use Item Filters"
                        content={editingPoint.filters_status ? 'TRUE' : 'FALSE'}
                        onClick={() =>
                          adjustPoint(editingPoint.id, 'toggle_filter_skip')
                        }
                        tooltip="Toggle filter usage"
                      />
                      <ConfigRow
                        label="Alternative Worker Action"
                        content={editingPoint.worker_use_rmb ? 'TRUE' : 'FALSE'}
                        onClick={() =>
                          adjustPoint(editingPoint.id, 'toggle_worker_rmb')
                        }
                        tooltip="Toggle RMB-like attack"
                      />
                      <ConfigRow
                        label="Worker Combat Stance"
                        content={
                          editingPoint.worker_combat_mode ? 'TRUE' : 'FALSE'
                        }
                        onClick={() =>
                          adjustPoint(editingPoint.id, 'toggle_worker_combat')
                        }
                        tooltip="Toggle using Combat Mode for interactions"
                      />
                    </>
                  )}
                </Table>
              </Stack.Item>
            </Stack>
          </Section>
          <Section title="Interaction Priorities">
            <Stack vertical>
              {editingPoint.settings_list.map((setting, index) => (
                <Stack key={setting.name} align="center">
                  <Stack.Item>
                    <Button
                      icon="arrow-up"
                      disabled={index === 0}
                      onClick={() =>
                        index > 0 &&
                        adjustPoint(editingPoint.id, 'priority_move_up', {
                          name: setting.name,
                        })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item grow>
                    <Box
                      className="candystripe"
                      style={{
                        padding: '4px 8px',
                        border: '1px solid #40668c',
                        width: `${Math.max(1, setting.priority_width) * 40}px`,
                        display: 'inline-block',
                      }}
                    >
                      {setting.name}
                    </Box>
                  </Stack.Item>
                </Stack>
              ))}
            </Stack>
          </Section>
          <Section
            title="Item Filters"
            buttons={
              <>
                <Button
                  icon="plus"
                  onClick={() =>
                    adjustPoint(editingPoint.id, 'add_atom_filter_from_held')
                  }
                >
                  Add held
                </Button>
                <Button.Confirm
                  onClick={() =>
                    adjustPoint(editingPoint.id, 'reset_atom_filters')
                  }
                  confirmContent="Reset?"
                  icon="trash"
                />
              </>
            }
          >
            <Stack vertical>
              {editingPoint.item_filters.map((name: string, index: number) => {
                return (
                  <Stack key={index}>
                    <Stack.Item grow>
                      <BlockQuote>{name}</BlockQuote>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        color="transparent"
                        icon="xmark"
                        onClick={() =>
                          adjustPoint(editingPoint.id, 'delete_filter', index)
                        }
                      />
                    </Stack.Item>
                  </Stack>
                );
              })}
            </Stack>
          </Section>
        </Modal>
      )}
    </>
  );
};

export const BigManipulator = () => {
  const { data, act } = useBackend<ManipulatorData>();
  const {
    active,
    interaction_mode,
    settings_list,
    worker_interaction,
    highest_priority,
    throw_range,
    item_as_filter,
    selected_type,
    current_task,
    current_task_duration,
    pickup_points,
    dropoff_points,
  } = data;

  // Local state for ProgressBar value management
  const [progressValue, setProgressValue] = useState(0);
  const [progressKey, setProgressKey] = useState(0);

  // Effect to control animation with CSS transitions
  useEffect(() => {
    const isTaskActive = current_task !== 'IDLE' && current_task !== 'NO TASK';

    if (isTaskActive) {
      // Start new task - reset progress and force component recreation
      setProgressValue(0);
      setProgressKey((prev) => prev + 1);

      // Use setTimeout to trigger CSS transition after component recreation
      setTimeout(() => {
        setProgressValue(100);
      }, 10);
    } else {
      // Task completed or idle - reset progress
      setProgressValue(0);
      setProgressKey((prev) => prev + 1);
    }
  }, [current_task, current_task_duration]);

  return (
    <Window title="Manipulator Interface" width={420} height={610}>
      <Window.Content overflowY="auto">
        <Box
          style={{
            height: '100%',
            overflowY: 'auto',
            scrollbarWidth: 'none',
            msOverflowStyle: 'none',
          }}
        >
          <Section
            title="Action Panel"
            buttons={
              <>
                <Button icon="id-card">Lock</Button>
                <Button
                  icon={
                    current_task === 'NO TASK'
                      ? 'play'
                      : current_task === 'STOPPING'
                        ? 'hourglass-start'
                        : 'stop'
                  }
                  color={
                    current_task === 'NO TASK'
                      ? 'good'
                      : current_task === 'STOPPING'
                        ? 'blue'
                        : 'bad'
                  }
                  onClick={() => act('run_cycle')}
                >
                  {current_task === 'NO TASK'
                    ? 'Run'
                    : current_task === 'STOPPING'
                      ? 'Stopping'
                      : 'Stop'}
                </Button>
              </>
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

          <Section>
            <Box
              key={progressKey}
              style={{
                position: 'relative',
                height: '1.8em',
                border: '1px solid #40668c',
                overflow: 'hidden',
                borderRadius: '2px',
              }}
            >
              <Box
                style={{
                  position: 'absolute',
                  top: 0,
                  left: 0,
                  height: '100%',
                  width: `${progressValue}%`,
                  backgroundColor: '#40668c',
                  transition: `width ${current_task_duration}s linear`,
                  zIndex: 1,
                }}
              />
              <Box
                style={{
                  position: 'relative',
                  zIndex: 2,
                  height: '100%',
                  display: 'flex',
                  alignItems: 'center',
                  padding: '0 8px',
                  color: '#fff',
                  fontSize: '12px',
                }}
              >
                <Box style={{ marginRight: '8px', marginLeft: '-2px' }}>
                  Current task:
                </Box>
                <Box style={{ flexGrow: 1 }}>{current_task.toUpperCase()}</Box>
              </Box>
            </Box>
          </Section>

          {/*
          <Section>
            <Stack>
              <Stack.Item lineHeight="1.8" grow>
                <Box
                  style={{
                    padding: '2px',
                    backgroundColor: '#444444',
                  }}
                >
                  <Button fluid icon="eject">
                    data disk
                  </Button>
                  <BlockQuote>No storage detected.</BlockQuote>
                </Box>
              </Stack.Item>
              <Stack.Item style={{ alignContent: 'center' }}>
                <Button lineHeight="2" icon="floppy-disk">
                  Read
                </Button>
              </Stack.Item>
              <Stack.Item style={{ alignContent: 'center' }}>
                <Button lineHeight="2" icon="circle">
                  Write
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
*/}
          <PointSection
            title="Pickup Points"
            points={pickup_points}
            onAdd={() => act('create_pickup_point')}
            act={act}
          />

          <PointSection
            title="Dropoff Points"
            points={dropoff_points}
            onAdd={() => act('create_dropoff_point')}
            act={act}
          />
        </Box>
      </Window.Content>
    </Window>
  );
};
