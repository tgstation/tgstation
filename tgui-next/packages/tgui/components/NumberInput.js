import { clamp } from 'common/math';
import { pureComponentHooks } from 'common/react';
import { Component, createRef } from 'inferno';
import { tridentVersion } from '../byond';
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
    };

    this.handleDragStart = e => {
      const { value } = this.props;
      document.body.style['pointer-events'] = 'none';
      this.ref = e.target;
      this.setState({
        dragging: false,
        origin: e.screenY,
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
          state.internalValue = clamp(
            state.internalValue + offset * step / stepPixelSize,
            minValue, maxValue);
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
      if (editing && this.inputRef) {
        this.inputRef.current.focus();
        this.inputRef.current.select();
      }
      else {
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
    } = this.state;
    const {
      value,
      unit,
      minValue,
      maxValue,
      width,
      onChange,
      onDrag,
    } = this.props;
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
                (intermediateValue - minValue) / maxValue * 100,
                0, 100) + '%',
            }} />
        </div>
        <div
          className="NumberInput__content"
          unselectable={tridentVersion <= 4}>
          {dragging ? intermediateValue : value} {unit}
        </div>
        <input
          ref={this.inputRef}
          className="NumberInput__editable"
          style={{
            display: !editing ? 'none' : undefined,
          }}
          value={internalValue}
          onBlur={e => {
            const value = clamp(e.target.value, minValue, maxValue);
            this.setState({
              editing: false,
              value,
            });
            if (onChange) {
              onChange(e, value);
            }
            if (onDrag) {
              onDrag(e, value);
            }
          }}
          onKeyDown={e => {
            if (e.keyCode === 13) {
              this.setState({
                editing: false,
                value: clamp(e.target.value, minValue, maxValue),
              });
            }
            if (e.keyCode === 27) {
              this.setState({
                editing: false,
              });
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
};
