import { createPopper } from '@popperjs/core';
import { classes } from 'common/react';
import React, { useEffect } from 'react';
import { ReactNode, useRef, useState } from 'react';

import { Box, BoxProps } from './Box';
import { Button } from './Button';
import { Icon } from './Icon';
import { Stack } from './Stack';

type DropdownEntry = {
  displayText: string | number | ReactNode;
  value: string | number | Enumerator;
};

type DropdownOption = string | DropdownEntry;

type Props = { options: DropdownOption[] } & Partial<{
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
}> &
  BoxProps;

function getOptionValue(option: DropdownOption) {
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
    dropdownStyle,
    icon,
    iconRotation,
    iconSpin,
    menuWidth,
    nochevron,
    onClick,
    onSelected,
    options = [],
    over,
    width,
    ...rest
  } = props;

  const [open, setOpen] = useState(false);
  const [selected, setSelected] = useState(props.selected);
  const dropdownRef = useRef<HTMLDivElement>(null);
  const menuRef = useRef<HTMLDivElement>(null);

  function getSelectedIndex() {
    return options.findIndex((option) => {
      return getOptionValue(option) === selected;
    });
  }

  function updateSelected(direction: 'previous' | 'next') {
    if (options.length < 1) {
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

    setSelected(getOptionValue(options[newIndex]));
  }

  useEffect(() => {
    setSelected(props.selected);
  }, [props.selected]);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setOpen(false);
      }
    };

    window.addEventListener('click', handleClickOutside);
    return () => {
      window.removeEventListener('click', handleClickOutside);
    };
  }, []);

  useEffect(() => {
    if (dropdownRef.current && menuRef.current) {
      createPopper(dropdownRef.current, menuRef.current, {
        placement: 'bottom-start',
      });
    }
  }, [open]);

  return (
    <Stack fill>
      <Stack.Item width={width}>
        <Box
          ref={dropdownRef}
          width="100%"
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
            if (onClick) {
              onClick(event);
            }
          }}
          {...rest}
        >
          {icon && (
            <Icon name={icon} rotation={iconRotation} spin={iconSpin} mr={1} />
          )}
          <span
            className="Dropdown__selected-text"
            style={{
              overflow: clipSelectedText ? 'hidden' : 'visible',
            }}
          >
            {displayText || selected}
          </span>
          {!nochevron && (
            <span className="Dropdown__arrow-button">
              <Icon name={open ? 'chevron-up' : 'chevron-down'} />
            </span>
          )}
        </Box>
      </Stack.Item>
      {buttons && (
        <>
          <Stack.Item height="100%">
            <Button
              height="100%"
              icon="chevron-left"
              disabled={disabled}
              onClick={() => {
                if (disabled) {
                  return;
                }

                updateSelected('previous');
              }}
            />
          </Stack.Item>
          <Stack.Item height="100%">
            <Button
              height="100%"
              icon="chevron-right"
              disabled={disabled}
              onClick={() => {
                if (disabled) {
                  return;
                }

                updateSelected('next');
              }}
            />
          </Stack.Item>
        </>
      )}
      {open && <DropDownMenu options={options} onSelected={setSelected} />}
    </Stack>
  );
}

function DropDownMenu(props: {
  options: DropdownOption[];
  onSelected: (selected: any) => void;
}) {
  const { options, onSelected } = props;

  return (
    <div>
      {options.map((option, index) => (
        <div key={index} onClick={() => onSelected(getOptionValue(option))}>
          {typeof option === 'string' ? option : option.displayText}
        </div>
      ))}
    </div>
  );
}
