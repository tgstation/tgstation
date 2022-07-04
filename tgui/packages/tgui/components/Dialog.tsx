/**
 * @file
 * @copyright 2022 raffclar
 * @license MIT
 */
import { Box } from './Box';
import { Button } from './Button';
import { useLocalState } from '../backend';
import { Input } from './Input';

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
      <Box className="Dialog__content" width={width}>
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
    <Dialog title="Save As" close={close} width={'600px'}>
      <div className="Dialog__body">
        <div className="SaveAsDialog__inputs">
          <label
            htmlFor="filename"
            className="SaveAsDialog__label">
            File name:
          </label>
          <Input
            id="filename"
            value={newDocumentName}
            className={'SaveAsDialog__input'}
            onChange={(e, text) => setNewDocumentName(text)}
          />
        </div>
      </div>
      <div className="Dialog__footer">
        <DialogButton onClick={saveWithValidName}>Save</DialogButton>
        <DialogButton onClick={close}>Cancel</DialogButton>
      </div>
    </Dialog>
  );
};
