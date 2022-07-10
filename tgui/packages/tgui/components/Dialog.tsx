/**
 * @file
 * @copyright 2022 raffclar
 * @license MIT
 */
import { Box } from './Box';
import { Button } from './Button';
import { useLocalState } from '../backend';
import { Input } from './Input';
import { Icon } from './Icon';

type DialogProps = {
  title: string;
  close: () => void;
  children: any;
  width?: string;
  height?: string;
};

export const Dialog = (props: DialogProps) => {
  const { title, close, children, width, height } = props;
  return (
    <div className="Dialog">
      <Box className="Dialog__content" width={width || '370px'} height={height}>
        <div className="Dialog__header">
          <div className="Dialog__title">{title}</div>
          <Box mr={2}>
            <Button
              mr="-3px"
              width="26px"
              lineHeight="22px"
              textAlign="center"
              color="transparent"
              icon="window-close-o"
              tooltip="Close"
              tooltipPosition="bottom-start"
              onClick={close}
            />
          </Box>
        </div>
        {children}
      </Box>
    </div>
  );
};

type DialogButtonProps = {
  onClick: () => void;
  children: any;
};

const DialogButton = (props: DialogButtonProps) => {
  const { onClick, children } = props;
  return (
    <Button
      onClick={onClick}
      className="Dialog__button"
      verticalAlignContent="middle">
      {children}
    </Button>
  );
};

Dialog.Button = DialogButton;

type UnsavedChangesDialogProps = {
  documentName: string;
  onSave: () => void;
  onDiscard: () => void;
  onClose: () => void;
};

export const UnsavedChangesDialog = (props: UnsavedChangesDialogProps) => {
  const { documentName, onSave, onDiscard, onClose } = props;
  return (
    <Dialog title="Notepad" close={close}>
      <div className="Dialog__body">
        Do you want to save changes to {documentName}?
      </div>
      <div className="Dialog__footer">
        <DialogButton onClick={onSave}>Save</DialogButton>
        <DialogButton onClick={onDiscard}>Don&apos;t Save</DialogButton>
        <DialogButton onClick={onClose}>Cancel</DialogButton>
      </div>
    </Dialog>
  );
};

type FileEntryProps = {
  name: string;
};

const FileEntry = (props: FileEntryProps) => {
  const { name } = props;
  return (
    <Box className='Dialog__FileEntry'>
      <Icon name='file' size='2' className='Dialog__FileIcon' />
      <div>{name}</div>
    </Box>
  );
}

type FileListProps = {
  files: string[];
}

const FileList = (props: FileListProps) => {
  const {files} = props;
  return (
    <Box className='Dialog__FileList'>
      {files.map((file) => (
        <FileEntry key={file} name={file} />
      ))}
    </Box>
  );
}

type OpenAsDialogProps = {
  files: string[];
  onOpen: (documentName: string) => void;
  onClose: () => void;
}

export const OpenAsDialog = (props: OpenAsDialogProps, context) => {
  const { files, onOpen, onClose } = props;
  const [selectedDocument, setSelectedDocument] = useLocalState<string>(context, 'selectedDocument', '');

  return (
    <Dialog title="Save As" close={close} width='80%' height='50%'>
      <div className="Dialog__body">
        <FileList files={files} />
      </div>
      <div className="Dialog__footer">
        <div style={{ 'flex-direction': 'column', 'flex-grow': 1 }}>
          <div className="SaveAsDialog__inputs">
            <div>
              <DialogButton onClick={() => onOpen("AAAA")}>Open</DialogButton>
              <DialogButton onClick={onClose}>Cancel</DialogButton>
            </div>
          </div>
        </div>
      </div>
    </Dialog>
  )
};

type SaveAsDialogProps = {
  files: string[];
  newDocumentNameNeeded: boolean;
  documentName: string;
  onSave: (newDocumentName: string) => void;
  onClose: () => void;
};

export const SaveAsDialog = (props: SaveAsDialogProps, context) => {
  const { files, newDocumentNameNeeded, documentName, onSave, onClose } = props;
  const [newDocumentName, setNewDocumentName] = useLocalState<string>(
    context,
    'newDocumentName',
    documentName
  );
  const saveWithValidName = () => {
    // Prevent saving as the provided document name as a new one is needed
    const invalidName = newDocumentNameNeeded && newDocumentName === documentName;
    if (newDocumentName.length === 0 || invalidName) {
      return;
    }

    onSave(newDocumentName);
  };

  return (
    <Dialog title="Save As" close={close} width='80%' height='50%'>
      <div className="Dialog__body">
        <Box style={{ 'display': 'flex', 'flex-direction': 'row' }}>
          <FileList files={files} />
        </Box>
      </div>
      <div className="Dialog__footer">
        <div style={{ 'flex-direction': 'column', 'flex-grow': 1 }}>
          <div style={{ 'display': 'flex', 'flex-direction': 'row', 'justify-content': 'flex-end', 'margin-bottom': '1rem', 'align-items': 'center' }}>
            <label
              htmlFor="fileDialogFilename"
              className="SaveAsDialog__label">
              File name:
            </label>
            <Input
              id="fileDialogFilename"
              value={newDocumentName}
              className={'SaveAsDialog__input'}
              onChange={(e, text) => setNewDocumentName(text)}
            />
          </div>
          <div className="SaveAsDialog__inputs">
            <div>
              <DialogButton onClick={saveWithValidName}>Save</DialogButton>
              <DialogButton onClick={onClose}>Cancel</DialogButton>
            </div>
          </div>
        </div>
      </div>
    </Dialog>
  );
};
