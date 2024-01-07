import { storage } from 'common/storage';
import { createUuid } from 'common/uuid';
import { Component, useState } from 'react';

import { useBackend } from '../../backend';
import { Button, Divider, Input, NumberInput, Section } from '../../components';
import { POD_GREY } from './constants';

type State = {
  presets: any[];
};

export class PresetsPage extends Component<any, State> {
  constructor(props) {
    super(props);
    this.state = {
      presets: [],
    };
  }

  async componentDidMount() {
    // This warning is generally considered OK to ignore in this context
    // eslint-disable-next-line react/no-did-mount-set-state
    this.setState({
      presets: await this.getPresets(),
    });
  }

  saveDataToPreset(id, data) {
    storage.set('podlauncher_preset_' + id, data);
  }

  async loadDataFromPreset(id) {
    const { act } = useBackend();
    act('loadDataFromPreset', {
      payload: await storage.get('podlauncher_preset_' + id),
    });
  }

  newPreset(presetName, hue, data) {
    let { presets } = this.state;
    if (!presets) {
      presets = [];
      presets.push('hi!');
    }
    const id = createUuid();
    const thing = { id, title: presetName, hue };
    presets.push(thing);
    storage.set('podlauncher_presetlist', presets);
    this.saveDataToPreset(id, data);
  }

  async getPresets() {
    let thing = await storage.get('podlauncher_presetlist');
    if (thing === undefined) {
      thing = [];
    }
    return thing;
  }

  deletePreset(deleteID) {
    const { presets } = this.state;
    for (let i = 0; i < presets.length; i++) {
      if (presets[i].id === deleteID) {
        presets.splice(i, 1);
        break;
      }
    }
    storage.set('podlauncher_presetlist', presets);
  }
  render() {
    const { presets } = this.state;
    const { data } = useBackend();
    const [presetIndex, setSelectedPreset] = useState(0);
    const [settingName, setEditingNameStatus] = useState(0);
    const [newNameText, setText] = useState('');
    const [hue, setHue] = useState(0);

    return (
      <Section
        scrollable
        fill
        title="Presets"
        buttons={
          <>
            {settingName === 0 && (
              <Button
                color="transparent"
                icon="plus"
                tooltip="New Preset"
                onClick={() => setEditingNameStatus(1)}
              />
            )}
            <Button
              inline
              color="transparent"
              icon="download"
              tooltip="Saves preset"
              tooltipPosition="bottom"
              onClick={() => this.saveDataToPreset(presetIndex, data)}
            />
            <Button
              inline
              color="transparent"
              icon="upload"
              tooltip="Loads preset"
              onClick={() => {
                this.loadDataFromPreset(presetIndex);
              }}
            />
            <Button
              inline
              color="transparent"
              icon="trash"
              tooltip="Deletes the selected preset"
              tooltipPosition="bottom-start"
              onClick={() => this.deletePreset(presetIndex)}
            />
          </>
        }
      >
        {settingName === 1 && (
          <>
            <Button
              inline
              icon="check"
              tooltip="Confirm"
              tooltipPosition="right"
              onClick={() => {
                this.newPreset(newNameText, hue, data);
                setEditingNameStatus(0);
              }}
            />
            <Button
              inline
              icon="window-close"
              tooltip="Cancel"
              onClick={() => {
                setText('');
                setEditingNameStatus(0);
              }}
            />
            <span color="label"> Hue: </span>
            <NumberInput
              inline
              animated
              width="40px"
              step={5}
              stepPixelSize={5}
              value={hue}
              minValue={0}
              maxValue={360}
              onChange={(e, value) => setHue(value)}
            />
            <Input
              inline
              autoFocus
              placeholder="Preset Name"
              onChange={(e, value) => setText(value)}
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
            key={i}
            width="100%"
            backgroundColor={`hsl(${preset.hue}, 50%, 50%)`}
            onClick={() => setSelectedPreset(preset.id)}
            onDoubleClick={() => this.loadDataFromPreset(preset.id)}
            style={
              presetIndex === preset.id
                ? {
                    borderWidth: '1px',
                    borderStyle: 'solid',
                    borderColor: `hsl(${preset.hue}, 80%, 80%)`,
                  }
                : ''
            }
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
}
