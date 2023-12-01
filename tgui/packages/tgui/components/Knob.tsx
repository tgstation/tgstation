/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { keyOfMatchingRange, scale } from 'common/math';
import { classes } from 'common/react';
import { BoxProps, computeBoxClassName, computeBoxProps } from './Box';
import { DraggableControl } from './DraggableControl';

type Props = Partial<{
  animated: boolean;
  bipolar: boolean;
  children: any;
  className: string;
  color: string;
  fillValue: number;
  format: string;
  maxValue: number;
  minValue: number;
  onChange: (event: Event, value: number) => void;
  onDrag: (event: Event, value: number) => void;
  ranges: Record<string, number[]>;
  size: number;
  step: number;
  stepPixelSize: number;
  style: Partial<HTMLDivElement['style']>;
  suppressFlicker: boolean;
  unclamped: boolean;
  unit: string;
  value: number;
}> &
  BoxProps;

export const Knob = (props: Props) => {
  const {
    // Draggable props (passthrough)
    animated,
    format,
    maxValue,
    minValue,
    unclamped,
    onChange,
    onDrag,
    step,
    stepPixelSize,
    suppressFlicker,
    unit,
    value,
    // Own props
    className,
    style,
    fillValue,
    color,
    ranges = {},
    size = 1,
    bipolar,
    children,
    ...rest
  } = props;

  return (
    <DraggableControl
      dragMatrix={[0, -1]}
      {...{
        animated,
        format,
        maxValue,
        minValue,
        unclamped,
        onChange,
        onDrag,
        step,
        stepPixelSize,
        suppressFlicker,
        unit,
        value,
      }}>
      {(control) => {
        const {
          dragging,
          editing,
          value,
          displayValue,
          displayElement,
          inputElement,
          handleDragStart,
        } = control;
        const scaledFillValue = scale(
          fillValue ?? displayValue,
          minValue,
          maxValue
        );
        const scaledDisplayValue = scale(displayValue, minValue, maxValue);
        const effectiveColor =
          color || keyOfMatchingRange(fillValue ?? value, ranges) || 'default';
        const rotation = Math.min((scaledDisplayValue - 0.5) * 270, 225);
        return (
          <div
            className={classes([
              'Knob',
              'Knob--color--' + effectiveColor,
              bipolar && 'Knob--bipolar',
              className,
              computeBoxClassName(rest),
            ])}
            {...computeBoxProps({
              style: {
                'font-size': size + 'em',
                ...style,
              },
              ...rest,
            })}
            onMouseDown={handleDragStart}>
            <div className="Knob__circle">
              <div
                className="Knob__cursorBox"
                style={{
                  transform: `rotate(${rotation}deg)`,
                }}>
                <div className="Knob__cursor" />
              </div>
            </div>
            {dragging && (
              <div className="Knob__popupValue">{displayElement}</div>
            )}
            <svg
              className="Knob__ring Knob__ringTrackPivot"
              viewBox="0 0 100 100">
              <circle className="Knob__ringTrack" cx="50" cy="50" r="50" />
            </svg>
            <svg
              className="Knob__ring Knob__ringFillPivot"
              viewBox="0 0 100 100">
              <circle
                className="Knob__ringFill"
                style={{
                  'stroke-dashoffset': Math.max(
                    ((bipolar ? 2.75 : 2.0) - scaledFillValue * 1.5) *
                      Math.PI *
                      50,
                    0
                  ),
                }}
                cx="50"
                cy="50"
                r="50"
              />
            </svg>
            {inputElement}
          </div>
        );
      }}
    </DraggableControl>
  );
};
