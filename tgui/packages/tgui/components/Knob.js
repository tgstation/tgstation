/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { keyOfMatchingRange, scale } from 'common/math';
import { classes } from 'common/react';
import { computeBoxClassName, computeBoxProps } from './Box';
import { DraggableControl } from './DraggableControl';
import { NumberInput } from './NumberInput';

export const Knob = props => {
  // IE8: I don't want to support a yet another component on IE8.
  // IE8: It also can't handle SVG.
  if (Byond.IS_LTE_IE8) {
    return (
      <NumberInput {...props} />
    );
  }
  const {
    // Draggable props (passthrough)
    animated,
    format,
    maxValue,
    minValue,
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
    size,
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
        onChange,
        onDrag,
        step,
        stepPixelSize,
        suppressFlicker,
        unit,
        value,
      }}>
      {control => {
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
          maxValue);
        const scaledDisplayValue = scale(
          displayValue,
          minValue,
          maxValue);
        const effectiveColor = color
          || keyOfMatchingRange(fillValue ?? value, ranges)
          || 'default';
        const rotation = (scaledDisplayValue - 0.5) * 270;
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
                'font-size': size + 'rem',
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
              <div className="Knob__popupValue">
                {displayElement}
              </div>
            )}
            <svg
              className="Knob__ring Knob__ringTrackPivot"
              viewBox="0 0 100 100">
              <circle
                className="Knob__ringTrack"
                cx="50"
                cy="50"
                r="50" />
            </svg>
            <svg
              className="Knob__ring Knob__ringFillPivot"
              viewBox="0 0 100 100">
              <circle
                className="Knob__ringFill"
                style={{
                  'stroke-dashoffset': (
                    ((bipolar ? 2.75 : 2.00) - scaledFillValue * 1.5)
                      * Math.PI * 50
                  ),
                }}
                cx="50"
                cy="50"
                r="50" />
            </svg>
            {inputElement}
          </div>
        );
      }}
    </DraggableControl>
  );
};
