/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { clamp01, scale, keyOfMatchingRange, toFixed } from 'common/math';
import { classes, pureComponentHooks } from 'common/react';
import { computeBoxClassName, computeBoxProps } from './Box';

export const ProgressBar = props => {
  const {
    className,
    value,
    minValue = 0,
    maxValue = 1,
    color,
    ranges = {},
    children,
    ...rest
  } = props;
  const scaledValue = scale(value, minValue, maxValue);
  const hasContent = children !== undefined;
  const effectiveColor = color
    || keyOfMatchingRange(value, ranges)
    || 'default';
  return (
    <div
      className={classes([
        'ProgressBar',
        'ProgressBar--color--' + effectiveColor,
        className,
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}>
      <div
        className="ProgressBar__fill ProgressBar__fill--animated"
        style={{
          width: clamp01(scaledValue) * 100 + '%',
        }} />
      <div className="ProgressBar__content">
        {hasContent
          ? children
          : toFixed(scaledValue * 100) + '%'}
      </div>
    </div>
  );
};

ProgressBar.defaultHooks = pureComponentHooks;
