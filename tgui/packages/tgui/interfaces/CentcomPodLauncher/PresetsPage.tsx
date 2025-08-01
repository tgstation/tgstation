import { storage } from 'common/storage';
import { useEffect, useState } from 'react';
import {
  Button,
  Divider,
  Input,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { createUuid } from 'tgui-core/uuid';

import { useBackend } from '../../backend';
import { POD_GREY } from './constants';
import type { PodLauncherData } from './types';

type Preset = {
  hue: number;
  id: string;
  title: string;
};

async function saveDataToPreset(id: string, data: any) {
  await storage.set(`podlauncher_preset_${id}`, data);
}

export function PresetsPage(props) {
  const { act, data } = useBackend<PodLauncherData>();

  const [editing, setEditing] = useState(false);
  const [hue, setHue] = useState(0);
  const [name, setName] = useState('');
  const [presetID, setPresetID] = useState('');
  const [presets, setPresets] = useState<Preset[]>([]);

  async function deletePreset(deleteID: string) {
    const newPresets: Preset[] = presets.filter(
      (preset) => preset.id !== deleteID,
    );
    await storage.set('podlauncher_presetlist', newPresets);
    setPresets(newPresets);
    if (presetID === deleteID) {
      setPresetID('');
    }
  }

  async function loadPreset(id: string) {
    const presetData = await storage.get(`podlauncher_preset_${id}`);
    if (presetData !== null && presetData !== undefined) {
      act('loadDataFromPreset', { payload: presetData });
    }
  }

  async function newPreset(presetName: string, hue: number, data: any) {
    if (!presetName.trim()) {
      return;
    }

    const id = createUuid();
    const newPresetEntry: Preset = { id, title: presetName, hue };
    const newPresets: Preset[] = [...presets, newPresetEntry];

    await storage.set('podlauncher_presetlist', newPresets);
    setPresets(newPresets);

    saveDataToPreset(id, data);
  }

  useEffect(() => {
    async function getPresets() {
      const storedPresets = await storage.get('podlauncher_presetlist');
      if (Array.isArray(storedPresets)) {
        setPresets(storedPresets);
      } else {
        setPresets([]);
      }
    }

    getPresets();
  }, []);

  return (
    <Section
      buttons={
        <PresetButtons
          deletePreset={deletePreset}
          editing={editing}
          loadPreset={loadPreset}
          presetId={presetID}
          setEditing={setEditing}
        />
      }
      fill
      scrollable
      title="Presets"
    >
      {editing && (
        <Stack vertical>
          <Stack.Item>
            <Input autoFocus onChange={setName} placeholder="Preset Name" />
            <Button
              icon="check"
              inline
              onClick={() => {
                newPreset(name, hue, data);
                setEditing(false);
              }}
              tooltip="Confirm"
              tooltipPosition="right"
            />
            <Button
              icon="window-close"
              inline
              onClick={() => {
                setName('');
                setEditing(false);
              }}
              tooltip="Cancel"
            />
          </Stack.Item>
          <Stack.Item>
            <span color="label"> Hue: </span>
            <NumberInput
              animated
              maxValue={360}
              minValue={0}
              onChange={(value) => setHue(value)}
              step={5}
              stepPixelSize={5}
              value={hue}
              width="40px"
            />
            <Stack.Item
              inline
              backgroundColor={`hsl(${hue}, 50%, 50%)`}
              width="20px"
              height="20px"
              verticalAlign="middle"
            />
          </Stack.Item>
          <Divider />
        </Stack>
      )}

      {(!presets || presets.length === 0) && (
        <span style={POD_GREY}>
          Click [+] to define a new preset. They are persistent across
          rounds/servers!
        </span>
      )}
      {Array.isArray(presets) &&
        presets.map((preset, i) => (
          <Button
            backgroundColor={`hsl(${preset.hue}, 50%, 50%)`}
            key={i}
            onClick={() => setPresetID(preset.id)}
            onDoubleClick={() => loadPreset(preset.id)}
            style={
              presetID === preset.id
                ? {
                    borderWidth: '1px',
                    borderStyle: 'solid',
                    borderColor: `hsl(${preset.hue}, 80%, 80%)`,
                  }
                : {}
            }
            width="100%"
          >
            {preset.title}
          </Button>
        ))}
      <span style={POD_GREY}>
        <br />
        <br />
        NOTE: Custom sounds from outside the base game files will not save! :(
      </span>
    </Section>
  );
}

type PresetButtonsProps = {
  deletePreset: (id: string) => void;
  editing: boolean;
  loadPreset: (id: string) => void;
  presetId: string;
  setEditing: (status: boolean) => void;
};

function PresetButtons(props: PresetButtonsProps) {
  const { data } = useBackend<PodLauncherData>();
  const { editing, deletePreset, loadPreset, presetId, setEditing } = props;

  return (
    <>
      {!editing && (
        <Button
          color="transparent"
          icon="plus"
          onClick={() => setEditing(!editing)}
          tooltip="New Preset"
        />
      )}
      <Button
        color="transparent"
        icon="download"
        inline
        onClick={() => saveDataToPreset(presetId, data)}
        tooltip="Saves preset"
        tooltipPosition="bottom"
      />
      <Button
        color="transparent"
        icon="upload"
        inline
        onClick={() => {
          loadPreset(presetId);
        }}
        tooltip="Loads preset"
      />
      <Button
        color="transparent"
        icon="trash"
        inline
        onClick={() => deletePreset(presetId)}
        tooltip="Deletes the selected preset"
        tooltipPosition="bottom-start"
      />
    </>
  );
}
