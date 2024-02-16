/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { RefObject } from 'react';

import {
  computeFlexClassName,
  computeFlexItemClassName,
  computeFlexItemProps,
  computeFlexProps,
  FlexItemProps,
  FlexProps,
} from './Flex';

type Props = Partial<{
  vertical: boolean;
  fill: boolean;
  zebra: boolean;
}> &
  FlexProps;

export const Stack = (props: Props) => {
  const { className, vertical, fill, zebra, ...rest } = props;
  return (
    <div
      className={classes([
        'Stack',
        fill && 'Stack--fill',
        vertical ? 'Stack--vertical' : 'Stack--horizontal',
        zebra && 'Stack--zebra',
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

type StackItemProps = FlexItemProps &
  Partial<{
    innerRef: RefObject<HTMLDivElement>;
  }>;

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

type StackDividerProps = FlexItemProps &
  Partial<{
    hidden: boolean;
  }>;

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
