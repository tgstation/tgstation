/**
 * @file
 * @copyright 2022 raffclar
 * @license MIT
 */
import { Box } from './Box';
import { Button } from './Button';
import { useLocalState } from '../backend';
import { Input } from './Input';
import { LabeledList } from './LabeledList';
import { Icon } from './Icon';

type DialogProps = {
  title: string;
  close: () => void;
  children: any;
  width?: string;
};

export const Dialog = (props: DialogProps) => {
  const { title, close, children, width } = props;
  return (
    <div className="Dialog">
      <Box className="Dialog__content" width={width || '370px'}>
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
  save: () => void;
  noSave: () => void;
  close: () => void;
};

export const UnsavedChangesDialog = (props: UnsavedChangesDialogProps) => {
  const { documentName, save, noSave, close } = props;
  return (
    <Dialog title="Notepad" close={close}>
      <div className="Dialog__body">
        Do you want to save changes to {documentName}?
      </div>
      <div className="Dialog__footer">
        <DialogButton onClick={save}>Save</DialogButton>
        <DialogButton onClick={noSave}>Don&apos;t Save</DialogButton>
        <DialogButton onClick={close}>Cancel</DialogButton>
      </div>
    </Dialog>
  );
};

type SaveAsDialogProps = {
  newDocumentNameNeeded: boolean;
  documentName: string;
  save: (newDocumentName: string) => void;
  close: () => void;
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

const DirectoryList = () => {
  return (
    <Box style={{ 'min-width': '5rem', 'max-width': '10rem', 'overflow-x': 'hidden', 'overflow-y': 'auto', 'border-right': '1px solid black' }}>
      <ol style={{ 'list-style': 'none', 'margin': '0', 'padding': '0' }}>
        <li style={{ 'word-wrap': 'nowrap' }} >My PDA</li>
        <li style={{ 'word-wrap': 'nowrap' }} >WIP</li>
        <li style={{ 'word-wrap': 'nowrap' }} >Etc</li>
      </ol>
    </Box>
  )
}

const FileList = () => {
  return (
    <Box className='Dialog__FileList'>
      <FileEntry name='note_0.txt' />
      <FileEntry name='note_1.txt' />
      <FileEntry name='note_2.txt' />
      <FileEntry name='note_3.txt' />
      <FileEntry name='note_0.txt' />
      <FileEntry name='note_1.txt' />
      <FileEntry name='note_2.txt' />
      <FileEntry name='note_3.txt' />
      <FileEntry name='note_1.txt' />
      <FileEntry name='note_2.txt' />
      <FileEntry name='note_3.txt' />
      <FileEntry name='note_1.txt' />
      <FileEntry name='note_2.txt' />
      <FileEntry name='note_3.txt' />
      <FileEntry name='note_0.txt' />
      <FileEntry name='note_1.txt' />
      <FileEntry name='note_2.txt' />
      <FileEntry name='note_3.txt' />
      <FileEntry name='note_0.txt' />
      <FileEntry name='note_1.txt' />
      <FileEntry name='note_2.txt' />
      <FileEntry name='note_3.txt' />
      <FileEntry name='note_1.txt' />
      <FileEntry name='note_2.txt' />
      <FileEntry name='note_3.txt' />
      <FileEntry name='note_1.txt' />
      <FileEntry name='note_2.txt' />
      <FileEntry name='note_3.txt' />
    </Box>
  )
}

export const SaveAsDialog = (props: SaveAsDialogProps, context) => {
  const { newDocumentNameNeeded, documentName, save, close } = props;
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

    save(newDocumentName);
  };

  return (
    <Dialog title="Save As" close={close} width='80%'>
      <div className="Dialog__body">
        <Box style={{ 'display': 'flex', 'flex-direction': 'row' }}>
          <DirectoryList />
          <FileList />
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
              <DialogButton onClick={close}>Cancel</DialogButton>
            </div>
          </div>
        </div>
      </div>
    </Dialog>
  );
};
