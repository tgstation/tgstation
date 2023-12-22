import { classes } from 'common/react';
import React, { useEffect } from 'react';
import { ReactNode, useRef, useState } from 'react';

import { Box, BoxProps } from './Box';
import { Button } from './Button';
import { Icon } from './Icon';
import { Popper } from './Popper';
import { Stack } from './Stack';

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
  nochevron: boolean;
  onClick: (event) => void;
  onSelected: (selected: any) => void;
  over: boolean;
  selected: string;
  width: string;
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
    dropdownStyle,
    icon,
    iconRotation,
    iconSpin,
    menuWidth = '15rem',
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

  const style = {
    pointerEvents: 'auto',
    width: menuWidth,
    overflowY: 'auto',
    ...dropdownStyle,
  } as const;

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

    setSelected(getOptionValue(options[newIndex]));
  }

  useEffect(() => {
    setSelected(props.selected);
  }, [props.selected]);

  return (
    <Popper
      additionalStyles={style}
      className={`Layout Dropdown__menu`}
      options={{ placement: 'bottom' }}
      popperContent={
        open ? (
          <>
            {options.map((option, index) => {
              const value = getOptionValue(option);

              return (
                <div
                  className={classes([
                    'Dropdown__menuentry',
                    selected === value && 'selected',
                  ])}
                  key={index}
                  onClick={() => setSelected(value)}
                >
                  {typeof option === 'string' ? option : option.displayText}
                </div>
              );
            })}
          </>
        ) : null
      }
    >
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
              onClick?.(event);
            }}
            {...rest}
          >
            {icon && (
              <Icon
                mr={1}
                name={icon}
                rotation={iconRotation}
                spin={iconSpin}
              />
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
            <Stack.Item>
              <Button
                disabled={disabled}
                icon="chevron-left"
                onClick={() => {
                  updateSelected('previous');
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                disabled={disabled}
                icon="chevron-right"
                onClick={() => {
                  updateSelected('next');
                }}
              />
            </Stack.Item>
          </>
        )}
      </Stack>
    </Popper>
  );
}
