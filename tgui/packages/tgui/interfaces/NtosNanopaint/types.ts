import type { BooleanLike } from 'tgui-core/react';
import type {
  ServerColorData,
  SpriteEditorData,
} from '../common/SpriteEditor/Types/types';

export type NanopaintFileEntry = {
  name: string;
  extension: string;
  uid: number;
  baseType: string;
};

export type NanopaintNewDialogData = {
  type: 'new';
};

export type NanopaintFileDialogData = {
  type: 'select';
  title: string;
  confirmText: string;
  action: string;
};

export type NanopaintConfirmDialogData = {
  type: 'confirm';
  title: string;
  message: string;
  action: string;
  params: Record<string, unknown>;
};

export type NanopaintErrorDialogData = {
  type: 'error';
  message: string;
};

export type NanopaintDialogData =
  | NanopaintNewDialogData
  | NanopaintFileDialogData
  | NanopaintConfirmDialogData
  | NanopaintErrorDialogData;

export type NanopaintData = {
  templateSizes: Record<string, [number, number]>;
  saveableTypes: { displayText: string; typepath: string; extension: string }[];
  editorData:
    | Required<ServerColorData>
    | (Required<ServerColorData> & SpriteEditorData);
  workspaceOpen: BooleanLike;
  driveFiles: NanopaintFileEntry[];
  diskFiles: NanopaintFileEntry[];
  minSize: number;
  maxSize: number;
  dialog?: NanopaintDialogData;
  diskInserted: BooleanLike;
};
