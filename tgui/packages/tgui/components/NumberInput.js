/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { clamp } from 'common/math';
import { classes, pureComponentHooks } from 'common/react';
import { Component, createRef } from 'inferno';
import { AnimatedNumber } from './AnimatedNumber';
import { Box } from './Box';

const DEFAULT_UPDATE_RATE = 400;

export class NumberInput extends Component {
  constructor(props) {
    super(props);
    const { value } = props;
    this.inputRef = createRef();
    this.state = {
      value,
      dragging: false,
      editing: false,
      internalValue: null,
      origin: null,
      suppressingFlicker: false,
    };

    // Suppresses flickering while the value propagates through the backend
    this.flickerTimer = null;
    this.suppressFlicker = () => {
      const { suppressFlicker } = this.props;
      if (suppressFlicker > 0) {
        this.setState({
          suppressingFlicker: true,
        });
        clearTimeout(this.flickerTimer);
        this.flickerTimer = setTimeout(
          () =>
            this.setState({
              suppressingFlicker: false,
            }),
          suppressFlicker
        );
      }
    };

    this.handleDragStart = (e) => {
      const { value } = this.props;
      const { editing } = this.state;
      if (editing) {
        return;
      }
      document.body.style['pointer-events'] = 'none';
      this.ref = e.target;
      this.setState({
        dragging: false,
        origin: e.screenY,
        value,
        internalValue: value,
      });
      this.timer = setTimeout(() => {
        this.setState({
          dragging: true,
        });
      }, 250);
      this.dragInterval = setInterval(() => {
        const { dragging, value } = this.state;
        const { onDrag } = this.props;
        if (dragging && onDrag) {
          onDrag(e, value);
        }
      }, this.props.updateRate || DEFAULT_UPDATE_RATE);
      document.addEventListener('mousemove', this.handleDragMove);
      document.addEventListener('mouseup', this.handleDragEnd);
    };

    this.handleDragMove = (e) => {
      const { minValue, maxValue, step, stepPixelSize } = this.props;
      this.setState((prevState) => {
        const state = { ...prevState };
        const offset = state.origin - e.screenY;
        if (prevState.dragging) {
          const stepOffset = Number.isFinite(minValue) ? minValue % step : 0;
          // Translate mouse movement to value
          // Give it some headroom (by increasing clamp range by 1 step)
          state.internalValue = clamp(
            state.internalValue + (offset * step) / stepPixelSize,
            minValue - step,
            maxValue + step
          );
          // Clamp the final value
          state.value = clamp(
            state.internalValue - (state.internalValue % step) + stepOffset,
            minValue,
            maxValue
          );
          state.origin = e.screenY;
        } else if (Math.abs(offset) > 4) {
          state.dragging = true;
        }
        return state;
      });
    };

    this.handleDragEnd = (e) => {
      const { onChange, onDrag } = this.props;
      const { dragging, value, internalValue } = this.state;
      document.body.style['pointer-events'] = 'auto';
      clearTimeout(this.timer);
      clearInterval(this.dragInterval);
      this.setState({
        dragging: false,
        editing: !dragging,
        origin: null,
      });
      document.removeEventListener('mousemove', this.handleDragMove);
      document.removeEventListener('mouseup', this.handleDragEnd);
      if (dragging) {
        this.suppressFlicker();
        if (onChange) {
          onChange(e, value);
        }
        if (onDrag) {
          onDrag(e, value);
        }
      } else if (this.inputRef) {
        const input = this.inputRef.current;
        input.value = internalValue;
        // IE8: Dies when trying to focus a hidden element
        // (Error: Object does not support this action)
        try {
          input.focus();
          input.select();
        } catch {}
      }
    };
  }

  render() {
    const {
      dragging,
      editing,
      value: intermediateValue,
      suppressingFlicker,
    } = this.state;
    const {
      className,
      fluid,
      animated,
      value,
      unit,
      minValue,
      maxValue,
      height,
      width,
      lineHeight,
      fontSize,
      format,
      onChange,
      onDrag,
    } = this.props;
    let displayValue = value;
    if (dragging || suppressingFlicker) {
      displayValue = intermediateValue;
    }

    // prettier-ignore
    const contentElement = (
      <div className="NumberInput__content" unselectable={Byond.IS_LTE_IE8}>
        {
          (animated && !dragging && !suppressingFlicker) ?
            (<AnimatedNumber value={displayValue} format={format} />) :
            (format ? format(displayValue) : displayValue)
        }

        {unit ? ' ' + unit : ''}
      </div>
    );

    return (
      <Box
        className={classes([
          'NumberInput',
          fluid && 'NumberInput--fluid',
          className,
        ])}
        minWidth={width}
        minHeight={height}
        lineHeight={lineHeight}
        fontSize={fontSize}
        onMouseDown={this.handleDragStart}>
        <div className="NumberInput__barContainer">
          <div
            className="NumberInput__bar"
            style={{
              // prettier-ignore
              height: clamp(
                (displayValue - minValue) / (maxValue - minValue) * 100,
                0, 100) + '%',
            }}
          />
        </div>
        {contentElement}
        <input
          ref={this.inputRef}
          className="NumberInput__input"
          style={{
            display: !editing ? 'none' : undefined,
            height: height,
            'line-height': lineHeight,
            'font-size': fontSize,
          }}
          onBlur={(e) => {
            if (!editing) {
              return;
            }
            const value = clamp(parseFloat(e.target.value), minValue, maxValue);
            if (Number.isNaN(value)) {
              this.setState({
                editing: false,
              });
              return;
            }
            this.setState({
              editing: false,
              value,
            });
            this.suppressFlicker();
            if (onChange) {
              onChange(e, value);
            }
            if (onDrag) {
              onDrag(e, value);
            }
          }}
          onKeyDown={(e) => {
            if (e.keyCode === 13) {
              // prettier-ignore
              const value = clamp(
                parseFloat(e.target.value),
                minValue,
                maxValue
              );
              if (Number.isNaN(value)) {
                this.setState({
                  editing: false,
                });
                return;
              }
              this.setState({
                editing: false,
                value,
              });
              this.suppressFlicker();
              if (onChange) {
                onChange(e, value);
              }
              if (onDrag) {
                onDrag(e, value);
              }
              return;
            }
            if (e.keyCode === 27) {
              this.setState({
                editing: false,
              });
              return;
            }
          }}
        />
      </Box>
    );
  }
}

NumberInput.defaultHooks = pureComponentHooks;
NumberInput.defaultProps = {
  minValue: -Infinity,
  maxValue: +Infinity,
  step: 1,
  stepPixelSize: 1,
  suppressFlicker: 50,
};
