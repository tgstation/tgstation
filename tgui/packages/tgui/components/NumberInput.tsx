import { isEscape, KEY } from 'common/keys';
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

type Props = Required<{
  value: number | string;
  minValue: number;
  maxValue: number;
  step: number;
}> &
  Partial<{
    stepPixelSize: number;
    disabled: BooleanLike;

    className: string;
    fluid: BooleanLike;
    animated: BooleanLike;
    unit: string;
    height: string;
    width: string;
    lineHeight: string;
    fontSize: string;
    format: (value: number) => string;
    onChange: (value: number) => void;
    onDrag: (value: number) => void;
  }>;

type State = {
  editing: BooleanLike;
  dragging: BooleanLike;
  currentValue: number;
  previousValue: number;
  origin: number;
};

export class NumberInput extends Component<Props, State> {
  // Ref to the input field to set focus & highlight
  inputRef: RefObject<HTMLInputElement> = createRef();

  // After this time has elapsed we are in drag mode so no editing when dragging ends
  dragTimeout: NodeJS.Timeout;

  // Call onDrag at this interval
  dragInterval: NodeJS.Timeout;

  // default values for the number input state
  state: State = {
    editing: false,
    dragging: false,
    currentValue: 0,
    previousValue: 0,
    origin: 0,
  };

  constructor(props: Props) {
    super(props);
  }

  componentDidMount(): void {
    let displayValue = parseFloat(this.props.value.toString());

    this.setState({
      currentValue: displayValue,
      previousValue: displayValue,
    });
  }

  handleDragStart: MouseEventHandler<HTMLDivElement> = (event) => {
    const { value, disabled } = this.props;
    const { editing } = this.state;
    if (disabled || editing) {
      return;
    }
    document.body.style['pointer-events'] = 'none';

    const parsedValue = parseFloat(value.toString());
    this.setState({
      dragging: false,
      origin: event.screenY,
      currentValue: parsedValue,
      previousValue: parsedValue,
    });

    this.dragTimeout = setTimeout(() => {
      this.setState({
        dragging: true,
      });
    }, 250);
    this.dragInterval = setInterval(() => {
      const { dragging, currentValue, previousValue } = this.state;
      const { onDrag } = this.props;
      if (dragging && currentValue !== previousValue) {
        this.setState({
          previousValue: currentValue,
        });
        onDrag?.(currentValue);
      }
    }, 400);

    document.addEventListener('mousemove', this.handleDragMove);
    document.addEventListener('mouseup', this.handleDragEnd);
  };

  handleDragMove = (event: MouseEvent) => {
    const { minValue, maxValue, step, stepPixelSize, disabled } = this.props;
    if (disabled) {
      return;
    }

    this.setState((prevState) => {
      const state = { ...prevState };

      const offset = state.origin - event.screenY;
      if (prevState.dragging) {
        const stepOffset = isFinite(minValue) ? minValue % step : 0;
        // Translate mouse movement to value
        // Give it some headroom (by increasing clamp range by 1 step)
        state.currentValue = clamp(
          state.currentValue + (offset * step) / (stepPixelSize || 1),
          minValue - step,
          maxValue + step,
        );
        // Clamp the final value
        state.currentValue = clamp(
          state.currentValue - (state.currentValue % step) + stepOffset,
          minValue,
          maxValue,
        );
        // Set the new origin
        state.origin = event.screenY;
      } else if (Math.abs(offset) > 4) {
        state.dragging = true;
      }
      return state;
    });
  };

  handleDragEnd = (event: MouseEvent) => {
    const { dragging, currentValue } = this.state;
    const { onDrag, onChange, disabled } = this.props;
    if (disabled) {
      return;
    }
    document.body.style['pointer-events'] = 'auto';

    clearInterval(this.dragInterval);
    clearTimeout(this.dragTimeout);

    this.setState({
      dragging: false,
      editing: !dragging,
      previousValue: currentValue,
    });
    if (dragging) {
      onChange?.(currentValue);
      onDrag?.(currentValue);
    } else if (this.inputRef) {
      const input = this.inputRef.current;
      if (input) {
        input.value = `${currentValue}`;
        setTimeout(() => {
          input.focus();
          input.select();
        }, 1);
      }
    }

    document.removeEventListener('mousemove', this.handleDragMove);
    document.removeEventListener('mouseup', this.handleDragEnd);
  };

  handleBlur: FocusEventHandler<HTMLInputElement> = (event) => {
    const { editing, previousValue } = this.state;
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
      currentValue: targetValue,
      previousValue: targetValue,
    });
    if (previousValue !== targetValue) {
      onChange?.(targetValue);
      onDrag?.(targetValue);
    }
  };

  handleKeyDown: KeyboardEventHandler<HTMLInputElement> = (event) => {
    const { minValue, maxValue, onChange, onDrag, disabled } = this.props;
    if (disabled) {
      return;
    }
    const { previousValue } = this.state;

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
        currentValue: targetValue,
        previousValue: targetValue,
      });
      if (previousValue !== targetValue) {
        onChange?.(targetValue);
        onDrag?.(targetValue);
      }
    } else if (isEscape(event.key)) {
      this.setState({
        editing: false,
      });
    }
  };

  render() {
    const { dragging, editing, currentValue } = this.state;

    const {
      className,
      fluid,
      animated,
      unit,
      value,
      minValue,
      maxValue,
      height,
      width,
      lineHeight,
      fontSize,
      format,
    } = this.props;

    let displayValue = parseFloat(value.toString());
    if (dragging) {
      displayValue = currentValue;
    }

    const contentElement = (
      <div className="NumberInput__content">
        {animated && !dragging ? (
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
