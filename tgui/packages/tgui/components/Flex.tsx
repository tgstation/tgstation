/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { BooleanLike, classes, pureComponentHooks } from 'common/react';
import { BoxProps, computeBoxClassName, computeBoxProps, unit } from './Box';

export type FlexProps = BoxProps & {
  direction?: string | BooleanLike;
  wrap?: string | BooleanLike;
  align?: string | BooleanLike;
  justify?: string | BooleanLike;
  inline?: BooleanLike;
};

export const computeFlexClassName = (props: FlexProps) => {
  return classes([
    'Flex',
    Byond.IS_LTE_IE10 && (
      props.direction === 'column'
        ? 'Flex--iefix--column'
        : 'Flex--iefix'
    ),
    props.inline && 'Flex--inline',
  ]);
};

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

export const Flex = props => {
  const { className, ...rest } = props;
  return (
    <div
      className={classes([
        className,
        computeFlexClassName(rest),
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(computeFlexProps(rest))}
    />
  );
};

Flex.defaultHooks = pureComponentHooks;

export type FlexItemProps = BoxProps & {
  grow?: number;
  order?: number;
  shrink?: number;
  basis?: string | BooleanLike;
  align?: string | BooleanLike;
};

export const computeFlexItemClassName = (props: FlexItemProps) => {
  return classes([
    'Flex__item',
    Byond.IS_LTE_IE10 && 'Flex__item--iefix',
    Byond.IS_LTE_IE10 && (props.grow && props.grow > 0) && 'Flex__item--iefix--grow',
  ]);
};

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

const FlexItem = props => {
  const { className, ...rest } = props;
  return (
    <div
      className={classes([
        className,
        computeFlexItemClassName(props),
        computeBoxClassName(props),
      ])}
      {...computeBoxProps(computeFlexItemProps(rest))}
    />
  );
};

FlexItem.defaultHooks = pureComponentHooks;

Flex.Item = FlexItem;
