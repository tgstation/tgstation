/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { isValidElement, PropsWithChildren, ReactNode } from 'react';
import { computeBoxClassName, computeBoxProps } from './Box';
import { Icon } from './Icon';

type Props = Partial<{
  className: string;
  vertical: boolean;
  fill: boolean;
  fluid: boolean;
}> &
  PropsWithChildren;

type TabProps = Partial<{
  className: string;
  selected: boolean;
  color: string;
  icon: string;
  leftSlot: ReactNode;
  rightSlot: ReactNode;
  onClick: () => void;
}> &
  PropsWithChildren;

export const Tabs = (props: Props) => {
  const { className, vertical, fill, fluid, children, ...rest } = props;

  return (
    <div
      className={classes([
        'Tabs',
        vertical ? 'Tabs--vertical' : 'Tabs--horizontal',
        fill && 'Tabs--fill',
        fluid && 'Tabs--fluid',
        className,
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}>
      {children}
    </div>
  );
};

const Tab = (props: TabProps) => {
  const {
    className,
    selected,
    color,
    icon,
    leftSlot,
    rightSlot,
    children,
    ...rest
  } = props;

  return (
    <div
      className={classes([
        'Tab',
        'Tabs__Tab',
        'Tab--color--' + color,
        selected && 'Tab--selected',
        className,
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}>
      {(isValidElement(leftSlot) && (
        <div className="Tab__left">{leftSlot}</div>
      )) ||
        (!!icon && (
          <div className="Tab__left">
            <Icon name={icon} />
          </div>
        ))}
      <div className="Tab__text">{children}</div>
      {isValidElement(rightSlot) && (
        <div className="Tab__right">{rightSlot}</div>
      )}
    </div>
  );
};

Tabs.Tab = Tab;
