import {NtosWindow} from '../layouts';
import {useBackend, useLocalState} from '../backend';
import {Box, Section, TextArea, MenuBarDropdown, Button, Input} from '../components';
import {Component, InfernoNode, RefObject} from "inferno";
import {logger} from "../logging";

const DEFAULT_DOCUMENT_NAME = "Untitled";

interface PartiallyUnderlinedProps {
  str: string;
  indexStart: number;
}

const PartiallyUnderlined = (props: PartiallyUnderlinedProps) => {
  const {str, indexStart} = props;
  const start = str.substring(0, indexStart);
  const underlined = str.substring(indexStart, indexStart + 1);
  const end = indexStart < str.length - 1 ? str.substring(indexStart + 1) : "";
  return <>{start}<span style="text-decoration: underline;">{underlined}</span>{end}</>
}

enum Dialogs {
  NONE = 0,
  UNSAVED_CHANGES = 1,
  SAVE_AS = 2,
  OPEN = 3,
  ABOUT = 4,
}

type MenuBarProps = {
  openDocument: () => void;
  save: () => void;
  saveAsDialog: () => void;
  exit: () => void;
  newNote: () => void;
  cutSelected: () => void;
  copySelected: () => void;
  pasteClipboard: () => void;
  deleteSelected: () => void;
  showStatusBar: boolean;
  setShowStatusBar: (boolean) => void;
  wordWrap: boolean,
  setWordWrap: (boolean) => void,
}

const MenuBar = (props: MenuBarProps, context) => {
  const {
    openDocument,
    save,
    saveAsDialog,
    exit,
    newNote,
    cutSelected,
    copySelected,
    pasteClipboard,
    deleteSelected,
    setShowStatusBar,
    showStatusBar,
    wordWrap,
    setWordWrap,
  } = props;
  const [openOnHover, setOpenOnHover] = useLocalState(context, "openOnHover", false);
  const [openMenuBar, setOpenMenuBar] = useLocalState<string | null>(context, "openMenuBar", null);
  const onMenuItemClick = (value) => {
    setOpenOnHover(false);
    setOpenMenuBar(null);
    switch (value) {
      case "open": openDocument(); break;
      case "save": save(); break;
      case "saveAs": saveAsDialog(); break;
      case "exit": exit(); break;
      case "new": newNote(); break;
      case "cut": cutSelected(); break;
      case "copy": copySelected(); break;
      case "paste": pasteClipboard(); break;
      case "delete": deleteSelected(); break;
      case "statusBar": setShowStatusBar(!showStatusBar); break;
      case "wordWrap": setWordWrap(!wordWrap); break;
    }
  }
  const getMenuItemProps = (value: string, displayText: string) => {
    return {
      key: value,
      value,
      displayText,
      onClick: onMenuItemClick,
    };
  };
  const fileOptions = [
    <MenuBarDropdown.MenuItem {...getMenuItemProps("new", "New")} />,
    <MenuBarDropdown.MenuItem {...getMenuItemProps("open", "Open")} />,
    <MenuBarDropdown.MenuItem {...getMenuItemProps("save", "Save")} />,
    <MenuBarDropdown.MenuItem {...getMenuItemProps("saveAs", "Save As...")} />,
    <MenuBarDropdown.Separator key="firstSep"/>,
    <MenuBarDropdown.MenuItem {...getMenuItemProps("print", "Print...")} />,
    <MenuBarDropdown.Separator key="secondSep"/>,
    <MenuBarDropdown.MenuItem {...getMenuItemProps("exit", "Exit...")} />,
  ];
  const editOptions = [
    <MenuBarDropdown.MenuItem {...getMenuItemProps("cut", "Cut")} />,
    <MenuBarDropdown.MenuItem {...getMenuItemProps("copy", "Copy")} />,
    <MenuBarDropdown.MenuItem {...getMenuItemProps("paste", "Paste")} />,
    <MenuBarDropdown.MenuItem {...getMenuItemProps("delete", "Delete")} />,
  ];
  const formatOptions = [
    (
      <MenuBarDropdown.MenuItemToggle
        checked={wordWrap}
        {...getMenuItemProps("wordWrap", "Word Wrap")}
      />
    ),
  ];
  const viewOptions = [
    (
      <MenuBarDropdown.MenuItemToggle
        checked={showStatusBar}
        {...getMenuItemProps("statusBar", "Status Bar")}
      />
    ),
  ];
  const helpOptions = [
    <MenuBarDropdown.MenuItem {...getMenuItemProps("aboutNotepad", "About Notepad")} />,
  ];
  const itemProps = {
    openOnHover,
    setOpenOnHover,
    openMenuBar,
    setOpenMenuBar,
  };

  return (
    <Box className="NtosNotepad__MenuBar">
      <MenuBarDropdown
        entry="file"
        openWidth="22rem"
        display={<PartiallyUnderlined str="File" indexStart={0}/>}
        options={fileOptions}
        {...itemProps}
      />
      <MenuBarDropdown
        entry="edit"
        openWidth="22rem"
        display={<PartiallyUnderlined str="Edit" indexStart={0}/>}
        options={editOptions}
        {...itemProps}
      />
      <MenuBarDropdown
        entry="format"
        openWidth="15rem"
        display={<PartiallyUnderlined str="Format" indexStart={1}/>}
        options={formatOptions}
        {...itemProps}
      />
      <MenuBarDropdown
        entry="view"
        openWidth="15rem"
        display={<PartiallyUnderlined str="View" indexStart={0}/>}
        options={viewOptions}
        {...itemProps}
      />
      <MenuBarDropdown
        entry="help"
        openWidth="17rem"
        display={<PartiallyUnderlined str="Help" indexStart={0}/>}
        options={helpOptions}
        {...itemProps}
      />
    </Box>
  );
};

interface StatusBarProps {
  statuses: Statuses
}

const StatusBar = (props: StatusBarProps) => {
  const {statuses} = props;
  return (
    <Box className="NtosNotepad__StatusBar">
      <Box className="NtosNotepad__StatusBar__entry" minWidth="15rem">Ln {statuses.line}, Col {statuses.column}</Box>
      <Box className="NtosNotepad__StatusBar__entry" minWidth="5rem">100%</Box>
      <Box className="NtosNotepad__StatusBar__entry" minWidth="12rem">NtOS (LF)</Box>
      <Box className="NtosNotepad__StatusBar__entry" minWidth="12rem">UTF-8</Box>
    </Box>
  )
}

function getStatusCounts(text: string, selectionStart: number): Statuses {
  const lines = text.substr(0, selectionStart).split("\n");
  return {
    line: lines.length,
    column: lines[lines.length - 1].length + 1,
  };
}

type Statuses = {
  line: number;
  column: number;
}

const TEXTAREA_UPDATE_TRIGGERS = [
  "click",
  "input",
  "paste",
  "cut",
  "mousemove",
  "select",
  "selectstart",
  "keydown",
];

interface NotePadTextAreaProps {
  maintainFocus: boolean;
  text: string;
  wordWrap: boolean;
  setText: (string) => void;
  setStatuses: (statuses: Statuses) => void;
}

class NotePadTextArea extends Component<NotePadTextAreaProps, { textAreaRef: RefObject<HTMLTextAreaElement> }> {
  textAreaRef: RefObject<HTMLTextAreaElement>;

  constructor(props) {
    super(props);
  }

  handleEvent(event: Event) {
    const area = event.target as HTMLTextAreaElement;
    this.props.setStatuses(getStatusCounts(area.value, area.selectionStart));
  }

  onblur() {
    if(!this.textAreaRef.current) {
      return;
    }

    if (this.props.maintainFocus) {
      this.textAreaRef.current.focus();
      return false;
    }

    return true;
  }

  componentWillUnmount() {
    const textarea = this.textAreaRef?.current;
    if (!textarea) {
      logger.error("NotePadTextArea. componentWillUnmount(): Textarea RefObject should not be null");
      return;
    }
    TEXTAREA_UPDATE_TRIGGERS.forEach((trigger) => textarea.removeEventListener(trigger, this));
  }

  render() {
    const {text, setText, wordWrap} = this.props;

    return (
      <TextArea
        textAreaRef={(ref) => {
          this.textAreaRef = ref
          const textarea = this.textAreaRef.current;
          if (!textarea) {
            return;
          }

          // Javascript – execute when textarea caret is moved
          // https://stackoverflow.com/a/53999418/5613731
          TEXTAREA_UPDATE_TRIGGERS.forEach((trigger) => textarea.addEventListener(trigger, this));
          // Slight hack: Keep selection when textarea loses focus so menubar actions can be used (i.e cut, delete)
          textarea.onblur = this.onblur.bind(this);
        }}
        onInput={(_, value) => setText(value)}
        className={"NtosNotepad__textarea"}
        scroll
        nowrap={!wordWrap}
        value={text}
      />
    )
  }
}

type DialogButtonProps = {
  onClick: () => void;
  children: InfernoNode,
}

const DialogButton = (props: DialogButtonProps) => {
  const {onClick, children} = props;
  return (
    <Button
      onClick={onClick}
      className="NtosNotepad__Dialog__button"
      verticalAlignContent="middle"
    >
      {children}
    </Button>
  );
}

type DialogProps = {
  title: string;
  close: () => void;
  children: InfernoNode,
  width?: string,
}

const Dialog = (props: DialogProps) => {
  const {title, close, children, width} = props;
  return (
    <div className="NtosNotepad__Dialog">
      <Box className="NtosNotepad__Dialog__content" width={width}>
        <div className="NtosNotepad__Dialog__header">
          <div className="NtosNotepad__Dialog__title">
            {title}
          </div>
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
}

type UnsavedChangesDialogProps = {
  documentName: string;
  save: () => void;
  noSave: () => void;
  close: () => void;
}

const UnsavedChangesDialog = (props: UnsavedChangesDialogProps) => {
  const {documentName, save, noSave, close} = props;
  return (
    <Dialog title="Notepad" close={close}>
      <div className="NtosNotepad__Dialog__body">
        Do you want to save changes to {documentName}?
      </div>
      <div className="NtosNotepad__Dialog__footer" >
        <DialogButton onClick={save}>Save</DialogButton>
        <DialogButton onClick={noSave}>Don't Save</DialogButton>
        <DialogButton onClick={close}>Cancel</DialogButton>
      </div>
    </Dialog>
  );
}

type SaveAsDialogProps = {
  documentName: string;
  save: (newDocumentName: string) => void;
  close: () => void;
}

const SaveAsDialog = (props: SaveAsDialogProps, context) => {
  const {documentName, save, close} = props;
  const saveAsName = documentName === DEFAULT_DOCUMENT_NAME ? "*.txt" : documentName;
  const [newDocumentName, setNewDocumentName] = useLocalState<string>(context, "newDocumentName", saveAsName);
  const saveWithValidName = () => {
    if (newDocumentName === "*.txt") {
      return;
    }

    save(newDocumentName);
  };

  return (
    <Dialog title="Save As" close={close} width={"600px"}>
      <div className="NtosNotepad__Dialog__body">
        <div className="NtosNotepad__SaveAsDialog__inputs">
          <label htmlFor="filename" className="NtosNotepad__SaveAsDialog__label">File name:</label>
          <Input
            id="filename"
            value={saveAsName}
            className={"NtosNotepad__SaveAsDialog__input"}
            onChange={(e, text) => setNewDocumentName(text)}
          />
        </div>
      </div>
      <div className="NtosNotepad__Dialog__footer" >
        <DialogButton onClick={saveWithValidName}>Save</DialogButton>
        <DialogButton onClick={close}>Cancel</DialogButton>
      </div>
    </Dialog>
  );
}

type NoteData = {
  note: string;
};
type RetryActionType = (retrying?: boolean) => void;

export const NtosNotepad = (props, context) => {
  const {act, data} = useBackend<NoteData>(context);
  const [documentName, setDocumentName] = useLocalState<string>(context, "documentName", DEFAULT_DOCUMENT_NAME);
  const [originalText, setOriginalText] = useLocalState<string>(context, "originalText", "");
  const [text, setText] = useLocalState<string>(context, "text", "");
  const [statuses, setStatuses] = useLocalState<Statuses>(context, "statuses", {line: 0, column: 0});
  const [activeDialog, setActiveDialog] = useLocalState<Dialogs>(context, "activeDialog", Dialogs.NONE);
  const [retryAction, setRetryAction] = useLocalState<RetryActionType | null>(context, "activeAction", null);
  const [showStatusBar, setShowStatusBar] = useLocalState<boolean>(context, "showStatusBar", true);
  const [wordWrap, setWordWrap] = useLocalState<boolean>(context, "wordWrap", true);
  const closeDialog = () => setActiveDialog(Dialogs.NONE);
  const save = (newDocumentName = documentName) => {
    logger.log(`Saving the document as ${newDocumentName}`);
    if (newDocumentName == DEFAULT_DOCUMENT_NAME) {
      logger.log(`Document name is ${newDocumentName}. New name is required.`);
      setActiveDialog(Dialogs.SAVE_AS);
      return;
    }

    act('UpdateNote', {newnote: text});
    setOriginalText(text);
    setDocumentName(newDocumentName);
    logger.log("Attempting to retry previous action");
    setActiveDialog(Dialogs.NONE);

    // Retry the previous action now that we've saved. The previous action could be to
    // close the application, a new document being created or
    // an existing document being opened
    if (retryAction) {
      retryAction(true);
    }
    setRetryAction(null);
  };
  const ensureUnsavedChangesAreHandled = (action: () => void, retrying = false): boolean => {
    // This is a guard function that throws up the "unsaved changes" dialog if the user is
    // attempting to do something that will make them lose data
    if (!retrying && originalText != text) {
      logger.log("Unsaved changes. Asking client to save");
      setRetryAction(() => action);
      setActiveDialog(Dialogs.UNSAVED_CHANGES);
      return true;
    }

    return false;
  };
  const openDocument = (retrying = false) => {
    if (ensureUnsavedChangesAreHandled(openDocument, retrying)) {
      return;
    }
    logger.log(`Opening a document`);
    setDocumentName("the_note.txt");
    const {note} = data;
    setOriginalText(note);
    setText(note);
  };
  const exit = (retrying = false) => {
    if (ensureUnsavedChangesAreHandled(exit, retrying)) {
      return;
    }
    logger.log("Exiting Notepad");
    act('PC_exit');
  };
  const newNote = (retrying = false) => {
    if (ensureUnsavedChangesAreHandled(newNote, retrying)) {
      return;
    }
    setOriginalText("");
    setText("");
    setDocumentName(DEFAULT_DOCUMENT_NAME);
  };
  const noSave = () => {
    logger.log("Discarding unsaved changes");
    setActiveDialog(Dialogs.NONE);
    if (retryAction) {
      retryAction(true);
    }
  }

  // MS Notepad displays an asterisk when there's unsaved changes
  const unsavedAsterisk = text != originalText ? "*" : "";
  return (
    <NtosWindow title={`${unsavedAsterisk}${documentName} - Notepad`} width={840} height={900}>
      <NtosWindow.Content>
        <Box className="NtosNotepad__layout">
          <MenuBar
            openDocument={openDocument}
            save={save}
            saveAsDialog={() => setActiveDialog(Dialogs.SAVE_AS)}
            exit={exit}
            newNote={newNote}
            cutSelected={() => document.execCommand("cut")}
            copySelected={() => document.execCommand("copy")}
            pasteClipboard={() => document.execCommand("paste")}
            deleteSelected={() => document.execCommand("delete")}
            showStatusBar={showStatusBar}
            setShowStatusBar={setShowStatusBar}
            wordWrap={wordWrap}
            setWordWrap={setWordWrap}
            aboutNotepadDialog={() => setActiveDialog(Dialogs.ABOUT)}
          />
          <Section fill>
            <NotePadTextArea
              maintainFocus={activeDialog === Dialogs.NONE}
              text={text}
              wordWrap={wordWrap}
              setText={setText}
              setStatuses={setStatuses}
            />
          </Section>
          {showStatusBar && <StatusBar statuses={statuses}/>}
        </Box>
      </NtosWindow.Content>
      {activeDialog === Dialogs.UNSAVED_CHANGES && (
        <UnsavedChangesDialog
          documentName={documentName}
          save={documentName == DEFAULT_DOCUMENT_NAME ? () => setActiveDialog(Dialogs.SAVE_AS) : save}
          close={closeDialog}
          noSave={noSave}
        />
      )}
      {activeDialog === Dialogs.SAVE_AS && (
        <SaveAsDialog
          documentName={documentName}
          save={save}
          close={closeDialog} />
      )}
    </NtosWindow>
  );
};
