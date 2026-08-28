import { useState } from 'react';
import {
  Button,
  Collapsible,
  Divider,
  Input,
  LabeledList,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import { capitalize } from 'tgui-core/string';
import { chatRenderer } from '../chat/renderer';
import { FONTS, THEMES } from './constants';
import { resetPaneSplitters, setEditPaneSplitters } from './scaling';
import { exportChatSettings, importChatSettings } from './settingsImExport';
import { useSettings } from './use-settings';

export function SettingsGeneral(props) {
  const { settings, updateSettings } = useSettings();
  const [freeFont, setFreeFont] = useState(false);

  const [editingPanes, setEditingPanes] = useState(false);

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Theme">
          {THEMES.map((THEME) => (
            <Button
              key={THEME}
              selected={settings.theme === THEME}
              color="transparent"
              onClick={() =>
                updateSettings({
                  theme: THEME,
                })
              }
            >
              {capitalize(THEME)}
            </Button>
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="UI sizes">
          <Stack>
            <Stack.Item>
              <Button
                onClick={() =>
                  setEditingPanes((val) => {
                    setEditPaneSplitters(!val);
                    return !val;
                  })
                }
                color={editingPanes ? 'red' : undefined}
                icon={editingPanes ? 'save' : undefined}
              >
                {editingPanes ? 'Save' : 'Adjust UI Sizes'}
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button onClick={resetPaneSplitters} icon="refresh" color="red">
                Reset
              </Button>
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
        <LabeledList.Item label="Font style">
          <Stack.Item>
            {!freeFont ? (
              <Collapsible
                title={settings.fontFamily}
                width="100%"
                buttons={
                  <Button
                    icon={freeFont ? 'lock-open' : 'lock'}
                    color={freeFont ? 'good' : 'bad'}
                    onClick={() => {
                      setFreeFont(!freeFont);
                    }}
                  >
                    Custom font
                  </Button>
                }
              >
                {FONTS.map((FONT) => (
                  <Button
                    key={FONT}
                    fontFamily={FONT}
                    selected={settings.fontFamily === FONT}
                    color="transparent"
                    onClick={() =>
                      updateSettings({
                        fontFamily: FONT,
                      })
                    }
                  >
                    {FONT}
                  </Button>
                ))}
              </Collapsible>
            ) : (
              <Stack>
                <Input
                  fluid
                  value={settings.fontFamily}
                  onBlur={(value) =>
                    updateSettings({
                      fontFamily: value,
                    })
                  }
                />
                <Button
                  ml={0.5}
                  icon={freeFont ? 'lock-open' : 'lock'}
                  color={freeFont ? 'good' : 'bad'}
                  onClick={() => {
                    setFreeFont(!freeFont);
                  }}
                >
                  Custom font
                </Button>
              </Stack>
            )}
          </Stack.Item>
        </LabeledList.Item>
        <LabeledList.Item label="Font size" verticalAlign="middle">
          <Stack textAlign="center">
            <Stack.Item grow>
              <Slider
                width="100%"
                step={1}
                stepPixelSize={20}
                minValue={8}
                maxValue={32}
                value={settings.fontSize}
                unit="px"
                format={(value) => toFixed(value)}
                onChange={(e, value) => updateSettings({ fontSize: value })}
              />
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
        <LabeledList.Item label="Line height">
          <Slider
            width="100%"
            step={0.01}
            minValue={0.8}
            maxValue={5}
            value={settings.lineHeight}
            format={(value) => toFixed(value, 2)}
            onChange={(e, value) =>
              updateSettings({
                lineHeight: value,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <Stack fill>
        <Stack.Item mt={0.15}>
          <Button
            icon="compact-disc"
            tooltip="Export chat settings"
            onClick={exportChatSettings}
          >
            Export settings
          </Button>
        </Stack.Item>
        <Stack.Item mt={0.15}>
          <Button.File
            accept=".json"
            tooltip="Import chat settings"
            icon="arrow-up-from-bracket"
            onSelectFiles={importChatSettings}
          >
            Import settings
          </Button.File>
        </Stack.Item>
        <Stack.Item grow mt={0.15}>
          <Button
            icon="save"
            tooltip="Export current tab history into HTML file"
            onClick={() => chatRenderer.saveToDisk()}
          >
            Save chat log
          </Button>
        </Stack.Item>
        <Stack.Item mt={0.15}>
          <Button.Confirm
            icon="trash"
            tooltip="Erase current tab history"
            onClick={() => chatRenderer.clearChat()}
          >
            Clear chat
          </Button.Confirm>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
