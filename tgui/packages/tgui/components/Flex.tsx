/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';

import { BoxProps, computeBoxClassName, computeBoxProps, unit } from './Box';

export type FlexProps = Partial<{
  align: string | boolean;
  direction: string;
  inline: boolean;
  justify: string;
  scrollable: boolean;
  style: Partial<HTMLDivElement['style']>;
  wrap: string | boolean;
}> &
  BoxProps;

export const computeFlexClassName = (props: FlexProps) => {
  return classes([
    'Flex',
    props.inline && 'Flex--inline',
    computeBoxClassName(props),
  ]);
};

export const computeFlexProps = (props: FlexProps) => {
  const { className, direction, wrap, align, justify, inline, ...rest } = props;

  return computeBoxProps({
    style: {
      ...rest.style,
      flexDirection: direction,
      flexWrap: wrap === true ? 'wrap' : wrap,
      alignItems: align,
      justifyContent: justify,
    },
    ...rest,
  });
};

export const Flex = (props) => {
  const { className, ...rest } = props;
  return (
    <div
      className={classes([className, computeFlexClassName(rest)])}
      {...computeFlexProps(rest)}
    />
  );
};

export type FlexItemProps = BoxProps &
  Partial<{
    grow: number | boolean;
    order: number;
    shrink: number | boolean;
    basis: string | number;
    align: string | boolean;
    style: Partial<HTMLDivElement['style']>;
  }>;

export const computeFlexItemClassName = (props: FlexItemProps) => {
  return classes(['Flex__item', computeBoxClassName(props)]);
};

export const computeFlexItemProps = (props: FlexItemProps) => {
  const { className, style, grow, order, shrink, basis, align, ...rest } =
    props;

  const computedBasis =
    basis ??
    // IE11: Set basis to specified width if it's known, which fixes certain
    // bugs when rendering tables inside the flex.
    props.width ??
    // If grow is used, basis should be set to 0 to be consistent with
    // flex css shorthand `flex: 1`.
    (grow !== undefined ? 0 : undefined);

  return computeBoxProps({
    style: {
      ...style,
      flexGrow: grow !== undefined && Number(grow),
      flexShrink: shrink !== undefined && Number(shrink),
      flexBasis: unit(computedBasis),
      order: order,
      alignSelf: align,
    },
    ...rest,
  });
};

const FlexItem = (props) => {
  const { className, ...rest } = props;
  return (
    <div
      className={classes([className, computeFlexItemClassName(props)])}
      {...computeFlexItemProps(rest)}
    />
  );
};

Flex.Item = FlexItem;
