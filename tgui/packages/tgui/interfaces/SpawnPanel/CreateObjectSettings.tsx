import { storage } from 'common/storage';
import React, { useEffect, useState } from 'react';
import {
  Button,
  Dropdown,
  Input,
  NumberInput,
  Slider,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import {
  directionIcons,
  directionNames,
  spawnLocationIcons,
  spawnLocationOptions,
} from './constants';

interface SpawnPanelData {
  icon: string;
  iconState: string;
  preferences?: {
    hide_icons: boolean;
    hide_mappings: boolean;
    sort_by: string;
    search_text: string;
    search_by: string;
    where_dropdown_value: string;
    offset_type: string;
    offset: string;
    object_count: number;
    dir: number;
    object_name: string;
  };
  precise_mode: string;
}

interface CreateObjectSettingsProps {
  onCreateObject?: (obj: any) => void;
}

export function CreateObjectSettings(props: CreateObjectSettingsProps) {
  const { onCreateObject } = props;
  const { act, data } = useBackend<SpawnPanelData>();

  const [amount, setAmount] = useState(1);
  const [cordsType, setCordsType] = useState(0);
  const [spawnLocation, setSpawnLocation] = useState('Current location');
  const [direction, setDirection] = useState(0);
  const [objectName, setObjectName] = useState('');
  const [offset, setOffset] = useState('');

  useEffect(() => {
    const loadStoredValues = async () => {
      const storedAmount = await storage.get('spawnpanel-object_count');
      const storedCordsType = await storage.get('spawnpanel-offset_type');
      const storedSpawnLocation = await storage.get(
        'spawnpanel-where_dropdown_value',
      );
      const storedDirection = await storage.get('spawnpanel-direction');
      const storedObjectName = await storage.get('spawnpanel-object_name');
      const storedOffset = await storage.get('spawnpanel-offset');

      if (storedAmount) setAmount(storedAmount);
      if (storedCordsType !== undefined) setCordsType(storedCordsType);
      if (storedSpawnLocation) setSpawnLocation(storedSpawnLocation);
      if (storedDirection !== undefined) setDirection(storedDirection);
      if (storedObjectName !== undefined) setObjectName(storedObjectName);
      if (storedOffset !== undefined) setOffset(storedOffset);
    };

    loadStoredValues();
  }, []);

  useEffect(() => {
    storage.set('spawnpanel-object_count', amount);
  }, [amount]);

  useEffect(() => {
    storage.set('spawnpanel-offset_type', cordsType);
  }, [cordsType]);

  useEffect(() => {
    storage.set('spawnpanel-where_dropdown_value', spawnLocation);
  }, [spawnLocation]);

  useEffect(() => {
    storage.set('spawnpanel-direction', direction);
  }, [direction]);

  useEffect(() => {
    storage.set('spawnpanel-object_name', objectName);
  }, [objectName]);

  useEffect(() => {
    storage.set('spawnpanel-offset', offset);
  }, [offset]);

  const isTargetMode =
    spawnLocation === 'Targeted location' ||
    spawnLocation === 'Targeted location (droppod)' ||
    spawnLocation === 'At a marked object' ||
    spawnLocation === "In targeted mob's hand";

  const isPreciseModeActive = data?.precise_mode === 'Target';
  const isMarkModeActive = data?.precise_mode === 'Mark';
  const isCopyModeActive = data?.precise_mode === 'Copy';

  const disablePreciseMode = () => {
    if (isPreciseModeActive) {
      act('toggle-precise-mode', {
        newPreciseType: 'Off',
      });
    }
  };

  const handleSpawn = () => {
    const currentSettings = {
      object_count: amount,
      offset_type: cordsType ? 'Absolute offset' : 'Relative offset',
      where_dropdown_value: spawnLocation,
      dir: [1, 2, 4, 8][direction],
      offset,
      object_name: objectName,
    };
    act('update-settings', currentSettings);

    if (!isTargetMode) {
      if (onCreateObject) {
        onCreateObject(currentSettings);
      } else {
        act('create-object-action', currentSettings);
      }
    } else {
      if (isPreciseModeActive) {
        act('toggle-precise-mode', { newPreciseType: 'Off' });
      } else {
        act('toggle-precise-mode', { newPreciseType: 'Target' });
      }
    }
  };

  React.useEffect(() => {
    if (!isTargetMode && isPreciseModeActive) {
      disablePreciseMode();
    }
  }, [spawnLocation]);

  return (
    <Stack fill vertical>
      <Stack>
        <Stack.Item grow>
          <Table
            style={{
              paddingLeft: '5px',
            }}
          >
            <Table.Row className="candystripe" lineHeight="26px">
              <Table.Cell pl={1}>Amnt.:</Table.Cell>
              <Table.Cell>
                <Stack>
                  <Stack.Item>
                    <NumberInput
                      width="45px"
                      minValue={1}
                      maxValue={100}
                      step={1}
                      value={amount}
                      onChange={(value) => setAmount(value)}
                    />
                  </Stack.Item>
                  <Stack.Item>Dir:</Stack.Item>
                  <Stack.Item>
                    <Button
                      icon={directionIcons[[1, 2, 4, 8][direction]]}
                      tooltip={directionNames[[1, 2, 4, 8][direction]]}
                      tooltipPosition="top"
                      fontSize="14"
                      onClick={() => {
                        const values = [1, 2, 4, 8];
                        const currentIndex = values.indexOf(values[direction]);
                        const nextIndex = (currentIndex + 1) % 4;
                        setDirection(nextIndex);
                      }}
                    />
                  </Stack.Item>
                  <Stack.Item grow>
                    <Slider
                      minValue={0}
                      maxValue={3}
                      step={1}
                      stepPixelSize={25}
                      value={direction}
                      format={(value) => {
                        const values = [1, 2, 4, 8];
                        return values[value].toString();
                      }}
                      onChange={(e, value) => setDirection(value)}
                    />
                  </Stack.Item>
                </Stack>
              </Table.Cell>
            </Table.Row>
            <Table.Row className="candystripe" lineHeight="26px">
              <Table.Cell pl={1}>Offset:</Table.Cell>
              <Table.Cell width="1200px">
                <Stack>
                  <Stack.Item>
                    <Button
                      icon={cordsType ? 'a' : 'r'}
                      height="19px"
                      fontSize="14"
                      onClick={() => {
                        const newCordsType = cordsType ? 0 : 1;
                        setCordsType(newCordsType);
                        if (isPreciseModeActive) {
                          disablePreciseMode();
                        }
                      }}
                      tooltip={cordsType ? 'Absolute' : 'Relative'}
                      tooltipPosition="top"
                      disabled={isTargetMode}
                    />
                  </Stack.Item>
                  <Stack.Item grow>
                    <Input
                      placeholder="x, y, z"
                      value={offset}
                      onChange={(value: string) => setOffset(value)}
                      width="100%"
                      disabled={isTargetMode}
                    />
                  </Stack.Item>
                </Stack>
              </Table.Cell>
            </Table.Row>
            <Table.Row className="candystripe" lineHeight="26px">
              <Table.Cell pl={1} width="80px">
                Name:
              </Table.Cell>
              <Table.Cell>
                <Input
                  onChange={(value: string) => setObjectName(value)}
                  value={objectName}
                  width="100%"
                  placeholder="leave empty for initial"
                />
              </Table.Cell>
            </Table.Row>
          </Table>
        </Stack.Item>
        <Stack.Item grow>
          <Stack fill>
            <Stack.Item>
              <Stack vertical>
                <Stack.Item>
                  <Button
                    icon="gear"
                    style={{
                      height: '22px',
                      width: '22px',
                      lineHeight: '22px',
                    }}
                    tooltip="Advanced settings"
                    tooltipPosition="top"
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="trash"
                    style={{
                      height: '22px',
                      width: '22px',
                      lineHeight: '22px',
                    }}
                    tooltip="Reset advanced settings"
                    tooltipPosition="top"
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    style={{
                      height: '22px',
                      width: '22px',
                      lineHeight: '22px',
                    }}
                    icon={
                      spawnLocation === 'At a marked object'
                        ? 'thumbtack'
                        : 'eye-dropper'
                    }
                    onClick={() => {
                      act('toggle-precise-mode', {
                        newPreciseType:
                          isMarkModeActive || isCopyModeActive
                            ? 'Off'
                            : spawnLocation === 'At a marked object'
                              ? 'Mark'
                              : 'Copy',
                      });
                    }}
                    selected={isMarkModeActive || isCopyModeActive}
                    tooltip={
                      spawnLocation === 'At a marked object'
                        ? 'Mark atom'
                        : 'Copy atom path'
                    }
                    tooltipPosition="top"
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item grow>
              <Stack vertical fill>
                <Stack.Item grow>
                  <Button
                    onClick={handleSpawn}
                    style={{
                      width: '100%',
                      height: '100%',
                      textAlign: 'center',
                      fontSize: '20px',
                      alignContent: 'center',
                    }}
                    icon={spawnLocationIcons[spawnLocation]}
                    selected={isTargetMode && isPreciseModeActive}
                  >
                    SPAWN
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Dropdown
                    options={spawnLocationOptions}
                    onSelected={(value) => {
                      if (data?.precise_mode && data.precise_mode !== 'Off') {
                        act('toggle-precise-mode', {
                          newPreciseType: 'Off',
                        });
                      }
                      setSpawnLocation(value);
                    }}
                    selected={spawnLocation}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Stack>
  );
}
