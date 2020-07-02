/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes, pureComponentHooks } from 'common/react';
import { IS_IE8 } from '../byond';
import { Box, unit } from './Box';

export const computeFlexProps = props => {
  const {
    className,
    direction,
    wrap,
    align,
    justify,
    inline,
    spacing = 0,
    ...rest
  } = props;
  return {
    className: classes([
      'Flex',
      IS_IE8 && (
        direction === 'column'
          ? 'Flex--ie8--column'
          : 'Flex--ie8'
      ),
      inline && 'Flex--inline',
      spacing > 0 && 'Flex--spacing--' + spacing,
      className,
    ]),
    style: {
      ...rest.style,
      'flex-direction': direction,
      'flex-wrap': wrap,
      'align-items': align,
      'justify-content': justify,
    },
    ...rest,
  };
};

export const Flex = props => (
  <Box {...computeFlexProps(props)} />
);

Flex.defaultHooks = pureComponentHooks;

export const computeFlexItemProps = props => {
  const {
    className,
    grow,
    order,
    shrink,
    // IE11: Always set basis to specified width, which fixes certain
    // bugs when rendering tables inside the flex.
    basis = props.width,
    align,
    ...rest
  } = props;
  return {
    className: classes([
      'Flex__item',
      IS_IE8 && 'Flex__item--ie8',
      className,
    ]),
    style: {
      ...rest.style,
      'flex-grow': grow,
      'flex-shrink': shrink,
      'flex-basis': unit(basis),
      'order': order,
      'align-self': align,
    },
    ...rest,
  };
};

export const FlexItem = props => (
  <Box {...computeFlexItemProps(props)} />
);

FlexItem.defaultHooks = pureComponentHooks;

Flex.Item = FlexItem;
