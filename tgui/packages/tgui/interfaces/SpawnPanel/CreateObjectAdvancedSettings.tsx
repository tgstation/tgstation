import { useEffect } from 'react';
import { Button, Dropdown, Slider, Table } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { IconSettings } from './index';

interface SpawnPanelData {
  icon: string;
  iconState: string;
  iconStates: string[];
  selected_object?: string;
  apply_icon_override?: boolean;
}

interface CreateObjectAdvancedSettingsProps {
  iconSettings: IconSettings;
  onIconSettingsChange: (settings: Partial<IconSettings>) => void;
}

export function CreateObjectAdvancedSettings(
  props: CreateObjectAdvancedSettingsProps,
) {
  const { act, data } = useBackend<SpawnPanelData>();
  const { iconSettings, onIconSettingsChange } = props;

  const sendUpdatedSettings = (
    changedSettings: Partial<Record<string, unknown>> = {},
  ) => {
    const currentSettings = {
      selected_atom_icon: data.icon || iconSettings.icon,
      selected_atom_icon_state: data.iconState || iconSettings.iconState,
      atom_icon_size: iconSettings.iconSize,
      ...changedSettings,
    };
    act('update-settings', currentSettings);
  };

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
          <Button fluid onClick={() => act('select-new-DMI')}>
            {data.icon || iconSettings.icon || 'Default'}
          </Button>
        </Table.Cell>
        <Table.Cell pr={1} width="25px">
          <Button
            icon="arrow-rotate-right"
            color="transparent"
            onClick={() => {
              act('reset-DMI-icon');
              sendUpdatedSettings();
            }}
          />
        </Table.Cell>
      </Table.Row>
      <Table.Row className="candystripe" lineHeight="26px">
        <Table.Cell pl={1}>Icon state:</Table.Cell>
        <Table.Cell>
          <Dropdown
            options={iconStateOptions}
            selected={data.iconState || iconSettings.iconState || 'Default'}
            displayText={data.iconState || iconSettings.iconState || 'Default'}
            onSelected={(value) => {
              act('select-new-icon-state', {
                new_state: value,
                current_icon: data.icon || iconSettings.icon,
              });
              onIconSettingsChange({ iconState: value });
              sendUpdatedSettings({ selected_atom_icon_state: value });
            }}
            width="100%"
          />
        </Table.Cell>
        <Table.Cell pr={1}>
          <Button
            icon="arrow-rotate-right"
            color="transparent"
            onClick={() => {
              onIconSettingsChange({ iconState: null });
              act('reset-icon-state');
            }}
          />
        </Table.Cell>
      </Table.Row>
      <Table.Row className="candystripe" lineHeight="26px">
        <Table.Cell pl={1}>Explicitly set icon:</Table.Cell>
        <Table.Cell>
          <Button.Checkbox
            checked={!!iconSettings.applyIcon}
            onClick={() => {
              const next = !iconSettings.applyIcon;
              onIconSettingsChange({ applyIcon: next });
              act('set-apply-icon-override', { value: next });
            }}
          >
            Enabled
          </Button.Checkbox>
        </Table.Cell>
        <Table.Cell pr={1} />
      </Table.Row>
      <Table.Row className="candystripe" lineHeight="26px">
        <Table.Cell pl={1}>Icon scale:</Table.Cell>
        <Table.Cell width="auto">
          <Slider
            minValue={25}
            maxValue={500}
            value={iconSettings.iconSize}
            step={25}
            lineHeight={1}
            stepPixelSize={20}
            onChange={(e, value) => {
              onIconSettingsChange({ iconSize: value });
              sendUpdatedSettings({ atom_icon_size: value });
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
              sendUpdatedSettings({ atom_icon_size: 100 });
            }}
          />
        </Table.Cell>
      </Table.Row>
    </Table>
  );
}
