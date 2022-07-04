/**
 * @file
 * @copyright 2022 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { Component, createRef, InfernoNode, RefObject } from 'inferno';
import { Box } from './Box';
import { logger } from '../logging';
import { Icon } from './Icon';

type MenuProps = {
  children: any;
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

  // eslint-disable-next-line react/no-deprecated
  componentWillMount() {
    window.addEventListener('click', this.handleClick);
  }

  componentWillUnmount() {
    window.removeEventListener('click', this.handleClick);
  }

  render() {
    const { width, children } = this.props;
    return (
      <div
        className={'MenuBar__menu'}
        style={{
          width: width,
        }}>
        {children}
      </div>
    );
  }
}

type MenuBarDropdownProps = {
  open: boolean;
  openWidth: string;
  children: any;
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
      children,
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
          onClick={disabled ? undefined : onClick}
          onmouseover={onMouseOver}>
          <span className="MenuBar__selected-text">{display}</span>
        </Box>
        {open && (
          <Menu
            width={openWidth}
            menuRef={this.menuRef}
            onOutsideClick={onOutsideClick}
          >
            {children}
          </Menu>
        )}
      </div>
    );
  }
}

type MenuBarItemProps = {
  entry: string;
  children: any;
  openWidth: string;
  display: InfernoNode;
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
    children,
    openWidth,
    display,
    setOpenMenuBar,
    openMenuBar,
    setOpenOnHover,
    openOnHover,
    disabled,
    className,
  } = props;

  return (
    <MenuBarButton
      openWidth={openWidth}
      display={display}
      disabled={disabled}
      open={openMenuBar === entry}
      className={className}
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
    >
      {children}
    </MenuBarButton>
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
