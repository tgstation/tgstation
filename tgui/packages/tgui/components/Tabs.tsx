/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { canRender, classes } from 'common/react';
import { InfernoNode } from 'inferno';
import { BoxProps, computeBoxClassName, computeBoxProps } from './Box';
import { Icon } from './Icon';

type Props = Partial<{
  children: InfernoNode;
  className: string;
  fill: boolean;
  fluid: boolean;
  vertical: boolean;
}> &
  BoxProps;

type TabProps = Partial<{
  children: InfernoNode;
  className: string;
  color: string;
  fluid: boolean;
  icon: string;
  leftSlot: InfernoNode;
  onClick: () => void;
  rightSlot: InfernoNode;
  selected: boolean;
}> &
  BoxProps;

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
      {(canRender(leftSlot) && <div className="Tab__left">{leftSlot}</div>) ||
        (!!icon && (
          <div className="Tab__left">
            <Icon name={icon} />
          </div>
        ))}
      <div className="Tab__text">{children}</div>
      {canRender(rightSlot) && <div className="Tab__right">{rightSlot}</div>}
    </div>
  );
};

Tabs.Tab = Tab;
