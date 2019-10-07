import { classes, pureComponentHooks } from 'common/react';
import { createVNode } from 'inferno';
import { ChildFlags, VNodeFlags } from 'inferno-vnode-flags';

const REM_PX = 12;
const REM_PER_INTEGER = 0.5;

/**
 * Coverts our rem-like spacing unit into a CSS unit.
 */
const unit = value => {
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
    height,
    inline,
    m, mx, my, mt, mb, ml, mr,
    opacity,
    width,
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
      'opacity': unit(opacity),
      'width': unit(width),
      'height': unit(height),
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
