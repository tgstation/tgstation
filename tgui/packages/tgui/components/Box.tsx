/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { BooleanLike, classes, pureComponentHooks } from 'common/react';
import { createVNode } from 'inferno';
import { ChildFlags, VNodeFlags } from 'inferno-vnode-flags';
import { CSS_COLORS } from '../constants';

type StringMap = keyof typeof stringStyleMap;
type BooleanMap = keyof typeof booleanStyleMap;

export type BoxProps = Partial<CommonProps & MappedProps & AsType> & {
  children?: any;
};

type CommonProps = {
  className: string | boolean;
  key: string | number;
  id: string;
  onClick: (event?) => void;
  onmouseover: (event?) => void;
};

type MappedProps = {
  [key in StringMap]: string | number;
} &
  { [key in BooleanMap]: BooleanLike };

type AsType =
  | {
      as: 'div';
      style: Partial<Record<string, any>>; // these will be replaced with actual CSS properties
    }
  | {
      as: 'img';
      src: string;
      style: Partial<Record<string, any>>;
    }
  | {
      as: 'span';
      style: Partial<Record<string, any>>;
    }
  | {
      as: string;
    };

/**
 * Coverts our rem-like spacing unit into a CSS unit.
 */
export const unit = (value: unknown): string | undefined => {
  if (typeof value === 'string') {
    // Transparently convert pixels into rem units
    if (value.endsWith('px') && !Byond.IS_LTE_IE8) {
      return parseFloat(value) / 12 + 'rem';
    }
    return value;
  }
  if (typeof value === 'number') {
    if (Byond.IS_LTE_IE8) {
      return value * 12 + 'px';
    }
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

// String and number props
const stringStyleMap = {
  // Direct mapping
  align: mapRawPropTo('align'),
  bottom: mapUnitPropTo('bottom', unit),
  fontFamily: mapRawPropTo('font-family'),
  fontSize: mapUnitPropTo('font-size', unit),
  height: mapUnitPropTo('height', unit),
  left: mapUnitPropTo('left', unit),
  maxHeight: mapUnitPropTo('max-height', unit),
  maxWidth: mapUnitPropTo('max-width', unit),
  minHeight: mapUnitPropTo('min-height', unit),
  minWidth: mapUnitPropTo('min-width', unit),
  opacity: mapRawPropTo('opacity'),
  overflow: mapRawPropTo('overflow'),
  overflowX: mapRawPropTo('overflow-x'),
  overflowY: mapRawPropTo('overflow-y'),
  position: mapRawPropTo('position'),
  right: mapUnitPropTo('right', unit),
  textAlign: mapRawPropTo('text-align'),
  top: mapUnitPropTo('top', unit),
  verticalAlign: mapRawPropTo('vertical-align'),
  width: mapUnitPropTo('width', unit),
  lineHeight: (style, value) => {
    if (typeof value === 'number') {
      style['line-height'] = value;
    } else if (typeof value === 'string') {
      style['line-height'] = unit(value);
    }
  },
  // Margin
  m: mapDirectionalUnitPropTo('margin', halfUnit, [
    'top',
    'bottom',
    'left',
    'right',
  ]),
  mx: mapDirectionalUnitPropTo('margin', halfUnit, ['left', 'right']),
  my: mapDirectionalUnitPropTo('margin', halfUnit, ['top', 'bottom']),
  mt: mapUnitPropTo('margin-top', halfUnit),
  mb: mapUnitPropTo('margin-bottom', halfUnit),
  ml: mapUnitPropTo('margin-left', halfUnit),
  mr: mapUnitPropTo('margin-right', halfUnit),
  // Padding
  p: mapDirectionalUnitPropTo('padding', halfUnit, [
    'top',
    'bottom',
    'left',
    'right',
  ]),
  px: mapDirectionalUnitPropTo('padding', halfUnit, ['left', 'right']),
  py: mapDirectionalUnitPropTo('padding', halfUnit, ['top', 'bottom']),
  pt: mapUnitPropTo('padding-top', halfUnit),
  pb: mapUnitPropTo('padding-bottom', halfUnit),
  pl: mapUnitPropTo('padding-left', halfUnit),
  pr: mapUnitPropTo('padding-right', halfUnit),
  // Color props
  color: mapColorPropTo('color'),
  textColor: mapColorPropTo('color'),
  backgroundColor: mapColorPropTo('background-color'),
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
const booleanStyleMap = {
  bold: mapBooleanPropTo('font-weight', 'bold'),
  inline: mapBooleanPropTo('display', 'inline-block'),
  italic: mapBooleanPropTo('font-style', 'italic'),
  nowrap: mapBooleanPropTo('white-space', 'nowrap'),
  preserveWhitespace: mapBooleanPropTo('white-space', 'pre-wrap'),
  wrap: mapBooleanPropTo('white-space', 'normal'),
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

  // Concatenate styles
  let style = '';
  for (let attrName of Object.keys(computedStyles)) {
    const attrValue = computedStyles[attrName];
    style += attrName + ':' + attrValue + ';';
  }
  if (props.style) {
    for (let attrName of Object.keys(props.style)) {
      const attrValue = props.style[attrName];
      style += attrName + ':' + attrValue + ';';
    }
  }
  if (style.length > 0) {
    computedProps.style = style;
  }

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
  // Render props
  if (typeof children === 'function') {
    return children(computeBoxProps(props));
  }
  // Compute class name and styles
  const computedClassName = className
    ? `${className} ${computeBoxClassName(rest)}`
    : computeBoxClassName(rest);

  const computedProps = computeBoxProps(rest);

  // Render a wrapper element
  return createVNode(
    VNodeFlags.HtmlElement,
    as,
    computedClassName,
    children,
    ChildFlags.UnknownChildren,
    computedProps,
    undefined
  );
};

Box.defaultHooks = pureComponentHooks;
