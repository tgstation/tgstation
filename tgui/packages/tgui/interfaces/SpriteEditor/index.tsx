import React, { useState } from 'react';
import { Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { LayerManager } from './Components/LayerManager';
import { useSpriteEditorContext } from './Context';
import { Icon } from './Types/Icon';
import { Workspace } from './Types/Workspace';

export const SpriteEditor = () => {
  const { act } = useBackend();
  const [workspace] = useState(() => new Workspace(new Icon(32, 32, 4)));
  const {
    colorPicker: ColorPicker,
    palette: Palette,
    toolbar: Toolbar,
    canvas: Canvas,
    undoButton: UndoButton,
    redoButton: RedoButton,
  } = useSpriteEditorContext();
  return (
    <Window width={1200} height={675}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Stack fill backgroundColor="rgba(0, 0, 0, 33%)">
              <Stack.Item grow />
              <Stack.Item>
                <Stack>
                  <Stack.Item>
                    <UndoButton workspace={workspace} />
                  </Stack.Item>
                  <Stack.Item>
                    <RedoButton workspace={workspace} />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Divider />
              <Stack.Item>
                <Toolbar perButtonProps={(tool) => ({ tooltip: tool.name })} />
              </Stack.Item>
              <Stack.Item grow />
            </Stack>
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item grow>
                <Stack fill vertical>
                  <Stack.Item>
                    <ColorPicker height="275px" hslWidth="33%" alpha />
                  </Stack.Item>
                  <Stack.Item>
                    <Palette
                      paletteButtonProps={{
                        width: '2rem',
                        height: '2rem',
                      }}
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item align="stretch" grow>
                <Canvas width="100%" height="100%" workspace={workspace} />
              </Stack.Item>
              <Stack.Item align="stretch" basis="min-content">
                <LayerManager
                  width="100%"
                  height="100%"
                  workspace={workspace}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
