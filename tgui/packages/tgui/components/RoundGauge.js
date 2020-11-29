/**
 * @file
 * @copyright 2020 bobbahbrown (https://github.com/bobbahbrown)
 * @license MIT
 */

import { scale, clamp01 } from 'common/math';
import { classes } from 'common/react';
import { computeBoxClassName, computeBoxProps, Box } from './Box';
import { AnimatedNumber } from './AnimatedNumber';

export const RoundGauge = props => {
  // Support for IE8 is for losers sorry B)
  if (Byond.IS_LTE_IE8) {
    return (
      <AnimatedNumber {...props} />
    );
  }

  const {
    maxValue,
    minValue,
    value,
    format,
    className,
    style,
    ranges,
    size = 1,
    children,
    ...rest
  } = props;

  const scaledValue = scale(
    value,
    minValue,
    maxValue);
  const clampedValue = clamp01(scaledValue);
  let scaledRanges = ranges ? {} : { "primary": [0, 1] };
  if (ranges)
    Object.keys(ranges).forEach(x => {
      const range = ranges[x];
      scaledRanges[x] = [
        scale(range[0], minValue, maxValue),
        scale(range[1], minValue, maxValue),
      ];
    });

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
          <g>
            <circle
              className="RoundGauge__ringTrack"
              // transform={`rotate(180 50 50)`}
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
          <g transform={`rotate(${clampedValue * 180 - 90} 50 50)`}>
            <polygon
              className="RoundGauge__needleLine"
              points="46,50 50,0 54,50" />
            <circle
              className="RoundGauge__needleMiddle"
              cx="50"
              cy="50"
              r="8" />
          </g>
          <g transform="matrix(1.92196,0,0,1.92196,-85.6242,-8.14155)">
            <path d="M92.106,4.789C92.275,4.45 92.621,4.236 93,4.236C93.379,4.236 93.725,4.45 93.894,4.789C94.613,6.225 95.608,8.216 96.276,9.553C96.431,9.863 96.415,10.231 96.233,10.526C96.05,10.821 95.729,11 95.382,11C93.994,11 92.006,11 90.618,11C90.271,11 89.95,10.821 89.767,10.526C89.585,10.231 89.569,9.863 89.724,9.553L92.106,4.789ZM93.5,9.5C93.5,9.224 93.276,9 93,9C92.724,9 92.5,9.224 92.5,9.5C92.5,9.776 92.724,10 93,10C93.276,10 93.5,9.776 93.5,9.5ZM93.5,6C93.5,5.724 93.276,5.5 93,5.5C92.724,5.5 92.5,5.724 92.5,6L92.5,8C92.5,8.276 92.724,8.5 93,8.5C93.276,8.5 93.5,8.276 93.5,8L93.5,6Z" />
          </g>
        </svg>
      </div>
      <AnimatedNumber
        value={value}
        format={format}
        size={size} />
    </Box>
  );
}
