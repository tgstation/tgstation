import { classes } from 'common/react';
import { useEffect } from 'react';
import { ReactNode, useState } from 'react';
import { Popover } from 'react-tiny-popover';

import { BoxProps } from './Box';
import { Button } from './Button';
import { Icon } from './Icon';

type DropdownEntry = {
  displayText: ReactNode;
  value: string;
};

type DropdownOption = string | DropdownEntry;

type Props = { options: DropdownOption[] } & Partial<{
  buttons: boolean;
  clipSelectedText: boolean;
  color: string;
  disabled: boolean;
  displayText: ReactNode;
  dropdownStyle: any;
  icon: string;
  iconRotation: number;
  iconSpin: boolean;
  menuWidth: string;
  noChevron: boolean;
  onClick: (event) => void;
  onSelected: (selected: any) => void;
  over: boolean;
  selected: string;
}> &
  BoxProps;

function getOptionValue(option: DropdownOption): string {
  return typeof option === 'string' ? option : option.value;
}

export function Dropdown(props: Props) {
  const {
    buttons,
    className,
    clipSelectedText = true,
    color = 'default',
    disabled,
    displayText,
    icon,
    iconRotation,
    iconSpin,
    menuWidth = '15rem',
    noChevron,
    onClick,
    onSelected,
    options = [],
  } = props;

  const [open, setOpen] = useState(false);
  const [selected, setSelected] = useState(props.selected);

  function getSelectedIndex() {
    return options.findIndex((option) => {
      return getOptionValue(option) === selected;
    });
  }

  function updateSelected(direction: 'previous' | 'next') {
    if (options.length < 1 || disabled) {
      return;
    }

    let selectedIndex = getSelectedIndex();
    const startIndex = 0;
    const endIndex = options.length - 1;

    const hasSelected = selectedIndex >= 0;
    if (!hasSelected) {
      selectedIndex = direction === 'next' ? endIndex : startIndex;
    }

    const newIndex =
      direction === 'next'
        ? selectedIndex === endIndex
          ? startIndex
          : selectedIndex + 1
        : selectedIndex === startIndex
          ? endIndex
          : selectedIndex - 1;

    onSelected?.(getOptionValue(options[newIndex]));
  }

  useEffect(() => {
    onSelected?.(props.selected);
  }, [onSelected, props.selected]);

  return (
    <Popover
      isOpen={open}
      positions="bottom"
      onClickOutside={() => setOpen(false)}
      content={
        <div className="Layout Dropdown__menu" style={{ minWidth: menuWidth }}>
          {options.length === 0 && (
            <div className="Dropdown__menuentry">No options</div>
          )}

          {options.map((option) => {
            const value = getOptionValue(option);

            return (
              <div
                className={classes([
                  'Dropdown__menuentry',
                  selected === value && 'selected',
                ])}
                key={value}
                onClick={() => setSelected(value)}
              >
                {typeof option === 'string' ? option : option.displayText}
              </div>
            );
          })}
        </div>
      }
    >
      <div
        style={{
          display: 'flex',
          alignItems: 'flex-start',
          minWidth: '5rem',
        }}
      >
        <div
          className={classes([
            'Dropdown__control',
            'Button',
            'Button--color--' + color,
            disabled && 'Button--disabled',
            className,
          ])}
          onClick={(event) => {
            if (disabled && !open) {
              return;
            }
            setOpen(!open);
            onClick?.(event);
          }}
          style={{
            flex: 1,
          }}
        >
          {icon && (
            <Icon mr={1} name={icon} rotation={iconRotation} spin={iconSpin} />
          )}
          <span className="Dropdown__selected-text">
            {displayText || selected}
          </span>
          {!noChevron && (
            <span className="Dropdown__arrow-button">
              <Icon name={open ? 'chevron-up' : 'chevron-down'} />
            </span>
          )}
        </div>

        {buttons && (
          <>
            <Button
              disabled={disabled}
              height={1.8}
              icon="chevron-left"
              onClick={() => {
                updateSelected('previous');
              }}
            />

            <Button
              disabled={disabled}
              height={1.8}
              icon="chevron-right"
              onClick={() => {
                updateSelected('next');
              }}
            />
          </>
        )}
      </div>
    </Popover>
  );
}
