/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { Component } from 'inferno';
import { Box } from './Box';
import { Icon } from './Icon';
import { Stack } from './Stack';
import { Button } from './Button';

export class Dropdown extends Component {
  constructor(props) {
    super(props);
    this.state = {
      selected: props.selected,
      open: false,
    };
    this.handleClick = () => {
      if (this.state.open) {
        this.setOpen(false);
      }
    };
  }

  componentWillUnmount() {
    window.removeEventListener('click', this.handleClick);
  }

  setOpen(open) {
    this.setState({ open: open });
    if (open) {
      setTimeout(() => {
        window.addEventListener('click', this.handleClick);
      });
      this.menuRef.focus();
    } else {
      window.removeEventListener('click', this.handleClick);
    }
  }

  setSelected(selected) {
    this.setState({
      selected: selected,
    });
    this.setOpen(false);
    this.props.onSelected(selected);
  }

  buildMenu() {
    const { options = [] } = this.props;
    const ops = options.map((option) => {
      let displayText, value;

      if (typeof option === 'string') {
        displayText = option;
        value = option;
      } else {
        displayText = option.displayText;
        value = option.value;
      }

      return (
        <Box
          key={value}
          className="Dropdown__menuentry"
          onClick={() => {
            this.setSelected(value);
          }}>
          {displayText}
        </Box>
      );
    });
    return ops.length ? ops : 'No Options Found';
  }

  getOptionValue(option) {
    return typeof option === 'string' ? option : option.value;
  }

  getOptionsValues() {
    const { options = [] } = this.props;

    return options.map((option) => {
      return this.getOptionValue(option);
    });
  }

  getSelectedIndex() {
    const selected = this.state.selected;
    const { options = [] } = this.props;

    let selectedIndex;
    options.forEach((option, index) => {
      let value = this.getOptionValue(option);

      if (value === selected) {
        selectedIndex = index;
      }
    });

    return selectedIndex;
  }

  hasSwitchToPrevious() {
    const selectedIndex = this.getSelectedIndex();

    if (selectedIndex === undefined) {
      return false;
    }

    const previousIndex = parseInt(selectedIndex, 10) - 1;
    const opts = this.getOptionsValues();

    const previous = opts[previousIndex];

    return previous !== undefined;
  }

  switchToPrevious() {
    const selectedIndex = this.getSelectedIndex();

    if (selectedIndex === undefined) {
      return;
    }

    const previousIndex = parseInt(selectedIndex, 10) - 1;
    const opts = this.getOptionsValues();

    const previous = opts[previousIndex];

    if (previous === undefined) {
      return;
    }

    this.setSelected(previous);
  }

  hasSwitchToNext() {
    const selectedIndex = this.getSelectedIndex();

    if (selectedIndex === undefined) {
      return false;
    }

    const nextIndex = parseInt(selectedIndex, 10) + 1;
    const opts = this.getOptionsValues();

    const next = opts[nextIndex];

    return next !== undefined;
  }

  switchToNext() {
    const selectedIndex = this.getSelectedIndex();

    if (selectedIndex === undefined) {
      return;
    }

    const nextIndex = parseInt(selectedIndex, 10) + 1;
    const opts = this.getOptionsValues();

    const next = opts[nextIndex];

    if (next === undefined) {
      return;
    }

    this.setSelected(next);
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
      noscroll,
      nochevron,
      width,
      openWidth = width,
      onClick,
      onOpen,
      selected,
      disabled,
      displayText,
      buttons,
      ...boxProps
    } = props;
    const { className, ...rest } = boxProps;

    const adjustedOpen = over ? !this.state.open : this.state.open;

    const menu = this.state.open ? (
      <div
        ref={(menu) => {
          this.menuRef = menu;
        }}
        tabIndex="-1"
        style={{
          'width': openWidth,
        }}
        className={classes([
          (noscroll && 'Dropdown__menu-noscroll') || 'Dropdown__menu',
          over && 'Dropdown__over',
        ])}>
        {this.buildMenu()}
      </div>
    ) : null;

    return (
      <Stack fill>
        <Stack.Item width={this.state.open ? openWidth : width}>
          <div className="Dropdown" style={dropdownStyle}>
            <Box
              width={'100%'}
              className={classes([
                'Dropdown__control',
                'Button',
                'Button--color--' + color,
                disabled && 'Button--disabled',
                className,
              ])}
              {...rest}
              onClick={(event) => {
                if (disabled && !this.state.open) {
                  return;
                }
                this.setOpen(!this.state.open);

                if (props.onOpen) {
                  props.onOpen(event);
                }
              }}>
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
                  'overflow': clipSelectedText ? 'hidden' : 'visible',
                }}>
                {displayText ? displayText : this.state.selected}
              </span>
              {!!nochevron || (
                <span className="Dropdown__arrow-button">
                  <Icon name={adjustedOpen ? 'chevron-up' : 'chevron-down'} />
                </span>
              )}
            </Box>
            {menu}
          </div>
        </Stack.Item>
        {buttons && (
          <Stack.Item height={'100%'}>
            <Button
              height={'100%'}
              content="<"
              disabled={disabled || !this.hasSwitchToPrevious()}
              onClick={() => {
                if (disabled || !this.hasSwitchToPrevious()) {
                  return;
                }

                this.switchToPrevious();
              }}
            />
          </Stack.Item>
        )}
        {buttons && (
          <Stack.Item height={'100%'}>
            <Button
              height={'100%'}
              content=">"
              disabled={disabled || !this.hasSwitchToNext()}
              onClick={() => {
                if (disabled || !this.hasSwitchToNext()) {
                  return;
                }

                this.switchToNext();
              }}
            />
          </Stack.Item>
        )}
      </Stack>
    );
  }
}
