/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @author Original Aleksej Komarov
 * @author Changes ThePotato97
 * @license MIT
 */

import { classes, pureComponentHooks } from 'common/react';
import { computeBoxClassName, computeBoxProps } from './Box';

const FA_OUTLINE_REGEX = /-o$/;

export const Icon = props => {
  const {
    name,
    size,
    spin,
    className,
    rotation,
    inverse,
    ...rest
  } = props;
  const boxProps = computeBoxProps(rest);
  if (size) {
    if (!boxProps.style) {
      boxProps.style = {};
    }
    boxProps.style['font-size'] = (size * 100) + '%';
  }
  if (typeof rotation === 'number') {
    if (!boxProps.style) {
      boxProps.style = {};
    }
    boxProps.style['transform'] = `rotate(${rotation}deg)`;
  }
  let iconClass = "";
  if (name.startsWith("tg-")) {
    // tgfont icon
    iconClass = name;
  } else {
    // font awesome icon
    const faRegular = FA_OUTLINE_REGEX.test(name);
    const faName = name.replace(FA_OUTLINE_REGEX, '');
    iconClass = (faRegular ? 'far ' : 'fas ') + 'fa-'+ faName + (spin ? " fa-spin" : "");
  }
  return (
    <i
      className={classes([
        'Icon',
        iconClass,
        className,
        computeBoxClassName(rest),
      ])}
      {...boxProps} />
  );
};

Icon.defaultHooks = pureComponentHooks;

export const IconStack = props => {
  const {
    className,
    children,
    ...rest
  } = props;
  return (
    <span
      class={classes([
        'IconStack',
        className,
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}>
      {children}
    </span>
  );
};

Icon.Stack = IconStack;
