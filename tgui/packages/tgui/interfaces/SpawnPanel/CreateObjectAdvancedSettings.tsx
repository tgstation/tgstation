import React, { useEffect } from 'react';
import { Button, Dropdown, Slider, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { IconSettings } from './index';

interface SpawnPanelData {
  icon: string;
  iconState: string;
  iconStates: string[];
  selected_object?: string;
}

interface CreateObjectAdvancedSettingsProps {
  iconSettings: IconSettings;
  onIconSettingsChange: (settings: Partial<IconSettings>) => void;
}

export function CreateObjectAdvancedSettings({
  iconSettings,
  onIconSettingsChange,
}: CreateObjectAdvancedSettingsProps) {
  const { act, data } = useBackend<SpawnPanelData>();

  useEffect(() => {
    act('get-icon-states');
  }, []);

  const iconStateOptions = (
    Array.isArray(data.iconStates) ? data.iconStates : []
  ).map((state) => ({
    value: state,
    displayText: state,
  }));

  return (
    <Table>
      <Table.Row className="candystripe" lineHeight="26px">
        <Table.Cell pl={1} width="fit-content">
          Icon:
        </Table.Cell>
        <Table.Cell>
          <Button fluid onClick={() => act('pick-icon')}>
            {iconSettings.icon || 'Default'}
          </Button>
        </Table.Cell>
        <Table.Cell pr={1} width="25px">
          <Button
            icon="arrow-rotate-right"
            color="transparent"
            onClick={() => {
              onIconSettingsChange({ icon: data.icon });
              act('reset-icon');
            }}
          />
        </Table.Cell>
      </Table.Row>
      <Table.Row className="candystripe" lineHeight="26px">
        <Table.Cell pl={1}>Icon state:</Table.Cell>
        <Table.Cell>
          <Dropdown
            options={iconStateOptions}
            selected={iconSettings.iconState || 'Default'}
            displayText={iconSettings.iconState || 'Default'}
            onSelected={(value) => {
              onIconSettingsChange({ iconState: value });
            }}
            width="100%"
          />
        </Table.Cell>
        <Table.Cell pr={1}>
          <Button
            icon="arrow-rotate-right"
            color="transparent"
            onClick={() => {
              onIconSettingsChange({ iconState: data.iconState });
              act('reset-icon-state');
            }}
          />
        </Table.Cell>
      </Table.Row>
      <Table.Row className="candystripe" lineHeight="26px">
        <Table.Cell pl={1}>Icon scale:</Table.Cell>
        <Table.Cell width="auto">
          <Slider
            minValue={25}
            maxValue={500}
            value={iconSettings.iconSize}
            step={25}
            stepPixelSize={20}
            onChange={(e, value) => {
              onIconSettingsChange({ iconSize: value });
              act('set-icon-size', { size: value });
            }}
          />
        </Table.Cell>
        <Table.Cell pr={1}>
          <Button
            icon="arrow-rotate-right"
            color="transparent"
            onClick={() => {
              onIconSettingsChange({ iconSize: 100 });
              act('reset-icon-size');
            }}
          />
        </Table.Cell>
      </Table.Row>
    </Table>
  );
}
