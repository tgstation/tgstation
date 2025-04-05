import { useState } from 'react';
import { Box, Button, Modal, Stack } from 'tgui-core/components';

import { useBackend } from '../../../../backend';
import { SpriteEditorContext } from '../../../SpriteEditor/Context';
import { PreferencesMenuData } from '../../types';

export const IconEditingModal = (props) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { editingIcon, workspaceData } = data;
  const [showGrid, setShowGrid] = useState(false);
  if (!workspaceData) {
    return undefined;
  }
  const { undoStack, redoStack, sprite } = workspaceData;
  return editingIcon ? (
    <Modal backgroundColor="#00000000">
      <SpriteEditorContext.Root>
        <Box width="100vw" height="100vh">
          <Box
            position="absolute"
            top="calc(50vh - 200px)"
            left="250px"
            width="600px"
            height="400px"
            backgroundColor="hsl(0, 0%, 14%)"
            p="0.5rem"
          >
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
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Stack justify="flex-end">
                  <Stack.Item>
                    <Button onClick={() => act('stop_editing_pref')}>
                      Cancel
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button.Confirm onClick={() => act('save_pref')}>
                      Save
                    </Button.Confirm>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Box>
        </Box>
      </SpriteEditorContext.Root>
    </Modal>
  ) : undefined;
};
