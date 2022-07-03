/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { Component, createRef, InfernoNode, InfernoNodeArray, RefObject } from 'inferno';
import { Box } from './Box';
import { logger } from '../logging';
import { Icon } from './Icon';

type MenuProps = {
  open: boolean;
  options: InfernoNodeArray;
  width: string;
  menuRef: RefObject<HTMLElement>;
  onOutsideClick: () => void;
};

class Menu extends Component<MenuProps> {
  private readonly handleClick: (event) => void;

  constructor(props) {
    super(props);
    this.handleClick = (event) => {
      if (!this.props.menuRef.current) {
        logger.log(`Menu.handleClick(): No ref`);
        return;
      }

      if (this.props.menuRef.current.contains(event.target)) {
        logger.log(`Menu.handleClick(): Inside`);
      } else {
        logger.log(`Menu.handleClick(): Outside`);
        this.props.onOutsideClick();
      }
    };
  }

  componentWillMount() {
    window.addEventListener('click', this.handleClick);
  }

  componentWillUnmount() {
    window.removeEventListener('click', this.handleClick);
  }

  render() {
    const { open, options, width } = this.props;
    const menu = open ? (
      <div
        className={'MenuBar__menu'}
        style={{
          width: width,
        }}>
        {options.length ? options : 'No Options Found'}
      </div>
    ) : null;

    return <>{menu}</>;
  }
}

type MenuBarDropdownProps = {
  open: boolean;
  openWidth: string;
  options: InfernoNodeArray;
  disabled?: boolean;
  display: InfernoNode;
  onMouseOver: () => void;
  onClick: () => void;
  onOutsideClick: () => void;
  className?: string;
};

class MenuBarButton extends Component<MenuBarDropdownProps> {
  private readonly menuRef: RefObject<HTMLDivElement>;

  constructor(props) {
    super(props);
    this.menuRef = createRef();
  }

  render() {
    const { props } = this;
    const {
      open,
      openWidth,
      options,
      disabled,
      display,
      onMouseOver,
      onClick,
      onOutsideClick,
      ...boxProps
    } = props;
    const { className, ...rest } = boxProps;

    return (
      <div ref={this.menuRef} className="MenuBar">
        <Box
          className={classes(['MenuBar__MenuBarButton', className])}
          {...rest}
          onClick={this.props.onClick}
          onmouseover={this.props.onMouseOver}>
          <span className="MenuBar__selected-text">{display}</span>
        </Box>
        {open && (
          <Menu
            open={open}
            width={openWidth}
            options={options}
            menuRef={this.menuRef}
            onOutsideClick={onOutsideClick}
          />
        )}
      </div>
    );
  }
}

type MenuBarItemProps = {
  entry: string;
  openWidth: string;
  display: InfernoNode;
  options: InfernoNodeArray;
  setOpenMenuBar: (entry: string | null) => void;
  openMenuBar: string | null;
  setOpenOnHover: (flag: boolean) => void;
  openOnHover: boolean;
  disabled?: boolean;
  className?: string;
};

export const MenuBarDropdown = (props: MenuBarItemProps) => {
  const {
    entry,
    openWidth,
    display,
    options,
    setOpenMenuBar,
    openMenuBar,
    setOpenOnHover,
    openOnHover,
    disabled,
  } = props;

  return (
    <MenuBarButton
      openWidth={openWidth}
      display={display}
      options={options}
      disabled={disabled}
      open={openMenuBar === entry}
      onClick={() => {
        const open = openMenuBar === entry ? null : entry;
        setOpenMenuBar(open);
        setOpenOnHover(!openOnHover);
      }}
      onOutsideClick={() => {
        setOpenMenuBar(null);
        setOpenOnHover(false);
      }}
      onMouseOver={() => {
        if (openOnHover) {
          setOpenMenuBar(entry);
        }
      }}
    />
  );
};

const MenuItemToggle = (props) => {
  const { value, displayText, onClick, checked } = props;
  return (
    <Box
      className={classes(['MenuBar__MenuItem', 'MenuBar__MenuItemToggle'])}
      onClick={() => onClick(value)}>
      <div className="MenuBar__MenuItemToggle__check">
        {checked && <Icon size={1.3} name="check" />}
      </div>
      {displayText}
    </Box>
  );
};

MenuBarDropdown.MenuItemToggle = MenuItemToggle;

const MenuItem = (props) => {
  const { value, displayText, onClick } = props;
  return (
    <Box className="MenuBar__MenuItem" onClick={() => onClick(value)}>
      {displayText}
    </Box>
  );
};

MenuBarDropdown.MenuItem = MenuItem;

const Separator = () => {
  return <div className="MenuBar__Separator" />;
};

MenuBarDropdown.Separator = Separator;
