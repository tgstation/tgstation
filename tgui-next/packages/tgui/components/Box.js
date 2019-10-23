import { classes, pureComponentHooks } from 'common/react';
import { createVNode } from 'inferno';
import { ChildFlags, VNodeFlags } from 'inferno-vnode-flags';

const REM_PX = 12;
const REM_PER_INTEGER = 0.5;

/**
 * Coverts our rem-like spacing unit into a CSS unit.
 */
export const unit = value => {
  if (typeof value === 'string') {
    return value;
  }
  if (typeof value === 'number') {
    return (value * REM_PX * REM_PER_INTEGER) + 'px';
  }
};

/**
 * Nullish coalesce function
 */
const firstDefined = (...args) => {
  return args.find(arg => arg !== undefined && arg !== null);
};

export const computeBoxProps = props => {
  const {
    className,
    color,
    width,
    minWidth,
    maxWidth,
    height,
    minHeight,
    maxHeight,
    fontSize,
    lineHeight,
    inline,
    m, mx, my, mt, mb, ml, mr,
    opacity,
    bold,
    italic,
    textAlign,
    position,
    top,
    left,
    right,
    bottom,
    ...rest
  } = props;
  return {
    ...rest,
    className: classes([
      className,
      color && 'color-' + color,
    ]),
    style: {
      'display': inline ? 'inline-block' : undefined,
      'margin-top': unit(firstDefined(mt, my, m)),
      'margin-bottom': unit(firstDefined(mb, my, m)),
      'margin-left': unit(firstDefined(ml, mx, m)),
      'margin-right': unit(firstDefined(mr, mx, m)),
      'opacity': opacity,
      'width': unit(width),
      'min-width': unit(minWidth),
      'max-width': unit(maxWidth),
      'height': unit(height),
      'min-height': unit(minHeight),
      'max-height': unit(maxHeight),
      'font-size': unit(fontSize),
      'line-height': unit(lineHeight),
      'font-weight': bold ? 'bold' : undefined,
      'font-style': italic ? 'italic' : undefined,
      'text-align': textAlign,
      'position': position,
      'top': unit(top),
      'left': unit(left),
      'right': unit(right),
      'bottom': unit(bottom),
      ...rest.style,
    },
  };
};

export const Box = props => {
  const { as = 'div', content, children, ...rest } = props;
  // Render props
  if (typeof children === 'function') {
    return children(computeBoxProps(props));
  }
  const { className, ...computedProps } = computeBoxProps(rest);
  // Render a wrapper element
  return createVNode(
    VNodeFlags.HtmlElement,
    as,
    className,
    content || children,
    ChildFlags.UnknownChildren,
    computedProps);
};

Box.defaultHooks = pureComponentHooks;
