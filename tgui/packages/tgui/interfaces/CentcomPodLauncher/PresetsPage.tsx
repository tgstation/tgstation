import { storage } from 'common/storage';
import { createUuid } from 'common/uuid';
import { useEffect, useState } from 'react';

import { useBackend } from '../../backend';
import { Button, Divider, Input, NumberInput, Section } from '../../components';
import { POD_GREY } from './constants';
import { PodLauncherData } from './types';

type Preset = {
  id: number;
  title: string;
  hue: number;
};

async function saveDataToPreset(id: string, data: any) {
  await storage.set('podlauncher_preset_' + id, data);
}

export function PresetsPage(props) {
  const { act, data } = useBackend();

  const [editingName, setEditingName] = useState(false);
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
          loadPreset={loadPreset}
          presetIndex={presetID}
          setEditingNameStatus={setEditingName}
          settingName={editingName}
        />
      }
      fill
      scrollable
      title="Presets"
    >
      {editingName && (
        <>
          <Button
            icon="check"
            inline
            onClick={() => {
              newPreset(name, hue, data);
              setEditingName(false);
            }}
            tooltip="Confirm"
            tooltipPosition="right"
          />
          <Button
            icon="window-close"
            inline
            onClick={() => {
              setName('');
              setEditingName(false);
            }}
            tooltip="Cancel"
          />
          <span color="label"> Hue: </span>
          <NumberInput
            animated
            inline
            maxValue={360}
            minValue={0}
            onChange={(e, value) => setHue(value)}
            step={5}
            stepPixelSize={5}
            value={hue}
            width="40px"
          />
          <Input
            autoFocus
            inline
            onChange={(e, value) => setName(value)}
            placeholder="Preset Name"
          />
          <Divider />
        </>
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
  loadPreset: (id: number) => void;
  presetIndex: number;
  setEditingNameStatus: (status: boolean) => void;
  settingName: boolean;
};

function PresetButtons(props: PresetButtonsProps) {
  const { data } = useBackend<PodLauncherData>();
  const {
    deletePreset,
    loadPreset,
    presetIndex,
    setEditingNameStatus,
    settingName,
  } = props;

  return (
    <>
      {!settingName && (
        <Button
          color="transparent"
          icon="plus"
          onClick={() => setEditingNameStatus(false)}
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
