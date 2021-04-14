/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { Flex } from './Flex';

export const Stack = props => {
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

const StackItem = props => {
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

const StackDivider = props => {
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
