import { clamp, toFixed } from 'common/math';
import { Component } from 'inferno';

const FPS = 20;
const Q = 0.5;

const isSafeNumber = value => {
  return typeof value === 'number'
    && Number.isFinite(value)
    && !Number.isNaN(value);
};

export class AnimatedNumber extends Component {
  constructor(props) {
    super(props);
    this.timer = null;
    this.state = {
      value: 0,
    };
    // Use provided initial state
    if (isSafeNumber(props.initial)) {
      this.state.value = props.initial;
    }
    // Set initial state with value provided in props
    else if (isSafeNumber(props.value)) {
      this.state.value = Number(props.value);
    }
  }

  tick() {
    const { props, state } = this;
    const currentValue = Number(state.value);
    const targetValue = Number(props.value);
    // Avoid poisoning our state with infinities and NaN
    if (!isSafeNumber(targetValue)) {
      return;
    }
    // Smooth the value using an exponential moving average
    const value = currentValue * Q + targetValue * (1 - Q);
    this.setState({ value });
  }

  componentDidMount() {
    this.timer = setInterval(() => this.tick(), 1000 / FPS);
  }

  componentWillUnmount() {
    clearTimeout(this.timer);
  }

  render() {
    const { props, state } = this;
    const { format, children } = props;
    const currentValue = state.value;
    const targetValue = props.value;
    // Directly display values which can't be animated
    if (!isSafeNumber(targetValue)) {
      return targetValue || null;
    }
    let formattedValue = currentValue;
    // Use custom formatter
    if (format) {
      formattedValue = format(currentValue);
    }
    // Fix our animated precision at target value's precision.
    else {
      const fraction = String(targetValue).split('.')[1];
      const precision = fraction ? fraction.length : 0;
      formattedValue = toFixed(currentValue, clamp(precision, 0, 8));
    }
    // Use a custom render function
    if (typeof children === 'function') {
      return children(formattedValue, currentValue);
    }
    return formattedValue;
  }
}
