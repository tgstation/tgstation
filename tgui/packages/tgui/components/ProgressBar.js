/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { clamp01, scale, keyOfMatchingRange, toFixed } from 'common/math';
import { classes, pureComponentHooks } from 'common/react';
import { computeBoxClassName, computeBoxProps } from './Box';
import { CSS_COLORS } from '../constants';

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

  // We permit colors to be in hex format, rgb()/rgba() format,
  // a name for a color-<name> class, or a base CSS class.
  const outerProps = computeBoxProps(rest);
  const outerClasses = [
    'ProgressBar',
    className,
    computeBoxClassName(rest),
  ];
  const fillStyles = {
    'width': clamp01(scaledValue) * 100 + '%',
  };
  if (CSS_COLORS.includes(effectiveColor) || effectiveColor === 'default') {
    // If the color is a color-<name> class, just use that.
    outerClasses.push('ProgressBar--color--' + effectiveColor);
  } else {
    // Otherwise, set styles directly.
    outerProps.style = (outerProps.style || "")
      + `border-color: ${effectiveColor};`;
    fillStyles['background-color'] = effectiveColor;
  }

  return (
    <div
      className={classes(outerClasses)}
      {...outerProps}>
      <div
        className="ProgressBar__fill ProgressBar__fill--animated"
        style={fillStyles} />
      <div className="ProgressBar__content">
        {hasContent
          ? children
          : toFixed(scaledValue * 100) + '%'}
      </div>
    </div>
  );
};

ProgressBar.defaultHooks = pureComponentHooks;
