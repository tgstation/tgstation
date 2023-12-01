/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { RefObject } from 'inferno';
import { computeFlexClassName, computeFlexItemClassName, computeFlexItemProps, computeFlexProps, FlexItemProps, FlexProps } from './Flex';

type StackProps = Partial<{
  vertical: boolean;
  fill: boolean;
}> &
  FlexProps;

export const Stack = (props: StackProps) => {
  const { className, vertical, fill, ...rest } = props;

  return (
    <div
      className={classes([
        'Stack',
        fill && 'Stack--fill',
        vertical ? 'Stack--vertical' : 'Stack--horizontal',
        className,
        computeFlexClassName(props),
      ])}
      {...computeFlexProps({
        direction: vertical ? 'column' : 'row',
        ...rest,
      })}
    />
  );
};

type StackItemProps = Partial<{
  innerRef?: RefObject<HTMLDivElement>;
}> &
  FlexItemProps;

const StackItem = (props: StackItemProps) => {
  const { className, innerRef, ...rest } = props;

  return (
    <div
      className={classes([
        'Stack__item',
        className,
        computeFlexItemClassName(rest),
      ])}
      ref={innerRef}
      {...computeFlexItemProps(rest)}
    />
  );
};

Stack.Item = StackItem;

type StackDividerProps = Partial<{
  hidden: boolean;
}> &
  FlexItemProps;

const StackDivider = (props: StackDividerProps) => {
  const { className, hidden, ...rest } = props;

  return (
    <div
      className={classes([
        'Stack__item',
        'Stack__divider',
        hidden && 'Stack__divider--hidden',
        className,
        computeFlexItemClassName(rest),
      ])}
      {...computeFlexItemProps(rest)}
    />
  );
};

Stack.Divider = StackDivider;
