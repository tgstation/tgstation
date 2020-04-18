import { clamp, keyOfMatchingRange, toFixed } from 'common/math';
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
  const scaledValue = (value - minValue) / (maxValue - minValue);
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
        className="ProgressBar__fill"
        style={{
          width: (clamp(scaledValue, 0, 1) * 100) + '%',
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
