import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  Modal,
  ProgressBar,
  Section,
  Slider,
  Stack,
  Table,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';

import type { ManipulatorData, PrioritySettings, InteractionPoint } from './types';

const taskingSchedules = {
  "Round Robin": "list-ol",
  "Strict Robin": "arrows-spin",
  "Prefer First": "arrow-down-1-9"
}

const MasterControls = () => {
  const { act, data } = useBackend<ManipulatorData>();
  const { delay_step, interaction_delay, min_delay, max_delay } = data;
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
          value={interaction_delay}
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
  const [editingPoint, setEditingPoint] = useState<InteractionPoint | null>(null);
  const [editingIndex, setEditingIndex] = useState<number | null>(null);

  const handleEditPoint = (point: InteractionPoint, index: number) => {
    setEditingPoint(point);
    setEditingIndex(index);
  };

  const handleDirectionClick = (dx: number, dy: number) => {
    if (!editingPoint || editingIndex === null) return;

    const [baseX, baseY] = data.manipulator_position.split(',').map(Number);

    const newX = baseX + dx;
    const newY = baseY + dy;
    const newTurf = `${newX},${newY}`;

    setEditingPoint({
      ...editingPoint,
      turf: newTurf,
    });

    act('move_point', {
      index: editingIndex + 1,
      dx: dx,
      dy: dy,
      is_pickup: title === 'Pickup Points',
    });
  };

  const getPointDirection = (
    point: InteractionPoint,
  ): { dx: number; dy: number } | null => {
    if (!point || !point.turf) return null;

    const [pointX, pointY] = point.turf.split(',').map(Number);
    const [baseX, baseY] = data.manipulator_position.split(',').map(Number);

    const dx = Math.sign(pointX - baseX);
    const dy = Math.sign(pointY - baseY);

    return { dx, dy };
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

  const handleFilteringModeChange = () => {
    if (!editingPoint || editingIndex === null) return;

    const newMode = (editingPoint.filtering_mode % 3) + 1;
    setEditingPoint({
      ...editingPoint,
      filtering_mode: newMode,
    });

    act('change_pickup_type', {
      index: editingIndex + 1,
    });
  };

  return (
    <>
      <Section
        title={title}
        buttons={<><Button tooltip="Cycle tasking schedule" icon="clipboard-list" color="transparent">Round Robin</Button> <Button icon="plus" color="transparent" onClick={onAdd} /></>}
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
                      <Box bold>{point.name} <Button icon="edit" color="transparent" /></Box>
                      <Box color="label">Mode: {point.mode.toUpperCase()}</Box>
                      <Box color="label">
                        Filters: {point.filters_status ? 'ACTIVE' : 'INACTIVE'}
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
                          act('remove_point', { index: index + 1 })
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
                  {[
                    [-1, 1],
                    [0, 1],
                    [1, 1],
                    [-1, 0],
                    [0, 0],
                    [1, 0],
                    [-1, -1],
                    [0, -1],
                    [1, -1],
                  ].map(([dx, dy]) => {
                    const isCenter = dx === 0 && dy === 0;
                    let icon;
                    if (dx === 1 && dy === 1) icon = 'arrow-up-right';
                    else if (dx === 0 && dy === 1) icon = 'arrow-up';
                    else if (dx === -1 && dy === 1) icon = 'arrow-up-left';
                    else if (dx === 1 && dy === 0) icon = 'arrow-right';
                    else if (dx === -1 && dy === 0) icon = 'arrow-left';
                    else if (dx === 1 && dy === -1) icon = 'arrow-down-right';
                    else if (dx === 0 && dy === -1) icon = 'arrow-down';
                    else if (dx === -1 && dy === -1) icon = 'arrow-down-left';
                    else if (dx === 0 && dy === 0) icon = 'location-dot';

                    const currentDirection = getPointDirection(editingPoint);
                    const isCurrentDirection =
                      currentDirection &&
                      dx === currentDirection.dx &&
                      dy === currentDirection.dy;

                    return (
                      <Button
                        key={`${dx},${dy}`}
                        icon={icon}
                        disabled={isCenter}
                        color={isCurrentDirection ? 'good' : 'default'}
                        onClick={() =>
                          !isCenter && handleDirectionClick(dx, dy)
                        }
                        style={{
                          margin: '0px',
                          textAlign: 'center',
                          padding: '0px',
                        }}
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
                        onClick={handleFilteringModeChange}
                        tooltip="Cycle the pickup type"
                      />
                      <ConfigRow
                        label="Item Filters"
                        content={
                          editingPoint.item_filters.length
                            ? 'ACTIVE'
                            : 'INACTIVE'
                        }
                        onClick={() =>
                          act('toggle_item_filter', {
                            index: editingIndex + 1,
                          })
                        }
                        tooltip="Toggle item filters"
                      />
                      <ConfigRow
                        label="Skip Item Filters"
                        content={editingPoint.filters_status ? 'TRUE' : 'FALSE'}
                        onClick={() =>
                          act('toggle_filters_skip', {
                            index: editingIndex + 1,
                          })
                        }
                        tooltip="Toggle filter skipping"
                      />
                    </>
                  ) : (
                    <>
                      <ConfigRow
                        label="Mode"
                        content={editingPoint.mode.toUpperCase()}
                        onClick={() =>
                          act('change_dropoff_mode', {
                            index: editingIndex + 1,
                          })
                        }
                        tooltip="Change dropoff mode"
                      />
                      <ConfigRow
                        label="Overflow"
                        content="OFF"
                        onClick={() =>
                          act('toggle_overflow', {
                            index: editingIndex + 1,
                          })
                        }
                        tooltip="Toggle overflow"
                      />
                      <ConfigRow
                        label="Filters"
                        content={
                          editingPoint.item_filters.length
                            ? 'ACTIVE'
                            : 'INACTIVE'
                        }
                        onClick={() =>
                          act('toggle_dropoff_filters', {
                            index: editingIndex + 1,
                          })
                        }
                        tooltip="Toggle filters"
                      />
                    </>
                  )}
                </Table>
              </Stack.Item>
            </Stack>
          </Section>
          {editingPoint.filters_status && <Section>something</Section>}
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
    current_task_type,
    current_task_duration,
    pickup_points,
    dropoff_points,
  } = data;

  // Local state for ProgressBar value management
  const [progressValue, setProgressValue] = useState(0);

  // Effect to control animation
  useEffect(() => {
    const isTaskActive = current_task_type !== 'idle';
    // Set initial value on task change
    setProgressValue(0);

    if (isTaskActive) {
      // Slight delay before setting the final value
      const timer = setTimeout(() => {
        setProgressValue(1);
      }, 20); // 20ms delay

      // Cleanup timer on unmount or task change
      return () => clearTimeout(timer);
    }
  }, [current_task_type]); // Dependency on task type

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
              <Button
                icon={active ? 'stop' : 'play'}
                color={active ? 'bad' : 'good'}
                onClick={() => act('on')}
              >
                {active ? 'Stop' : 'Run'}
              </Button>
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
            <ProgressBar
              value={progressValue}
              maxValue={1}
              style={{
                transition:
                  progressValue === 1
                    ? `width ${current_task_duration}s linear`
                    : 'none',
              }}
            >
              <Stack lineHeight="1.8em">
                <Stack.Item ml="-2px">Current task:</Stack.Item>
                <Stack.Item grow>{current_task_type.toUpperCase()}</Stack.Item>
              </Stack>
            </ProgressBar>
          </Section>

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
