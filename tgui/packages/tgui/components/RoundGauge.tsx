/**
 * @file
 * @copyright 2020 bobbahbrown (https://github.com/bobbahbrown)
 * @license MIT
 */

import { clamp01, keyOfMatchingRange, scale } from 'common/math';
import { classes } from 'common/react';

import { AnimatedNumber } from './AnimatedNumber';
import { Box, BoxProps, computeBoxClassName, computeBoxProps } from './Box';

type Props = {
  /** The current value of the metric. */
  value: number;
} & Partial<{
  /** When provided, will cause an alert symbol on the gauge to begin flashing in the color upon which the needle currently rests, as defined in `ranges`. */
  alertAfter: number;
  /** As with alertAfter, but alerts below a value. If both are set, and alertAfter comes earlier, the alert will only flash when the needle is between both values. Otherwise, the alert will flash when on the active side of either threshold. */
  alertBefore: number;
  /** CSS style. */
  className: string;
  /** When provided, will be used to format the value of the metric for display. */
  format: (value: number) => string;
  /** The upper bound of the gauge. */
  maxValue: number;
  /** The lower bound of the gauge. */
  minValue: number;
  /** Provide regions of the gauge to color between two specified values of the metric. */
  ranges: Record<string, [number, number]>;
  /** When provided scales the gauge. */
  size: number;
  /** Custom css */
  style: React.CSSProperties;
}> &
  BoxProps;

/**
 * ## RoundGauge
 * The RoundGauge component provides a visual representation of a single metric, as well as being capable of showing
 * informational or cautionary boundaries related to that metric.
 *
 * @example
 * ```tsx
 * <RoundGauge
 *  size={1.75}
 *  value={tankPressure}
 *  minValue={0}
 *  maxValue={pressureLimit}
 *  alertAfter={pressureLimit * 0.7}
 *  ranges={{
 *     good: [0, pressureLimit * 0.7],
 *     average: [pressureLimit * 0.7, pressureLimit * 0.85],
 *     bad: [pressureLimit * 0.85, pressureLimit],
 *   }}
 *   format={formatPressure}
 * />
 * ```
 *
 * The alert on the gauge is optional, and will only be shown if the `alertAfter` prop is defined. When defined, the alert
 * will begin to flash the respective color upon which the needle currently rests, as defined in the `ranges` prop.
 *
 */
export function RoundGauge(props: Props) {
  const {
    alertAfter,
    alertBefore,
    className,
    format,
    maxValue = 1,
    minValue = 1,
    ranges,
    size = 1,
    style,
    value,
    ...rest
  } = props;

  const scaledValue = scale(value, minValue, maxValue);
  const clampedValue = clamp01(scaledValue);
  const scaledRanges = ranges ? {} : { primary: [0, 1] };

  if (ranges) {
    Object.keys(ranges).forEach((x) => {
      const range = ranges[x];
      scaledRanges[x] = [
        scale(range[0], minValue, maxValue),
        scale(range[1], minValue, maxValue),
      ];
    });
  }

  function shouldShowAlert() {
    // If both after and before alert props are set, and value is between them
    if (
      alertAfter &&
      alertBefore &&
      value > alertAfter &&
      value < alertBefore
    ) {
      return true;
    }
    // If only alertAfter is set and value is greater than alertAfter
    else if (alertAfter && value > alertAfter) {
      return true;
    }
    // If only alertBefore is set and value is less than alertBefore
    else if (alertBefore && value < alertBefore) {
      return true;
    }
    // If none of the above conditions are met
    return false;
  }

  const alertColor =
    shouldShowAlert() && keyOfMatchingRange(clampedValue, scaledRanges);

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
            fontSize: size + 'em',
            ...style,
          },
          ...rest,
        })}
      >
        <svg viewBox="0 0 100 50">
          {(alertAfter || alertBefore) && (
            <g
              className={classes([
                'RoundGauge__alert',
                alertColor ? `active RoundGauge__alert--${alertColor}` : '',
              ])}
            >
              <path d="M48.211,14.578C48.55,13.9 49.242,13.472 50,13.472C50.758,13.472 51.45,13.9 51.789,14.578C54.793,20.587 60.795,32.589 63.553,38.106C63.863,38.726 63.83,39.462 63.465,40.051C63.101,40.641 62.457,41 61.764,41C55.996,41 44.004,41 38.236,41C37.543,41 36.899,40.641 36.535,40.051C36.17,39.462 36.137,38.726 36.447,38.106C39.205,32.589 45.207,20.587 48.211,14.578ZM50,34.417C51.426,34.417 52.583,35.574 52.583,37C52.583,38.426 51.426,39.583 50,39.583C48.574,39.583 47.417,38.426 47.417,37C47.417,35.574 48.574,34.417 50,34.417ZM50,32.75C50,32.75 53,31.805 53,22.25C53,20.594 51.656,19.25 50,19.25C48.344,19.25 47,20.594 47,22.25C47,31.805 50,32.75 50,32.75Z" />
            </g>
          )}
          <g>
            <circle className="RoundGauge__ringTrack" cx="50" cy="50" r="45" />
          </g>
          <g>
            {Object.keys(scaledRanges).map((x, i) => {
              const col_ranges = scaledRanges[x];
              return (
                <circle
                  className={`RoundGauge__ringFill RoundGauge--color--${x}`}
                  key={i}
                  style={{
                    strokeDashoffset: Math.max(
                      (2.0 - (col_ranges[1] - col_ranges[0])) * Math.PI * 50,
                      0,
                    ),
                  }}
                  transform={`rotate(${180 + 180 * col_ranges[0]} 50 50)`}
                  cx="50"
                  cy="50"
                  r="45"
                />
              );
            })}
          </g>
          <g
            className="RoundGauge__needle"
            transform={`rotate(${clampedValue * 180 - 90} 50 50)`}
          >
            <polygon
              className="RoundGauge__needleLine"
              points="46,50 50,0 54,50"
            />
            <circle
              className="RoundGauge__needleMiddle"
              cx="50"
              cy="50"
              r="8"
            />
          </g>
        </svg>
      </div>
      <AnimatedNumber value={value} format={format} />
    </Box>
  );
}
