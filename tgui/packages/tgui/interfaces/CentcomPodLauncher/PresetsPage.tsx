import { storage } from 'common/storage';
import { createUuid } from 'common/uuid';
import { useEffect, useState } from 'react';

import { useBackend } from '../../backend';
import {
  Button,
  Divider,
  Input,
  NumberInput,
  Section,
  Stack,
} from '../../components';
import { POD_GREY } from './constants';
import { PodLauncherData } from './types';

type Preset = {
  hue: number;
  id: number;
  title: string;
};

async function saveDataToPreset(id: string, data: any) {
  await storage.set('podlauncher_preset_' + id, data);
}

export function PresetsPage(props) {
  const { act, data } = useBackend();

  const [editing, setEditing] = useState(false);
  const [hue, setHue] = useState(0);
  const [name, setName] = useState('');
  const [presetID, setPresetID] = useState(0);
  const [presets, setPresets] = useState<Preset[]>([]);

  async function deletePreset(deleteID: number) {
    const newPresets: any[] = [...presets];
    for (let i = 0; i < presets.length; i++) {
      if (presets[i].id === deleteID) {
        newPresets.splice(i, 1);
        break;
      }
    }
    await storage.set('podlauncher_presetlist', presets);
  }

  async function loadPreset(id) {
    act('loadDataFromPreset', {
      payload: await storage.get('podlauncher_preset_' + id),
    });
  }

  async function newPreset(presetName: string, hue: number, data: any) {
    const newPresets: any[] = [...presets];

    if (!presets) {
      newPresets.push('hi!');
    }
    const id = createUuid();
    const thing = { id, title: presetName, hue };
    newPresets.push(thing);
    await storage.set('podlauncher_presetlist', presets);

    saveDataToPreset(id, data);
  }

  useEffect(() => {
    async function getPresets() {
      let thing = await storage.get('podlauncher_presetlist');
      if (thing === undefined) {
        thing = [];
      }
      setPresets(thing);
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
          presetIndex={presetID}
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
            <Input
              autoFocus
              onChange={(e, value) => setName(value)}
              placeholder="Preset Name"
            />
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
      {presets.map((preset, i) => (
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
              : ''
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
  deletePreset: (id: number) => void;
  editing: boolean;
  loadPreset: (id: number) => void;
  presetIndex: number;
  setEditing: (status: boolean) => void;
};

function PresetButtons(props: PresetButtonsProps) {
  const { data } = useBackend<PodLauncherData>();
  const { editing, deletePreset, loadPreset, presetIndex, setEditing } = props;

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
        onClick={() => saveDataToPreset(presetIndex.toString(), data)}
        tooltip="Saves preset"
        tooltipPosition="bottom"
      />
      <Button
        color="transparent"
        icon="upload"
        inline
        onClick={() => {
          loadPreset(presetIndex);
        }}
        tooltip="Loads preset"
      />
      <Button
        color="transparent"
        icon="trash"
        inline
        onClick={() => deletePreset(presetIndex)}
        tooltip="Deletes the selected preset"
        tooltipPosition="bottom-start"
      />
    </>
  );
}
