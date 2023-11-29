/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { BooleanLike, classes, pureComponentHooks } from 'common/react';
import { createElement } from 'react';
import { CSS_COLORS } from '../constants';

type StringMap = keyof typeof styleStringNumberMap;
type BooleanMap = keyof typeof styleBooleanMap;

export type BoxProps = {
  [key in StringMap]?: string | number;
} &
  { [key in BooleanMap]?: boolean } &
  Record<string, string | BooleanLike>;

/**
 * Coverts our rem-like spacing unit into a CSS unit.
 */
export const unit = (value: unknown): string | undefined => {
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
export const halfUnit = (value: unknown): string | undefined => {
  if (typeof value === 'string') {
    return unit(value);
  }
  if (typeof value === 'number') {
    return unit(value * 0.5);
  }
};

const isColorCode = (str: unknown) => !isColorClass(str);

const isColorClass = (str: unknown): boolean => {
  return typeof str === 'string' && CSS_COLORS.includes(str);
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
const styleStringNumberMap = {
  position: mapRawPropTo('position'),
  overflow: mapRawPropTo('overflow'),
  overflowX: mapRawPropTo('overflowX'),
  overflowY: mapRawPropTo('overflowY'),
  top: mapUnitPropTo('top', unit),
  bottom: mapUnitPropTo('bottom', unit),
  left: mapUnitPropTo('left', unit),
  right: mapUnitPropTo('right', unit),
  width: mapUnitPropTo('width', unit),
  minWidth: mapUnitPropTo('minWidth', unit),
  maxWidth: mapUnitPropTo('maxWidth', unit),
  height: mapUnitPropTo('height', unit),
  minHeight: mapUnitPropTo('minHeight', unit),
  maxHeight: mapUnitPropTo('maxHeight', unit),
  fontSize: mapUnitPropTo('fontSize', unit),
  fontFamily: mapRawPropTo('fontFamily'),
  opacity: mapRawPropTo('opacity'),
  textAlign: mapRawPropTo('textAlign'),
  verticalAlign: mapRawPropTo('verticalAlign'),

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
  mx: mapDirectionalUnitPropTo('margin', halfUnit, ['Left', 'Right']),
  my: mapDirectionalUnitPropTo('margin', halfUnit, ['Top', 'Bottom']),
  mt: mapUnitPropTo('marginTop', halfUnit),
  mb: mapUnitPropTo('marginBottom', halfUnit),
  ml: mapUnitPropTo('marginLeft', halfUnit),
  mr: mapUnitPropTo('marginRight', halfUnit),
  // Padding
  p: mapDirectionalUnitPropTo('padding', halfUnit, [
    'Top',
    'Bottom',
    'Left',
    'Right',
  ]),
  px: mapDirectionalUnitPropTo('padding', halfUnit, ['Left', 'Right']),
  py: mapDirectionalUnitPropTo('padding', halfUnit, ['Top', 'Bottom']),
  pt: mapUnitPropTo('paddingTop', halfUnit),
  pb: mapUnitPropTo('paddingBottom', halfUnit),
  pl: mapUnitPropTo('paddingLeft', halfUnit),
  pr: mapUnitPropTo('paddingRight', halfUnit),
  // Color props
  color: mapColorPropTo('color'),
  textColor: mapColorPropTo('color'),
  backgroundColor: mapColorPropTo('backgroundColor'),

  // Utility props
  fillPositionedParent: (style, value) => {
    if (value) {
      style['position'] = 'absolute';
      style['top'] = 0;
      style['bottom'] = 0;
      style['left'] = 0;
      style['right'] = 0;
    }
  },
} as const;

// Boolean props
const styleBooleanMap = {
  inline: mapBooleanPropTo('display', 'inlineBlock'),
  bold: mapBooleanPropTo('fontWeight', 'bold'),
  italic: mapBooleanPropTo('fontStyle', 'italic'),
  nowrap: mapBooleanPropTo('whiteSpace', 'nowrap'),
  preserveWhitespace: mapBooleanPropTo('whiteSpace', 'preWrap'),
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

    let mapPropToStyle;
    if (typeof propValue === 'boolean') {
      mapPropToStyle = styleBooleanMap[propName];
    } else {
      mapPropToStyle = styleStringNumberMap[propName];
    }

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

export const Box = (props: BoxProps) => {
  const { as = 'div', className, children, ...rest } = props;

  // Compute class name and styles
  const computedClassName = className
    ? `${className} ${computeBoxClassName(rest)}`
    : computeBoxClassName(rest);
  const computedProps = computeBoxProps(rest);

  // Render the component
  return createElement(
    typeof as === 'string' ? as : 'div',
    {
      ...computedProps,
      className: computedClassName,
    },
    children
  );
};

Box.defaultHooks = pureComponentHooks;
