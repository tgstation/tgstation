import { KEY } from 'common/keys';
import { clamp } from 'common/math';
import { BooleanLike, classes } from 'common/react';
import {
  Component,
  createRef,
  FocusEventHandler,
  KeyboardEventHandler,
  MouseEventHandler,
  RefObject,
} from 'react';

import { AnimatedNumber } from './AnimatedNumber';
import { Box } from './Box';

const DEFAULT_UPDATE_RATE = 400;

type Props = Required<{
  value: number | string;
  minValue: number;
  maxValue: number;
}> &
  Partial<{
    step: number;
    stepPixelSize: number;
    suppressFlicker: number;
    disabled: BooleanLike;

    className: string;
    fluid: BooleanLike;
    animated: BooleanLike;
    unit: string;
    height: string;
    width: string;
    lineHeight: string;
    fontSize: string;
    updateRate: number;
    format: (value: number) => string;
    onChange: (e: any, value: number) => void;
    onDrag: (e: any, value: number) => void;
  }>;

type State = {
  value: number;
  dragging: BooleanLike;
  editing: BooleanLike;
  internalValue: number;
  origin: number;
  suppressingFlicker: BooleanLike;
};

export class NumberInput extends Component<Props, State> {
  // Ref to the input field to set focus & highlight
  inputRef: RefObject<HTMLInputElement> = createRef();

  // Timer id for the flicker id
  flickerTimer: NodeJS.Timeout;

  // After this time has elapsed we are in drag mode so no editing when dragging ends
  dragTimeout: NodeJS.Timeout;

  // Call onDrag at this interval
  dragInterval: NodeJS.Timeout;

  // default values for the number input state
  state: State = {
    value: 0,
    dragging: false,
    editing: false,
    internalValue: 0,
    origin: 0,
    suppressingFlicker: false,
  };

  // default values for the number input props
  static defaultProps = {
    step: 1,
    stepPixelSize: 1,
    suppressFlicker: 50,
  };

  constructor(props: Props) {
    super(props);
  }

  suppressFlicker = () => {
    const { suppressFlicker } = this.props;
    if (suppressFlicker) {
      this.setState({
        suppressingFlicker: true,
      });
      clearTimeout(this.flickerTimer);
      this.flickerTimer = setTimeout(
        () =>
          this.setState({
            suppressingFlicker: false,
          }),
        suppressFlicker,
      );
    }
  };

  handleDragStart: MouseEventHandler<HTMLDivElement> = (event) => {
    const { value, updateRate, disabled } = this.props;
    const { editing } = this.state;
    if (disabled || editing) {
      return;
    }
    this.setState({
      dragging: false,
      origin: event.screenY,
      internalValue: parseFloat(value.toString()),
    });
    this.dragTimeout = setTimeout(() => {
      this.setState({
        dragging: true,
      });
    }, 250);

    this.dragInterval = setInterval(() => {
      const { dragging, value } = this.state;
      const { onDrag } = this.props;
      if (dragging) {
        onDrag?.(event, value);
      }
    }, updateRate || DEFAULT_UPDATE_RATE);
  };

  handleDragMove: MouseEventHandler<HTMLDivElement> = (event) => {
    const { minValue, maxValue, step, stepPixelSize, disabled } = this.props;
    const { dragging } = this.state;
    if (disabled || !dragging) {
      return;
    }

    this.setState((prevState) => {
      const state = { ...prevState };
      const offset = state.origin - event.screenY;
      if (prevState.dragging && step) {
        const stepOffset = isFinite(minValue) ? minValue % step : 0;
        // Translate mouse movement to value
        // Give it some headroom (by increasing clamp range by 1 step)
        state.internalValue = clamp(
          state.internalValue + (offset * step) / (stepPixelSize || 1),
          minValue - step,
          maxValue + step,
        );
        // Clamp the final value
        state.value = clamp(
          state.internalValue - (state.internalValue % step) + stepOffset,
          minValue,
          maxValue,
        );
        state.origin = event.screenY;
      } else if (Math.abs(offset) > 4) {
        state.dragging = true;
      }
      return state;
    });
  };

  handleDragEnd: MouseEventHandler<HTMLInputElement> = (event) => {
    const { value, dragging, internalValue } = this.state;
    const { onDrag, onChange, disabled } = this.props;
    if (disabled) {
      return;
    }

    clearInterval(this.dragInterval);
    clearTimeout(this.dragTimeout);
    this.setState({
      dragging: false,
      editing: !dragging,
    });

    if (dragging) {
      this.suppressFlicker();
      onChange?.(event, value);
      onDrag?.(event, value);
    } else if (this.inputRef) {
      const input = this.inputRef.current;
      if (input) {
        input.value = `${internalValue}`;
        setTimeout(() => {
          input.focus();
          input.select();
        }, 1);
      }
    }
  };

  handleBlur: FocusEventHandler<HTMLInputElement> = (event) => {
    const { editing } = this.state;
    const { minValue, maxValue, onChange, onDrag, disabled } = this.props;

    if (disabled || !editing) {
      return;
    }

    const targetValue = clamp(
      parseFloat(event.target.value),
      minValue,
      maxValue,
    );
    if (isNaN(targetValue)) {
      this.setState({
        editing: false,
      });
      return;
    }
    this.setState({
      editing: false,
    });
    this.suppressFlicker();
    onChange?.(event, targetValue);
    onDrag?.(event, targetValue);
  };

  handleKeyDown: KeyboardEventHandler<HTMLInputElement> = (event) => {
    const { minValue, maxValue, onChange, onDrag, disabled } = this.props;
    if (disabled) {
      return;
    }

    if (event.key === KEY.Enter) {
      const targetValue = clamp(
        parseFloat(event.currentTarget.value),
        minValue,
        maxValue,
      );
      if (isNaN(targetValue)) {
        this.setState({
          editing: false,
        });
        return;
      }
      this.setState({
        editing: false,
        value: targetValue,
      });
      this.suppressFlicker();
      onChange?.(event, targetValue);
      onDrag?.(event, targetValue);
    } else if (event.key === KEY.Escape) {
      this.setState({
        editing: false,
      });
    }
  };

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
    } = this.props;

    let displayValue = parseFloat(value.toString());
    if (dragging || suppressingFlicker) {
      displayValue = intermediateValue;
    }

    const contentElement = (
      <div className="NumberInput__content">
        {animated && !dragging && !suppressingFlicker ? (
          <AnimatedNumber value={displayValue} format={format} />
        ) : format ? (
          format(displayValue)
        ) : (
          displayValue
        )}

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
        onMouseDown={this.handleDragStart}
        onMouseMove={this.handleDragMove}
        onMouseUp={this.handleDragEnd}
      >
        <div className="NumberInput__barContainer">
          <div
            className="NumberInput__bar"
            style={{
              height:
                clamp(
                  ((displayValue - minValue) / (maxValue - minValue)) * 100,
                  0,
                  100,
                ) + '%',
            }}
          />
        </div>
        {contentElement}
        <input
          ref={this.inputRef}
          className="NumberInput__input"
          style={{
            display: !editing ? 'none' : 'inline',
            height: height,
            lineHeight: lineHeight,
            fontSize: fontSize,
          }}
          onBlur={this.handleBlur}
          onKeyDown={this.handleKeyDown}
        />
      </Box>
    );
  }
}
