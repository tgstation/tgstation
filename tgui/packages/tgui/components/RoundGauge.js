/**
 * @file
 * @copyright 2020 bobbahbrown (https://github.com/bobbahbrown)
 * @license MIT
 */

import { clamp01, keyOfMatchingRange, scale } from 'common/math';
import { classes } from 'common/react';
import { AnimatedNumber } from './AnimatedNumber';
import { Box, computeBoxClassName, computeBoxProps } from './Box';

export const RoundGauge = props => {
  // Support for IE8 is for losers sorry B)
  if (Byond.IS_LTE_IE8) {
    return (
      <AnimatedNumber {...props} />
    );
  }

  const {
    value,
    minValue = 1,
    maxValue = 1,
    ranges,
    alertAfter,
    format,
    size = 1,
    className,
    style,
    ...rest
  } = props;

  const scaledValue = scale(
    value,
    minValue,
    maxValue);
  const clampedValue = clamp01(scaledValue);
  let scaledRanges = ranges ? {} : { "primary": [0, 1] };
  if (ranges)
  { Object.keys(ranges).forEach(x => {
    const range = ranges[x];
    scaledRanges[x] = [
      scale(range[0], minValue, maxValue),
      scale(range[1], minValue, maxValue),
    ];
  }); }

  let alertColor = null;
  if (alertAfter < value) {
    alertColor = keyOfMatchingRange(clampedValue, scaledRanges);
  }

  return (
    <Box inline>
      <div
        className={classes([
          'RoundGauge',
          className,
          computeBoxClassName(rest),
        ])}
        {...computeBoxProps({
          style: {
            'font-size': size + 'em',
            ...style,
          },
          ...rest,
        })}>
        <svg
          viewBox="0 0 100 50">
          {alertAfter && (
            <g className={classes([
              'RoundGauge__alert',
              alertColor ? `active RoundGauge__alert--${alertColor}` : '',
            ])}>
              <path d="M48.211,14.578C48.55,13.9 49.242,13.472 50,13.472C50.758,13.472 51.45,13.9 51.789,14.578C54.793,20.587 60.795,32.589 63.553,38.106C63.863,38.726 63.83,39.462 63.465,40.051C63.101,40.641 62.457,41 61.764,41C55.996,41 44.004,41 38.236,41C37.543,41 36.899,40.641 36.535,40.051C36.17,39.462 36.137,38.726 36.447,38.106C39.205,32.589 45.207,20.587 48.211,14.578ZM50,34.417C51.426,34.417 52.583,35.574 52.583,37C52.583,38.426 51.426,39.583 50,39.583C48.574,39.583 47.417,38.426 47.417,37C47.417,35.574 48.574,34.417 50,34.417ZM50,32.75C50,32.75 53,31.805 53,22.25C53,20.594 51.656,19.25 50,19.25C48.344,19.25 47,20.594 47,22.25C47,31.805 50,32.75 50,32.75Z" />
            </g>
          )}
          <g>
            <circle
              className="RoundGauge__ringTrack"
              cx="50"
              cy="50"
              r="45" />
          </g>
          <g>
            {Object.keys(scaledRanges).map((x, i) => {
              const col_ranges = scaledRanges[x];
              return (
                <circle
                  className={`RoundGauge__ringFill RoundGauge--color--${x}`}
                  key={i}
                  style={{
                    'stroke-dashoffset': (
                      Math.max((2.0 - (col_ranges[1] - col_ranges[0]))
                        * Math.PI * 50, 0)
                    ),
                  }}
                  transform={`rotate(${180 + 180 * col_ranges[0]} 50 50)`}
                  cx="50"
                  cy="50"
                  r="45" />
              );
            })}
          </g>
          <g
            className="RoundGauge__needle"
            transform={`rotate(${clampedValue * 180 - 90} 50 50)`}>
            <polygon
              className="RoundGauge__needleLine"
              points="46,50 50,0 54,50" />
            <circle
              className="RoundGauge__needleMiddle"
              cx="50"
              cy="50"
              r="8" />
          </g>
        </svg>
      </div>
      <AnimatedNumber
        value={value}
        format={format}
        size={size} />
    </Box>
  );
};
