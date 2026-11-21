import { type ReactNode, useState } from 'react';
import { Button, Stack } from 'tgui-core/components';
import { clamp } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';
import { NtosWindow } from '../../layouts';
import { SpriteEditor } from '../common/SpriteEditor';
import {
  type ServerColorData,
  SpriteEditorColorMode,
  type SpriteEditorData,
} from '../common/SpriteEditor/Types/types';
import { NanopaintConfirmDialog } from './dialogs/NanopaintConfirmDialog';
import { NanopaintErrorDialog } from './dialogs/NanopaintErrorDialog';
import { NanopaintNewDialog } from './dialogs/NanopaintNewDialog';
import { NanopaintSelectDialog } from './dialogs/NanopaintSelectDialog';
import { NanopaintMenuBar } from './NanopaintMenuBar';
import type { NanopaintData } from './types';
import { useNtos } from '../NtosCore';

const isWorkspaceOpen = (
  workspaceOpen: BooleanLike,
  data: ServerColorData,
): data is Required<ServerColorData> & SpriteEditorData => !!workspaceOpen;

export const NtosNanopaint = (props) => {
  const { act, data } = useNtos<NanopaintData>();
  const {
    templateSizes,
    saveableTypes,
    editorData,
    workspaceOpen,
    driveFiles,
    diskFiles,
    minSize,
    maxSize,
    dialog,
    diskInserted,
  } = data;

  const hasEditorData = isWorkspaceOpen(workspaceOpen, editorData);

  const {
    onSelectServerColor,
    serverSelectedColor,
    onAddServerColor,
    onRemoveServerColor,
    serverPalette,
    maxServerColors,
  } = editorData;
  const {
    undoStack = [],
    redoStack = [],
    sprite,
    toolFlags,
  } = hasEditorData ? editorData : {};
  const { width = 0, height = 0 } = sprite ?? {};

  const [showGrid, setShowGrid] = useState(false);
  const [zoom, setZoom] = useState(1);

  let dialogNode: ReactNode;
  switch (dialog?.type) {
    case 'new': {
      dialogNode = (
        <NanopaintNewDialog {...{ act, minSize, maxSize, templateSizes }} />
      );
      break;
    }
    case 'select': {
      const { title, confirmText, action } = dialog;
      dialogNode = (
        <NanopaintSelectDialog
          {...{
            act,
            title,
            confirmText,
            action,
            saveableTypes,
            driveFiles,
            diskFiles,
            diskInserted,
          }}
        />
      );
      break;
    }
    case 'confirm': {
      const { title, message, action, params } = dialog;
      dialogNode = (
        <NanopaintConfirmDialog {...{ act, title, message, action, params }} />
      );
      break;
    }
    case 'error': {
      const { message } = dialog;
      dialogNode = <NanopaintErrorDialog act={act} message={message} />;
      break;
    }
  }

  SpriteEditor.syncBackend(onSelectServerColor, serverSelectedColor);

  return (
    <NtosWindow width={1280} height={720}>
      <NtosWindow.Content>
        {dialogNode}
        <Stack fill vertical>
          <Stack.Item>
            <NanopaintMenuBar
              act={act}
              undoHistory={undoStack}
              redoHistory={redoStack}
              workspaceOpen={workspaceOpen}
              zoom={zoom}
              maxZoom={20}
              minZoom={1}
              setZoom={setZoom}
            />
          </Stack.Item>
          <Stack.Item>
            {hasEditorData ? (
              <Stack>
                <Stack.Item>
                  <SpriteEditor.Toolbar toolFlags={toolFlags} />
                </Stack.Item>
                <Stack.Item>
                  <SpriteEditor.Undo act={act} stack={undoStack} />
                </Stack.Item>
                <Stack.Item>
                  <SpriteEditor.Redo act={act} stack={redoStack} />
                </Stack.Item>
                <Stack.Item>
                  <Button.Checkbox
                    checked={showGrid}
                    onClick={() => setShowGrid(!showGrid)}
                  >
                    Show Grid
                  </Button.Checkbox>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="search-minus"
                    tooltip="Zoom Out (Shift + Scroll Down)"
                    disabled={!workspaceOpen || zoom <= 1}
                    onClick={() => setZoom(zoom - 1)}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="search-plus"
                    tooltip="Zoom In (Shift + Scroll Up)"
                    disabled={!workspaceOpen || zoom >= 20}
                    onClick={() => setZoom(zoom + 1)}
                  />
                </Stack.Item>
              </Stack>
            ) : (
              <Stack fill />
            )}
          </Stack.Item>
          <Stack.Item grow shrink maxHeight="calc(100% - 5.4rem)">
            <Stack fill maxHeight="100%">
              <Stack.Item>
                <Stack vertical width="420px">
                  <Stack.Item>
                    <SpriteEditor.ColorPicker
                      act={act}
                      colorMode={SpriteEditorColorMode.Rgba}
                      hslWidth="33%"
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <SpriteEditor.Palette
                      {...{
                        act,
                        onAddServerColor,
                        onRemoveServerColor,
                        serverPalette,
                        maxServerColors,
                      }}
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              {hasEditorData && (
                <>
                  <Stack.Item
                    width="100%"
                    height="100%"
                    textAlign="center"
                    onWheel={(ev) => {
                      if (!ev.shiftKey) return;
                      ev.preventDefault();
                      setZoom(clamp(zoom - Math.sign(ev.deltaY), 1, 20));
                    }}
                    overflow="scroll"
                  >
                    <SpriteEditor.Canvas
                      act={act}
                      height={`${height * zoom}px`}
                      width={`${width * zoom}px`}
                      data={sprite!}
                      showGrid={showGrid}
                      position="relative"
                      top={`max(50% - ${(height * zoom) / 2}px, 0px)`}
                    />
                  </Stack.Item>
                  <Stack.Item height="100%">
                    <SpriteEditor.LayerManager
                      height="100%"
                      act={act}
                      data={sprite!}
                    />
                  </Stack.Item>
                </>
              )}
            </Stack>
          </Stack.Item>
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
