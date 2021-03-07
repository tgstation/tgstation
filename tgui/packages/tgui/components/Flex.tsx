/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { BooleanLike, classes, pureComponentHooks } from 'common/react';
import { Box, BoxProps, unit } from './Box';

export interface FlexProps extends BoxProps {
  direction: string | BooleanLike;
  wrap: string | BooleanLike;
  align: string | BooleanLike;
  justify: string | BooleanLike;
  inline: BooleanLike;
}

export const computeFlexProps = (props: FlexProps) => {
  const {
    className,
    direction,
    wrap,
    align,
    justify,
    inline,
    ...rest
  } = props;
  return {
    className: classes([
      'Flex',
      Byond.IS_LTE_IE10 && (
        direction === 'column'
          ? 'Flex--iefix--column'
          : 'Flex--iefix'
      ),
      inline && 'Flex--inline',
      className,
    ]),
    style: {
      ...rest.style,
      'flex-direction': direction,
      'flex-wrap': wrap === true ? 'wrap' : wrap,
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

export interface FlexItemProps extends BoxProps {
  grow?: number;
  order?: number;
  shrink?: number;
  basis?: string | BooleanLike;
  align?: string | BooleanLike;
}

export const computeFlexItemProps = (props: FlexItemProps) => {
  const {
    className,
    style,
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
      Byond.IS_LTE_IE10 && 'Flex__item--iefix',
      Byond.IS_LTE_IE10 && grow > 0 && 'Flex__item--iefix--grow',
      className,
    ]),
    style: {
      ...style,
      'flex-grow': grow !== undefined && Number(grow),
      'flex-shrink': shrink !== undefined && Number(shrink),
      'flex-basis': unit(basis),
      'order': order,
      'align-self': align,
    },
    ...rest,
  };
};

const FlexItem = props => (
  <Box {...computeFlexItemProps(props)} />
);

FlexItem.defaultHooks = pureComponentHooks;

Flex.Item = FlexItem;
