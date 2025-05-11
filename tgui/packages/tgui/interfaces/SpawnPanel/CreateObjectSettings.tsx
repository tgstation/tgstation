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
import { IconSettings } from './index';
import { SpawnPreferences } from './types';

export interface SpawnPanelData {
  icon: string;
  iconState: string;
  preferences?: SpawnPreferences;
  precise_mode: string;
}

interface CreateObjectSettingsProps {
  onCreateObject?: (obj: Record<string, unknown>) => void;
  setAdvancedSettings: (value: boolean) => void;
  iconSettings: IconSettings;
}

interface StateSetterConfig<T extends unknown> {
  value: T;
  storageKey: string;
  setter: (value: T) => void;
}

const setStateAndStorage = async <T extends unknown>({
  value,
  storageKey,
  setter,
}: StateSetterConfig<T>) => {
  setter(value);
  await storage.set(storageKey, value);
};

export function CreateObjectSettings(props: CreateObjectSettingsProps) {
  const { onCreateObject, setAdvancedSettings, iconSettings } = props;
  const { act, data } = useBackend<SpawnPanelData>();

  const [amount, setAmount] = useState(1);
  const [cordsType, setCordsType] = useState(0);
  const [spawnLocation, setSpawnLocation] = useState('Current location');
  const [direction, setDirection] = useState(0);
  const [objectName, setObjectName] = useState('');
  const [offset, setOffset] = useState('');

  const updateAmount = (value: number) => {
    setStateAndStorage({
      value,
      storageKey: 'spawnpanel-object_count',
      setter: setAmount,
    });
    sendUpdatedSettings({ object_count: value });
  };

  const updateCordsType = (value: number) => {
    setStateAndStorage({
      value,
      storageKey: 'spawnpanel-offset_type',
      setter: setCordsType,
    });
    sendUpdatedSettings({
      offset_type: value ? 'Absolute offset' : 'Relative offset',
    });
  };

  const updateSpawnLocation = (value: string) => {
    setStateAndStorage({
      value,
      storageKey: 'spawnpanel-where_dropdown_value',
      setter: setSpawnLocation,
    });
    sendUpdatedSettings({ where_dropdown_value: value });
  };

  const updateDirection = (value: number) => {
    setStateAndStorage({
      value,
      storageKey: 'spawnpanel-direction',
      setter: setDirection,
    });
    sendUpdatedSettings({ dir: [1, 2, 4, 8][value] });
  };

  const updateObjectName = (value: string) => {
    setStateAndStorage({
      value,
      storageKey: 'spawnpanel-object_name',
      setter: setObjectName,
    });
    sendUpdatedSettings({ object_name: value });
  };

  const updateOffset = (value: string) => {
    setStateAndStorage({
      value,
      storageKey: 'spawnpanel-offset',
      setter: setOffset,
    });
    sendUpdatedSettings({ offset: value });
  };

  const sendUpdatedSettings = (
    changedSettings: Partial<Record<string, unknown>> = {},
  ) => {
    const currentSettings = {
      object_count: amount,
      offset_type: cordsType ? 'Absolute offset' : 'Relative offset',
      where_dropdown_value: spawnLocation,
      dir: [1, 2, 4, 8][direction],
      offset: offset,
      object_name: objectName,
      custom_icon: iconSettings.icon,
      custom_icon_state: iconSettings.iconState,
      custom_icon_size: iconSettings.iconSize,
      ...changedSettings,
    };
    act('update-settings', currentSettings);
  };

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

  const isTargetMode =
    spawnLocation === 'Targeted location' ||
    spawnLocation === 'Targeted location (droppod)' ||
    spawnLocation === "In targeted mob's hand";

  const isPreciseModeActive = data?.precise_mode === 'Target';
  const isMarkModeActive = data?.precise_mode === 'Mark';
  const isCopyModeActive = data?.precise_mode === 'Copy';

  const disablePreciseMode = function (): void {
    if (isPreciseModeActive) {
      act('toggle-precise-mode', {
        newPreciseType: 'Off',
      });
    }
  };

  const handleSpawn = function (): void {
    if (!isTargetMode) {
      const currentSettings = {
        object_count: amount,
        offset_type: cordsType ? 'Absolute offset' : 'Relative offset',
        where_dropdown_value: spawnLocation,
        dir: [1, 2, 4, 8][direction],
        offset,
        object_name: objectName,
        custom_icon: iconSettings.icon,
        custom_icon_state: iconSettings.iconState,
        custom_icon_size: iconSettings.iconSize,
      };
      act('update-settings', currentSettings);

      if (onCreateObject) {
        onCreateObject(currentSettings);
      } else {
        act('create-object-action', currentSettings);
      }
    } else {
      if (isPreciseModeActive) {
        act('toggle-precise-mode', { newPreciseType: 'Off' });
      } else {
        act('toggle-precise-mode', {
          newPreciseType: 'Target',
          where_dropdown_value: spawnLocation,
        });
      }
    }
  };

  useEffect(() => {
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
                      onChange={(value) => updateAmount(value)}
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
                        updateDirection(nextIndex);
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
                      onChange={(e, value) => updateDirection(value)}
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
                      fontSize="14"
                      onClick={() => {
                        const newCordsType = cordsType ? 0 : 1;
                        updateCordsType(newCordsType);
                        if (isPreciseModeActive) {
                          disablePreciseMode();
                        }
                      }}
                      tooltip={cordsType ? 'Absolute' : 'Relative'}
                      tooltipPosition="top"
                      disabled={
                        isTargetMode || spawnLocation === 'At a marked object'
                      }
                    />
                  </Stack.Item>
                  <Stack.Item grow>
                    <Input
                      placeholder="x, y, z"
                      value={offset}
                      onChange={(value: string) => updateOffset(value)}
                      width="100%"
                      disabled={
                        isTargetMode || spawnLocation === 'At a marked object'
                      }
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
                  onChange={(value: string) => updateObjectName(value)}
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
                    onClick={() => setAdvancedSettings(true)}
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
                      updateSpawnLocation(value);
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
