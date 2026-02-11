import type { ReactNode } from 'react';
import { Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';
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

const isWorkspaceOpen = (
  workspaceOpen: BooleanLike,
  data: ServerColorData,
): data is Required<ServerColorData> & SpriteEditorData => !!workspaceOpen;

export const NtosNanopaint = (props) => {
  const { data } = useBackend<NanopaintData>();
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

  let dialogNode: ReactNode;
  switch (dialog?.type) {
    case 'new': {
      dialogNode = (
        <NanopaintNewDialog {...{ minSize, maxSize, templateSizes }} />
      );
      break;
    }
    case 'select': {
      const { title, confirmText, selectAct } = dialog;
      dialogNode = (
        <NanopaintSelectDialog
          {...{
            title,
            confirmText,
            selectAct,
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
      const { title, message, confirmAct, params } = dialog;
      dialogNode = (
        <NanopaintConfirmDialog {...{ title, message, confirmAct, params }} />
      );
      break;
    }
    case 'error': {
      const { message } = dialog;
      dialogNode = <NanopaintErrorDialog message={message} />;
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
              undoHistory={undoStack}
              redoHistory={redoStack}
              workspaceOpen={workspaceOpen}
            />
          </Stack.Item>
          <Stack.Item>
            {hasEditorData ? (
              <Stack>
                <Stack.Item>
                  <SpriteEditor.Toolbar toolFlags={toolFlags} />
                </Stack.Item>
              </Stack>
            ) : (
              <Stack fill />
            )}
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill height="100%">
              <Stack.Item maxWidth="33%">
                <Stack vertical>
                  <Stack.Item>
                    <SpriteEditor.ColorPicker
                      colorMode={SpriteEditorColorMode.Rgba}
                      hslWidth="33%"
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <SpriteEditor.Palette
                      {...{
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
                  <Stack.Item grow height="100%">
                    <SpriteEditor.Canvas
                      height="100%"
                      width="100%"
                      data={sprite!}
                    />
                  </Stack.Item>
                  <Stack.Item height="100%">
                    <SpriteEditor.LayerManager height="100%" data={sprite!} />
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
