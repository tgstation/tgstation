import { clamp } from 'common/math';
import { pureComponentHooks } from 'common/react';
import { Component, createRef } from 'inferno';
import { tridentVersion } from '../byond';
import { AnimatedNumber } from './AnimatedNumber';
import { Box } from './Box';

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
    this.suppressFlicker = () => {
      const { suppressFlicker } = this.props;
      if (suppressFlicker > 0) {
        this.setState({
          suppressingFlicker: true,
        });
        setTimeout(() => this.setState({
          suppressingFlicker: false,
        }), suppressFlicker);
      }
    };

    this.handleDragStart = e => {
      const { value } = this.props;
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
      }, 500);
      document.addEventListener('mousemove', this.handleDragMove);
      document.addEventListener('mouseup', this.handleDragEnd);
    };

    this.handleDragMove = e => {
      const { minValue, maxValue, step, stepPixelSize } = this.props;
      this.setState(prevState => {
        const state = { ...prevState };
        const offset = state.origin - e.screenY;
        if (prevState.dragging) {
          // Translate mouse movement to value
          // Give it some headroom (by increasing clamp range by 1 step)
          state.internalValue = clamp(
            state.internalValue + offset * step / stepPixelSize,
            minValue - step, maxValue + step);
          // Clamp the final value
          state.value = clamp(
            state.internalValue - state.internalValue % step,
            minValue, maxValue);
          state.origin = e.screenY;
        }
        else if (Math.abs(offset) > 4) {
          state.dragging = true;
        }
        return state;
      });
    };

    this.handleDragEnd = e => {
      const { onChange, onDrag } = this.props;
      const { dragging, value } = this.state;
      document.body.style['pointer-events'] = 'auto';
      clearTimeout(this.timer);
      clearInterval(this.dragInterval);
      const editing = !dragging;
      this.setState({
        dragging: false,
        editing,
        origin: null,
      });
      if (editing) {
        if (this.inputRef) {
          this.inputRef.current.focus();
          this.inputRef.current.select();
        }
      }
      else {
        this.suppressFlicker();
        if (onChange) {
          onChange(e, value);
        }
        if (onDrag) {
          onDrag(e, value);
        }
      }
      document.removeEventListener('mousemove', this.handleDragMove);
      document.removeEventListener('mouseup', this.handleDragEnd);
    };
  }

  render() {
    const {
      dragging,
      editing,
      value: intermediateValue,
      internalValue,
      suppressingFlicker,
    } = this.state;
    const {
      animated,
      value,
      unit,
      minValue,
      maxValue,
      width,
      format,
      onChange,
      onDrag,
    } = this.props;
    let displayValue = value;
    if (dragging || suppressingFlicker) {
      displayValue = intermediateValue;
    }
    const renderContentElement = value => (
      <div
        className="NumberInput__content"
        unselectable={tridentVersion <= 4}>
        {value + (unit ? ' ' + unit : '')}
      </div>
    );
    const contentElement = (animated && !dragging && !suppressingFlicker && (
      <AnimatedNumber
        value={displayValue}
        format={format}>
        {renderContentElement}
      </AnimatedNumber>
    ) || (
      renderContentElement(format ? format(displayValue) : displayValue)
    ));
    return (
      <Box
        className="NumberInput"
        minWidth={width}
        onMouseDown={this.handleDragStart}>
        <div className="NumberInput__barContainer">
          <div
            className="NumberInput__bar"
            style={{
              height: clamp(
                (displayValue - minValue) / (maxValue - minValue) * 100,
                0, 100) + '%',
            }} />
        </div>
        {contentElement}
        <input
          ref={this.inputRef}
          className="NumberInput__editable"
          style={{
            display: !editing ? 'none' : undefined,
          }}
          value={internalValue}
          onBlur={e => {
            if (!editing) {
              return;
            }
            const value = clamp(e.target.value, minValue, maxValue);
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
          onKeyDown={e => {
            if (e.keyCode === 13) {
              const value = clamp(e.target.value, minValue, maxValue);
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
          onInput={e => this.setState({
            internalValue: e.target.value,
          })} />
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
