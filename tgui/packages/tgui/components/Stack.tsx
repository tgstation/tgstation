/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { forwardRef, SFC } from 'inferno';
import { Flex, FlexItemProps, FlexProps } from './Flex';

 interface StackProps extends FlexProps {
   vertical?: boolean;
   fill?: boolean;
 }

export const Stack: SFC<FlexProps> & {
   Divider: SFC<StackDividerProps>,
   Item: SFC<FlexProps>,
 } = forwardRef((props: StackProps, ref) => {
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
       ref={ref}
       {...rest} />
   );
 }) as unknown as any; // They'll be defined later;

const StackItem = forwardRef((props: FlexProps, ref) => {
  const { className, ...rest } = props;
  return (
    <Flex.Item
      className={classes([
        'Stack__item',
        className,
      ])}
      ref={ref}
      {...rest} />
  );
});

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
