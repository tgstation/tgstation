import { classes } from 'react-tools';
import { createVNode } from 'inferno';
import { VNodeFlags, ChildFlags } from 'inferno-vnode-flags';

const REM_PX = 12;
const REM_PER_INTEGER = 0.5;

/**
 * Coverts our rem-like spacing unit into a CSS unit.
 */
const unit = value => value
  ? (value * REM_PX * REM_PER_INTEGER) + 'px'
  : undefined;

/**
 * Nullish coalesce function
 */
const firstDefined = (...args) => {
  for (let arg of args) {
    if (arg !== undefined && arg !== null) {
      return arg;
    }
  }
};

export const computeBoxProps = props => {
  const {
    className,
    color,
    height,
    inline,
    m = 0, mx, my, mt, mb, ml, mr,
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
      display: inline ? 'inline-block' : undefined,
      ...rest.style,
      'margin-top':    unit(firstDefined(mt, my, m)),
      'margin-bottom': unit(firstDefined(mb, my, m)),
      'margin-left':   unit(firstDefined(ml, mx, m)),
      'margin-right':  unit(firstDefined(mr, mx, m)),
      opacity,
      width,
      height,
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
