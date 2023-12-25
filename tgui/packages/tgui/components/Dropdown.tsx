import { classes } from 'common/react';
import { ReactNode, useEffect, useRef, useState } from 'react';

import { BoxProps } from './Box';
import { Button } from './Button';
import { Icon } from './Icon';
import { Popper } from './Popper';

type DropdownEntry = {
  displayText: ReactNode;
  value: string | number;
};

type DropdownOption = string | DropdownEntry;

type Props = {
  options: DropdownOption[];
  onSelected: (selected: any) => void;
} & Partial<{
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
  over: boolean;
  selected: string | number;
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
    icon,
    iconRotation,
    iconSpin,
    menuWidth = '15rem',
    noChevron,
    onClick,
    onSelected,
    options = [],
    selected,
  } = props;

  const [open, setOpen] = useState(false);
  const parentRef = useRef<HTMLDivElement>(null);
  const popperRef = useRef<HTMLDivElement>(null);

  /** Get the index of the selected option */
  function getSelectedIndex() {
    return options.findIndex((option) => {
      return getOptionValue(option) === selected;
    });
  }

  /** Update the selected value when clicking the left/right buttons */
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

  /** Focus the dropdown menu when opening it */
  useEffect(() => {
    if (open && popperRef.current) {
      popperRef.current.focus();
    }
  }, [open]);

  return (
    <Popper
      placement="bottom-start"
      onClickOutside={() => setOpen(false)}
      popperContent={
        open ? (
          <div
            className="Layout Dropdown__menu"
            style={{ minWidth: menuWidth }}
            ref={popperRef}
          >
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
                  onClick={() => {
                    setOpen(false);
                    onSelected?.(value);
                  }}
                >
                  {typeof option === 'string' ? option : option.displayText}
                </div>
              );
            })}
          </div>
        ) : null
      }
    >
      <div
        className="Dropdown"
        ref={parentRef}
        style={{
          minWidth: menuWidth,
        }}
      >
        <div
          className={classes([
            'Dropdown__control',
            'Button',
            'Button--dropdown',
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
        >
          {icon && (
            <Icon mr={1} name={icon} rotation={iconRotation} spin={iconSpin} />
          )}
          <span
            className="Dropdown__selected-text"
            style={{
              overflow: clipSelectedText ? 'hidden' : 'visible',
            }}
          >
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
    </Popper>
  );
}
