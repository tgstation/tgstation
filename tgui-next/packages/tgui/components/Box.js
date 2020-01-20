import { classes, isFalsy, pureComponentHooks } from 'common/react';
import { createVNode } from 'inferno';
import { ChildFlags, VNodeFlags } from 'inferno-vnode-flags';
import { CSS_COLORS } from '../constants';

const UNIT_PX = 6;

/**
 * Coverts our rem-like spacing unit into a CSS unit.
 */
export const unit = value => {
  if (typeof value === 'string') {
    return value;
  }
  if (typeof value === 'number') {
    return (value * UNIT_PX) + 'px';
  }
};

const isColorCode = str => !isColorClass(str);

const isColorClass = str => typeof str === 'string'
  && CSS_COLORS.includes(str);

const mapRawPropTo = attrName => (style, value) => {
  if (!isFalsy(value)) {
    style[attrName] = value;
  }
};

const mapUnitPropTo = attrName => (style, value) => {
  if (!isFalsy(value)) {
    style[attrName] = unit(value);
  }
};

const mapBooleanPropTo = (attrName, attrValue) => (style, value) => {
  if (!isFalsy(value)) {
    style[attrName] = attrValue;
  }
};

const mapDirectionalUnitPropTo = (attrName, dirs) => (style, value) => {
  if (!isFalsy(value)) {
    for (let i = 0; i < dirs.length; i++) {
      style[attrName + '-' + dirs[i]] = unit(value);
    }
  }
};

const mapColorPropTo = attrName => (style, value) => {
  if (isColorCode(value)) {
    style[attrName] = value;
  }
};

const styleMapperByPropName = {
  // Direct mapping
  position: mapRawPropTo('position'),
  overflow: mapRawPropTo('overflow'),
  overflowX: mapRawPropTo('overflow-x'),
  overflowY: mapRawPropTo('overflow-y'),
  top: mapUnitPropTo('top'),
  bottom: mapUnitPropTo('bottom'),
  left: mapUnitPropTo('left'),
  right: mapUnitPropTo('right'),
  width: mapUnitPropTo('width'),
  minWidth: mapUnitPropTo('min-width'),
  maxWidth: mapUnitPropTo('max-width'),
  height: mapUnitPropTo('height'),
  minHeight: mapUnitPropTo('min-height'),
  maxHeight: mapUnitPropTo('max-height'),
  fontSize: mapUnitPropTo('font-size'),
  fontFamily: mapRawPropTo('font-family'),
  lineHeight: mapUnitPropTo('line-height'),
  opacity: mapRawPropTo('opacity'),
  textAlign: mapRawPropTo('text-align'),
  verticalAlign: mapRawPropTo('vertical-align'),
  // Boolean props
  inline: mapBooleanPropTo('display', 'inline-block'),
  bold: mapBooleanPropTo('font-weight', 'bold'),
  italic: mapBooleanPropTo('font-style', 'italic'),
  nowrap: mapBooleanPropTo('white-space', 'nowrap'),
  // Margins
  m: mapDirectionalUnitPropTo('margin', ['top', 'bottom', 'left', 'right']),
  mx: mapDirectionalUnitPropTo('margin', ['left', 'right']),
  my: mapDirectionalUnitPropTo('margin', ['top', 'bottom']),
  mt: mapUnitPropTo('margin-top'),
  mb: mapUnitPropTo('margin-bottom'),
  ml: mapUnitPropTo('margin-left'),
  mr: mapUnitPropTo('margin-right'),
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
};

export const computeBoxProps = props => {
  const computedProps = {};
  const computedStyles = {};
  // Compute props
  for (let propName of Object.keys(props)) {
    if (propName === 'style') {
      continue;
    }
    const propValue = props[propName];
    const mapPropToStyle = styleMapperByPropName[propName];
    if (mapPropToStyle) {
      mapPropToStyle(computedStyles, propValue);
    }
    else {
      computedProps[propName] = propValue;
    }
  }
  // Concatenate styles
  Object.assign(computedStyles, props.style);
  let style = '';
  for (let attrName of Object.keys(computedStyles)) {
    const attrValue = computedStyles[attrName];
    style += attrName + ':' + attrValue + ';';
  }
  if (style.length > 0) {
    computedProps.style = style;
  }
  return computedProps;
};

export const Box = props => {
  const {
    as = 'div',
    className,
    content,
    children,
    ...rest
  } = props;
  const color = props.textColor || props.color;
  const backgroundColor = props.backgroundColor;
  // Render props
  if (typeof children === 'function') {
    return children(computeBoxProps(props));
  }
  const computedProps = computeBoxProps(rest);
  // Render a wrapper element
  return createVNode(
    VNodeFlags.HtmlElement,
    as,
    classes([
      className,
      isColorClass(color) && 'color-' + color,
      isColorClass(backgroundColor) && 'color-bg-' + backgroundColor,
    ]),
    content || children,
    ChildFlags.UnknownChildren,
    computedProps);
};

Box.defaultHooks = pureComponentHooks;

/**
 * A hack to force certain things (like tables) to position correctly
 * inside bugged things, like Flex in Internet Explorer.
 */
const ForcedBox = props => {
  const { children, ...rest } = props;
  return (
    <Box position="relative" {...rest}>
      <Box fillPositionedParent>
        {children}
      </Box>
    </Box>
  );
};

ForcedBox.defaultHooks = pureComponentHooks;

Box.Forced = ForcedBox;
