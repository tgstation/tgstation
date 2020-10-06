/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes, pureComponentHooks } from 'common/react';
import { Box } from './Box';

const FA_OUTLINE_REGEX = /-o$/;

export const Icon = props => {
  const { name, size, spin, className, style = {}, rotation, ...rest } = props;
  if (size) {
    style['font-size'] = (size * 100) + '%';
  }
  if (typeof rotation === 'number') {
    style['transform'] = `rotate(${rotation}deg)`;
  }
  const faRegular = FA_OUTLINE_REGEX.test(name);
  const faName = name.replace(FA_OUTLINE_REGEX, '');
  return (
    <Box
      as="i"
      className={classes([
        className,
        faRegular ? 'far' : 'fas',
        'fa-' + faName,
        spin && 'fa-spin',
      ])}
      style={style}
      {...rest} />
  );
};

Icon.defaultHooks = pureComponentHooks;

export const IconStack = props => {
  const { nameTop, nameBottom, size, spin, className, style = {}, rotation, sizeBottom='1x', sizeTop='1x', ...rest } = props;
  if (size) {
    style['font-size'] = (size * 100) + '%';
  }
  if (typeof rotation === 'number') {
    style['transform'] = `rotate(${rotation}deg)`;
  }
  const faRegularBottom = FA_OUTLINE_REGEX.test(nameTop);
  const faRegularTop = FA_OUTLINE_REGEX.test(nameBottom);
  const faNameBottom = nameTop.replace(FA_OUTLINE_REGEX, '');
  const faNameTop = nameBottom.replace(FA_OUTLINE_REGEX, '');
  return (
    <Box
      as="span"
      class="fa-stack">
      <Box
        as="i"
        className={classes([
          className,
          faRegularBottom ? 'far' : 'fas',
          'fa-' + faNameBottom,
          spin && 'fa-spin',
          'fa-stack-' + sizeBottom,
        ])}
        style={style}
        {...rest} />
      <Box
        as="i"
        className={classes([
          className,
          faRegularTop ? 'far' : 'fas',
          'fa-' + faNameTop,
          spin && 'fa-spin',
          'fa-stack-' + sizeTop,
        ])}
        style={style}
        {...rest} />
    </Box>
  );
};


Icon.Stack = IconStack;
