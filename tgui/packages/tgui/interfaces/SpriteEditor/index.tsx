import React, { useState } from 'react';
import { Button, Input, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { SpriteEditorContext } from './Context';
import { SpriteEditorData } from './Types/types';

export const SpriteEditor = () => {
  const { data } = useBackend<SpriteEditorData>();
  const [showGrid, setShowGrid] = useState(false);
  const [bg, setBg] = useState<string>('');
  const { undoStack, redoStack, sprite } = data;
  return (
    <Window width={1200} height={675}>
      <SpriteEditorContext.Root>
        <Window.Content>
          <Stack fill vertical>
            <Stack.Item>
              <Stack fill backgroundColor="rgba(0, 0, 0, 33%)">
                <Stack.Item grow />
                <Stack.Item>
                  <Stack>
                    <Stack.Item>
                      <SpriteEditorContext.Undo stack={undoStack} />
                    </Stack.Item>
                    <Stack.Item>
                      <SpriteEditorContext.Redo stack={redoStack} />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item>
                  <SpriteEditorContext.Toolbar
                    perButtonProps={(tool) => ({ tooltip: tool.name })}
                  />
                </Stack.Item>
                <Stack.Item grow />
                <Stack.Item>
                  <Button.Checkbox
                    checked={showGrid}
                    onClick={() => setShowGrid(!showGrid)}
                  >
                    Show Grid
                  </Button.Checkbox>
                </Stack.Item>
                <Stack.Item grow />
                <Stack.Item grow>
                  <Input
                    fluid
                    value={bg}
                    onChange={(_, value) => setBg(value)}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item grow>
              <Stack fill>
                <Stack.Item grow>
                  <Stack fill vertical>
                    <Stack.Item>
                      <SpriteEditorContext.ColorPicker
                        height="275px"
                        hslWidth="33%"
                        alpha
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <SpriteEditorContext.Palette
                        paletteButtonProps={{
                          width: '2rem',
                          height: '2rem',
                        }}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item align="stretch" grow>
                  <SpriteEditorContext.Canvas
                    width="100%"
                    height="100%"
                    data={sprite}
                    showGrid={showGrid}
                  />
                </Stack.Item>
                <Stack.Item align="stretch" basis="min-content">
                  <SpriteEditorContext.LayerManager
                    width="100%"
                    height="100%"
                    data={sprite}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Window.Content>
      </SpriteEditorContext.Root>
    </Window>
  );
};
