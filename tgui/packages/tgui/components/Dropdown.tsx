import { classes } from 'common/react';
import { ReactNode, useCallback, useEffect, useRef, useState } from 'react';

import { BoxProps, unit } from './Box';
import { Button } from './Button';
import { Icon } from './Icon';
import { Popper } from './Popper';

type DropdownEntry = {
  displayText: ReactNode;
  value: string | number;
};

type DropdownOption = string | DropdownEntry;

type Props = {
  /** An array of strings which will be displayed in the
  dropdown when open. See Dropdown.tsx for more advanced usage with DropdownEntry */
  options: DropdownOption[];
  /** Called when a value is picked from the list, `value` is the value that was picked */
  onSelected: (value: any) => void;
} & Partial<{
  /** Whether to display previous / next buttons */
  buttons: boolean;
  /** Whether to clip the selected text */
  clipSelectedText: boolean;
  /** Color of dropdown button */
  color: string;
  /** Disables the dropdown */
  disabled: boolean;
  /** Text to always display in place of the selected text */
  displayText: ReactNode;
  /** Icon to display in dropdown button */
  icon: string;
  /** Angle of the icon */
  iconRotation: number;
  /** Whether or not the icon should spin */
  iconSpin: boolean;
  /** Width of the dropdown menu. Default: 15rem */
  menuWidth: string;
  /** Whether or not the arrow on the right hand side of the dropdown button is visible */
  noChevron: boolean;
  /** Called when dropdown button is clicked */
  onClick: (event) => void;
  /** Dropdown renders over instead of below */
  over: boolean;
  /** Currently selected entry */
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
    over,
    selected,
    width,
  } = props;

  const [open, setOpen] = useState(false);
  const adjustedOpen = over ? !open : open;
  const innerRef = useRef<HTMLDivElement>(null);

  /** Update the selected value when clicking the left/right buttons */
  const updateSelected = useCallback(
    (direction: 'previous' | 'next') => {
      if (options.length < 1 || disabled) {
        return;
      }
      const startIndex = 0;
      const endIndex = options.length - 1;

      let selectedIndex = options.findIndex(
        (option) => getOptionValue(option) === selected,
      );

      if (selectedIndex < 0) {
        selectedIndex = direction === 'next' ? endIndex : startIndex;
      }

      let newIndex = selectedIndex;
      if (direction === 'next') {
        newIndex = selectedIndex === endIndex ? startIndex : selectedIndex++;
      } else {
        newIndex = selectedIndex === startIndex ? endIndex : selectedIndex--;
      }

      onSelected?.(getOptionValue(options[newIndex]));
    },
    [disabled, onSelected, options, selected],
  );

  /** Allows the menu to be scrollable on open */
  useEffect(() => {
    if (!open) return;

    innerRef.current?.focus();
  }, [open]);

  return (
    <Popper
      isOpen={open}
      onClickOutside={() => setOpen(false)}
      placement={over ? 'top-start' : 'bottom-start'}
      content={
        <div
          className="Layout Dropdown__menu"
          style={{ minWidth: menuWidth }}
          ref={innerRef}
        >
          {options.length === 0 && (
            <div className="Dropdown__menuentry">No options</div>
          )}

          {options.map((option, index) => {
            const value = getOptionValue(option);

            return (
              <div
                className={classes([
                  'Dropdown__menuentry',
                  selected === value && 'selected',
                ])}
                key={index}
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
      }
    >
      <div>
        <div className="Dropdown" style={{ width: unit(width) }}>
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
            {!noChevron && (
              <span className="Dropdown__arrow-button">
                <Icon name={adjustedOpen ? 'chevron-up' : 'chevron-down'} />
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
      </div>
    </Popper>
  );
}
