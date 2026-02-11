import { useState } from 'react';
import { sendAct as act } from 'tgui/events/act';
import { MenuBar } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

type NanopaintMenuBarProps = {
  undoHistory: string[];
  redoHistory: string[];
  workspaceOpen: BooleanLike;
};

export const NanopaintMenuBar = (props: NanopaintMenuBarProps) => {
  const { undoHistory, redoHistory, workspaceOpen } = props;
  const [openOnHover, setOpenOnHover] = useState(false);
  const [openMenuBar, setOpenMenuBar] = useState<string | null>(null);
  const closeMenu = () => {
    setOpenOnHover(false);
    setOpenMenuBar(null);
  };
  // Adds the key using the value
  const getMenuItemProps = (
    value: string,
    displayText: string,
    action: () => void,
  ) => {
    return {
      key: value,
      value,
      displayText,
      onClick: (_value) => {
        closeMenu();
        action();
      },
    };
  };
  const dropdownProps = {
    openOnHover,
    setOpenOnHover,
    openMenuBar,
    setOpenMenuBar,
  };
  return (
    <MenuBar>
      <MenuBar.Dropdown
        entry="file"
        openWidth="22rem"
        display="File"
        {...dropdownProps}
      >
        <MenuBar.Dropdown.MenuItem
          {...getMenuItemProps('new', 'New', () => act('newDialog'))}
        />
        <MenuBar.Dropdown.MenuItem
          {...getMenuItemProps('open', 'Open', () => act('openDialog'))}
        />
        <MenuBar.Dropdown.MenuItem
          {...getMenuItemProps('save', 'Save', () => act('save'))}
          disabled={!workspaceOpen}
        />
        <MenuBar.Dropdown.MenuItem
          {...getMenuItemProps('saveAs', 'Save As', () => act('saveAsDialog'))}
          disabled={!workspaceOpen}
        />
      </MenuBar.Dropdown>
      <MenuBar.Dropdown
        entry="edit"
        openWidth="22rem"
        display="Edit"
        disabled={!workspaceOpen}
        {...dropdownProps}
      >
        <MenuBar.Dropdown.MenuItem
          {...getMenuItemProps(
            `Undo${undoHistory.length > 0 ? ` ${undoHistory[0]}` : ''}`,
            'undo',
            () => act('spriteEditorCommand', { command: 'undo' }),
          )}
          disabled={undoHistory.length === 0}
        />
        <MenuBar.Dropdown.MenuItem
          {...getMenuItemProps(
            `Redo${undoHistory.length > 0 ? ` ${redoHistory[0]}` : ''}`,
            'redo',
            () => act('spriteEditorCommand', { command: 'redo' }),
          )}
          disabled={redoHistory.length === 0}
        />
      </MenuBar.Dropdown>
    </MenuBar>
  );
};
