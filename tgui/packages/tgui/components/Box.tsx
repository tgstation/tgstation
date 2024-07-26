/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { BooleanLike, classes } from 'common/react';
import {
  createElement,
  KeyboardEventHandler,
  MouseEventHandler,
  ReactNode,
  UIEventHandler,
} from 'react';

import { CSS_COLORS } from '../constants';
import { logger } from '../logging';

type BooleanProps = Partial<Record<keyof typeof booleanStyleMap, boolean>>;
type StringProps = Partial<
  Record<keyof typeof stringStyleMap, string | BooleanLike>
>;

export type EventHandlers = Partial<{
  onClick: MouseEventHandler<HTMLDivElement>;
  onContextMenu: MouseEventHandler<HTMLDivElement>;
  onDoubleClick: MouseEventHandler<HTMLDivElement>;
  onKeyDown: KeyboardEventHandler<HTMLDivElement>;
  onKeyUp: KeyboardEventHandler<HTMLDivElement>;
  onMouseDown: MouseEventHandler<HTMLDivElement>;
  onMouseMove: MouseEventHandler<HTMLDivElement>;
  onMouseOver: MouseEventHandler<HTMLDivElement>;
  onMouseUp: MouseEventHandler<HTMLDivElement>;
  onScroll: UIEventHandler<HTMLDivElement>;
}>;

export type BoxProps = Partial<{
  as: string;
  children: ReactNode;
  className: string | BooleanLike;
  style: Partial<CSSStyleDeclaration>;
}> &
  BooleanProps &
  StringProps &
  EventHandlers;

// Don't you dare put this elsewhere
type DangerDoNotUse = {
  dangerouslySetInnerHTML?: {
    __html: any;
  };
};

/**
 * Coverts our rem-like spacing unit into a CSS unit.
 */
export const unit = (value: unknown) => {
  if (typeof value === 'string') {
    // Transparently convert pixels into rem units
    if (value.endsWith('px')) {
      return parseFloat(value) / 12 + 'rem';
    }
    return value;
  }
  if (typeof value === 'number') {
    return value + 'rem';
  }
};

/**
 * Same as `unit`, but half the size for integers numbers.
 */
export const halfUnit = (value: unknown) => {
  if (typeof value === 'string') {
    return unit(value);
  }
  if (typeof value === 'number') {
    return unit(value * 0.5);
  }
};

const isColorCode = (str: unknown) => !isColorClass(str);

const isColorClass = (str: unknown): boolean => {
  return typeof str === 'string' && CSS_COLORS.includes(str as any);
};

const mapRawPropTo = (attrName) => (style, value) => {
  if (typeof value === 'number' || typeof value === 'string') {
    style[attrName] = value;
  }
};

const mapUnitPropTo = (attrName, unit) => (style, value) => {
  if (typeof value === 'number' || typeof value === 'string') {
    style[attrName] = unit(value);
  }
};

const mapBooleanPropTo = (attrName, attrValue) => (style, value) => {
  if (value) {
    style[attrName] = attrValue;
  }
};

const mapDirectionalUnitPropTo = (attrName, unit, dirs) => (style, value) => {
  if (typeof value === 'number' || typeof value === 'string') {
    for (let i = 0; i < dirs.length; i++) {
      style[attrName + '-' + dirs[i]] = unit(value);
    }
  }
};

const mapColorPropTo = (attrName) => (style, value) => {
  if (isColorCode(value)) {
    style[attrName] = value;
  }
};

// String / number props
const stringStyleMap = {
  align: mapRawPropTo('textAlign'),
  bottom: mapUnitPropTo('bottom', unit),
  fontFamily: mapRawPropTo('fontFamily'),
  fontSize: mapUnitPropTo('fontSize', unit),
  fontWeight: mapRawPropTo('fontWeight'),
  height: mapUnitPropTo('height', unit),
  left: mapUnitPropTo('left', unit),
  maxHeight: mapUnitPropTo('maxHeight', unit),
  maxWidth: mapUnitPropTo('maxWidth', unit),
  minHeight: mapUnitPropTo('minHeight', unit),
  minWidth: mapUnitPropTo('minWidth', unit),
  opacity: mapRawPropTo('opacity'),
  overflow: mapRawPropTo('overflow'),
  overflowX: mapRawPropTo('overflowX'),
  overflowY: mapRawPropTo('overflowY'),
  position: mapRawPropTo('position'),
  right: mapUnitPropTo('right', unit),
  textAlign: mapRawPropTo('textAlign'),
  top: mapUnitPropTo('top', unit),
  verticalAlign: mapRawPropTo('verticalAlign'),
  width: mapUnitPropTo('width', unit),

  lineHeight: (style, value) => {
    if (typeof value === 'number') {
      style['lineHeight'] = value;
    } else if (typeof value === 'string') {
      style['lineHeight'] = unit(value);
    }
  },
  // Margin
  m: mapDirectionalUnitPropTo('margin', halfUnit, [
    'Top',
    'Bottom',
    'Left',
    'Right',
  ]),
  mb: mapUnitPropTo('marginBottom', halfUnit),
  ml: mapUnitPropTo('marginLeft', halfUnit),
  mr: mapUnitPropTo('marginRight', halfUnit),
  mt: mapUnitPropTo('marginTop', halfUnit),
  mx: mapDirectionalUnitPropTo('margin', halfUnit, ['Left', 'Right']),
  my: mapDirectionalUnitPropTo('margin', halfUnit, ['Top', 'Bottom']),
  // Padding
  p: mapDirectionalUnitPropTo('padding', halfUnit, [
    'Top',
    'Bottom',
    'Left',
    'Right',
  ]),
  pb: mapUnitPropTo('paddingBottom', halfUnit),
  pl: mapUnitPropTo('paddingLeft', halfUnit),
  pr: mapUnitPropTo('paddingRight', halfUnit),
  pt: mapUnitPropTo('paddingTop', halfUnit),
  px: mapDirectionalUnitPropTo('padding', halfUnit, ['Left', 'Right']),
  py: mapDirectionalUnitPropTo('padding', halfUnit, ['Top', 'Bottom']),
  // Color props
  color: mapColorPropTo('color'),
  textColor: mapColorPropTo('color'),
  backgroundColor: mapColorPropTo('backgroundColor'),
} as const;

// Boolean props
const booleanStyleMap = {
  bold: mapBooleanPropTo('fontWeight', 'bold'),
  fillPositionedParent: (style, value) => {
    if (value) {
      style['position'] = 'absolute';
      style['top'] = 0;
      style['bottom'] = 0;
      style['left'] = 0;
      style['right'] = 0;
    }
  },
  inline: mapBooleanPropTo('display', 'inline-block'),
  italic: mapBooleanPropTo('fontStyle', 'italic'),
  nowrap: mapBooleanPropTo('whiteSpace', 'nowrap'),
  preserveWhitespace: mapBooleanPropTo('whiteSpace', 'pre-wrap'),
} as const;

export const computeBoxProps = (props) => {
  const computedProps: Record<string, any> = {};
  const computedStyles: Record<string, string | number> = {};

  // Compute props
  for (let propName of Object.keys(props)) {
    if (propName === 'style') {
      continue;
    }

    const propValue = props[propName];

    const mapPropToStyle =
      stringStyleMap[propName] || booleanStyleMap[propName];

    if (mapPropToStyle) {
      mapPropToStyle(computedStyles, propValue);
    } else {
      computedProps[propName] = propValue;
    }
  }

  // Merge computed styles and any directly provided styles
  computedProps.style = { ...computedStyles, ...props.style };

  return computedProps;
};

export const computeBoxClassName = (props: BoxProps) => {
  const color = props.textColor || props.color;
  const backgroundColor = props.backgroundColor;
  return classes([
    isColorClass(color) && 'color-' + color,
    isColorClass(backgroundColor) && 'color-bg-' + backgroundColor,
  ]);
};

export const Box = (props: BoxProps & DangerDoNotUse) => {
  const { as = 'div', className, children, ...rest } = props;

  // Compute class name and styles
  const computedClassName = className
    ? `${className} ${computeBoxClassName(rest)}`
    : computeBoxClassName(rest);
  const computedProps = computeBoxProps(rest);

  if (as === 'img') {
    logger.error(
      'Box component cannot be used as an image. Use Image component instead.',
    );
  }

  // Render the component
  return createElement(
    typeof as === 'string' ? as : 'div',
    {
      ...computedProps,
      className: computedClassName,
    },
    children,
  );
};
