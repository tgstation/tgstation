/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { Flex, FlexItemProps, FlexProps } from './Flex';

interface StackProps extends FlexProps {
  vertical?: boolean;
  fill?: boolean;
}

export const Stack = (props: StackProps) => {
  const { className, vertical, fill, ...rest } = props;
  return (
    <Flex
      className={classes([
        'Stack',
        fill && 'Stack--fill',
        vertical
          ? 'Stack--vertical'
          : 'Stack--horizontal',
        className,
      ])}
      direction={vertical ? 'column' : 'row'}
      {...rest} />
  );
};

const StackItem = (props: FlexProps) => {
  const { className, ...rest } = props;
  return (
    <Flex.Item
      className={classes([
        'Stack__item',
        className,
      ])}
      {...rest} />
  );
};

Stack.Item = StackItem;

interface StackDividerProps extends FlexItemProps {
  hidden?: boolean;
}

const StackDivider = (props: StackDividerProps) => {
  const { className, hidden, ...rest } = props;
  return (
    <Flex.Item
      className={classes([
        'Stack__item',
        'Stack__divider',
        hidden && 'Stack__divider--hidden',
        className,
      ])}
      {...rest} />
  );
};

Stack.Divider = StackDivider;
