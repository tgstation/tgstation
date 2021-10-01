/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @author Original Aleksej Komarov
 * @author Changes ThePotato97
 * @license MIT
 */

import { classes, pureComponentHooks } from 'common/react';
import { Box } from './Box';

const FA_OUTLINE_REGEX = /-o$/;

export const Icon = props => {
  const {
    name,
    size,
    spin,
    className,
    style = {},
    rotation,
    inverse,
    ...rest
  } = props;
  if (size) {
    style['font-size'] = (size * 100) + '%';
  }
  if (typeof rotation === 'number') {
    style['transform'] = `rotate(${rotation}deg)`;
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
    <Box
      as="i"
      className={classes([
        'Icon',
        className,
        iconClass,
      ])}
      style={style}
      {...rest} />
  );
};

Icon.defaultHooks = pureComponentHooks;

export const IconStack = props => {
  const {
    className,
    style = {},
    children,
    ...rest
  } = props;
  return (
    <Box
      as="span"
      class={classes([
        'IconStack',
        className,
      ])}
      style={style}
      {...rest}>
      {children}
    </Box>
  );
};

Icon.Stack = IconStack;
