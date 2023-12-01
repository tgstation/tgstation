import { createPopper, VirtualElement } from '@popperjs/core';
import { classes } from 'common/react';
import { Component, ReactNode } from 'react';
import { findDOMNode, render } from 'react-dom';
import { Box, BoxProps } from './Box';
import { Button } from './Button';
import { Icon } from './Icon';
import { Stack } from './Stack';

export interface DropdownEntry {
  displayText: string | number | ReactNode;
  value: string | number | Enumerator;
}

type DropdownUniqueProps = { options: string[] | DropdownEntry[] } & Partial<{
  buttons: boolean;
  clipSelectedText: boolean;
  color: string;
  disabled: boolean;
  displayText: string | number | ReactNode;
  dropdownStyle: any;
  icon: string;
  iconRotation: number;
  iconSpin: boolean;
  menuWidth: string;
  nochevron: boolean;
  onClick: (event) => void;
  onSelected: (selected: any) => void;
  over: boolean;
  // you freaks really are just doing anything with this shit
  selected: any;
  width: string;
}>;

export type DropdownProps = BoxProps & DropdownUniqueProps;

const DEFAULT_OPTIONS = {
  placement: 'left-start',
  modifiers: [
    {
      name: 'eventListeners',
      enabled: false,
    },
  ],
};
const NULL_RECT: DOMRect = {
  width: 0,
  height: 0,
  top: 0,
  right: 0,
  bottom: 0,
  left: 0,
  x: 0,
  y: 0,
  toJSON: () => null,
} as const;

type DropdownState = {
  selected?: string;
  open: boolean;
};

const DROPDOWN_DEFAULT_CLASSNAMES = 'Layout Dropdown__menu';
const DROPDOWN_SCROLL_CLASSNAMES = 'Layout Dropdown__menu-scroll';

export class Dropdown extends Component<DropdownProps, DropdownState> {
  static renderedMenu: HTMLDivElement | undefined;
  static singletonPopper: ReturnType<typeof createPopper> | undefined;
  static currentOpenMenu: Element | undefined;
  static virtualElement: VirtualElement = {
    getBoundingClientRect: () =>
      Dropdown.currentOpenMenu?.getBoundingClientRect() ?? NULL_RECT,
  };
  menuContents: any;
  state: DropdownState = {
    open: false,
    selected: this.props.selected,
  };

  handleClick = () => {
    if (this.state.open) {
      this.setOpen(false);
    }
  };

  getDOMNode() {
    // eslint-disable-next-line react/no-find-dom-node
    return findDOMNode(this) as Element;
  }

  componentDidMount() {
    const domNode = this.getDOMNode();

    if (!domNode) {
      return;
    }
  }

  openMenu() {
    let renderedMenu = Dropdown.renderedMenu;
    if (renderedMenu === undefined) {
      renderedMenu = document.createElement('div');
      renderedMenu.className = DROPDOWN_DEFAULT_CLASSNAMES;
      document.body.appendChild(renderedMenu);
      Dropdown.renderedMenu = renderedMenu;
    }

    const domNode = this.getDOMNode()!;
    Dropdown.currentOpenMenu = domNode;

    renderedMenu.scrollTop = 0;
    renderedMenu.style.width = this.props.menuWidth || '10rem';
    renderedMenu.style.opacity = '1';
    renderedMenu.style.pointerEvents = 'auto';

    // ie hack
    // ie has this bizarre behavior where focus just silently fails if the
    // element being targeted "isn't ready"
    // 400 is probably way too high, but the lack of hotloading is testing my
    // patience on tuning it
    // I'm beyond giving a shit at this point it fucking works whatever
    setTimeout(() => {
      Dropdown.renderedMenu?.focus();
    }, 400);
    this.renderMenuContent();
  }

  closeMenu() {
    if (Dropdown.currentOpenMenu !== this.getDOMNode()) {
      return;
    }

    Dropdown.currentOpenMenu = undefined;
    Dropdown.renderedMenu!.style.opacity = '0';
    Dropdown.renderedMenu!.style.pointerEvents = 'none';
  }

  componentWillUnmount() {
    this.closeMenu();
    this.setOpen(false);
  }

  renderMenuContent() {
    const renderedMenu = Dropdown.renderedMenu;
    if (!renderedMenu) {
      return;
    }
    if (renderedMenu.offsetHeight > 200) {
      renderedMenu.className = DROPDOWN_SCROLL_CLASSNAMES;
    } else {
      renderedMenu.className = DROPDOWN_DEFAULT_CLASSNAMES;
    }

    const { options = [] } = this.props;
    const ops = options.map((option) => {
      let value, displayText;

      if (typeof option === 'string') {
        displayText = option;
        value = option;
      } else if (option !== null) {
        displayText = option.displayText;
        value = option.value;
      }

      return (
        <div
          key={value}
          className={classes([
            'Dropdown__menuentry',
            this.state.selected === value && 'selected',
          ])}
          onClick={() => {
            this.setSelected(value);
          }}>
          {displayText}
        </div>
      );
    });

    const to_render = ops.length ? ops : 'No Options Found';

    render(<div>{to_render}</div>, renderedMenu, () => {
      let singletonPopper = Dropdown.singletonPopper;
      if (singletonPopper === undefined) {
        singletonPopper = createPopper(Dropdown.virtualElement, renderedMenu!, {
          ...DEFAULT_OPTIONS,
          placement: 'bottom-start',
        });

        Dropdown.singletonPopper = singletonPopper;
      } else {
        singletonPopper.setOptions({
          ...DEFAULT_OPTIONS,
          placement: 'bottom-start',
        });

        singletonPopper.update();
      }
    });
  }

  setOpen(open: boolean) {
    this.setState((state) => ({
      ...state,
      open,
    }));
    if (open) {
      setTimeout(() => {
        this.openMenu();
        window.addEventListener('click', this.handleClick);
      });
    } else {
      this.closeMenu();
      window.removeEventListener('click', this.handleClick);
    }
  }

  setSelected(selected: string) {
    this.setState((state) => ({
      ...state,
      selected,
    }));
    this.setOpen(false);
    if (this.props.onSelected) {
      this.props.onSelected(selected);
    }
  }

  getOptionValue(option): string {
    return typeof option === 'string' ? option : option.value;
  }

  getSelectedIndex(): number {
    const selected = this.state.selected || this.props.selected;
    const { options = [] } = this.props;

    return options.findIndex((option) => {
      return this.getOptionValue(option) === selected;
    });
  }

  toPrevious(): void {
    if (this.props.options.length < 1) {
      return;
    }

    let selectedIndex = this.getSelectedIndex();
    const startIndex = 0;
    const endIndex = this.props.options.length - 1;

    const hasSelected = selectedIndex >= 0;
    if (!hasSelected) {
      selectedIndex = startIndex;
    }

    const previousIndex =
      selectedIndex === startIndex ? endIndex : selectedIndex - 1;

    this.setSelected(this.getOptionValue(this.props.options[previousIndex]));
  }

  toNext(): void {
    if (this.props.options.length < 1) {
      return;
    }

    let selectedIndex = this.getSelectedIndex();
    const startIndex = 0;
    const endIndex = this.props.options.length - 1;

    const hasSelected = selectedIndex >= 0;
    if (!hasSelected) {
      selectedIndex = endIndex;
    }

    const nextIndex =
      selectedIndex === endIndex ? startIndex : selectedIndex + 1;

    this.setSelected(this.getOptionValue(this.props.options[nextIndex]));
  }

  render() {
    const { props } = this;
    const {
      icon,
      iconRotation,
      iconSpin,
      clipSelectedText = true,
      color = 'default',
      dropdownStyle,
      over,
      nochevron,
      width,
      onClick,
      onSelected,
      selected,
      disabled,
      displayText,
      buttons,
      ...boxProps
    } = props;
    const { className, ...rest } = boxProps;

    const adjustedOpen = over ? !this.state.open : this.state.open;

    return (
      <Stack fill>
        <Stack.Item width={width}>
          <Box
            width={'100%'}
            className={classes([
              'Dropdown__control',
              'Button',
              'Button--color--' + color,
              disabled && 'Button--disabled',
              className,
            ])}
            onClick={(event) => {
              if (disabled && !this.state.open) {
                return;
              }
              this.setOpen(!this.state.open);
              if (onClick) {
                onClick(event);
              }
            }}
            {...rest}>
            {icon && (
              <Icon
                name={icon}
                rotation={iconRotation}
                spin={iconSpin}
                mr={1}
              />
            )}
            <span
              className="Dropdown__selected-text"
              style={{
                overflow: clipSelectedText ? 'hidden' : 'visible',
              }}>
              {displayText || this.state.selected}
            </span>
            {nochevron || (
              <span className="Dropdown__arrow-button">
                <Icon name={adjustedOpen ? 'chevron-up' : 'chevron-down'} />
              </span>
            )}
          </Box>
        </Stack.Item>
        {buttons && (
          <>
            <Stack.Item height={'100%'}>
              <Button
                height={'100%'}
                icon="chevron-left"
                disabled={disabled}
                onClick={() => {
                  if (disabled) {
                    return;
                  }

                  this.toPrevious();
                }}
              />
            </Stack.Item>
            <Stack.Item height={'100%'}>
              <Button
                height={'100%'}
                icon="chevron-right"
                disabled={disabled}
                onClick={() => {
                  if (disabled) {
                    return;
                  }

                  this.toNext();
                }}
              />
            </Stack.Item>
          </>
        )}
      </Stack>
    );
  }
}
