import { clamp, toFixed } from 'common/math';
import { Component } from 'inferno';

const FPS = 20;
const Q = 0.5;

export class AnimatedNumber extends Component {
  constructor() {
    super();
    this.timer = null;
    this.state = {
      value: 0,
    };
  }

  tick() {
    const { props, state } = this;
    const currentValue = Number(state.value);
    const targetValue = Number(props.value);
    // Avoid poisoning our state with infinities and NaN
    if (!Number.isFinite(targetValue) || Number.isNaN(targetValue)) {
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
    const currentValue = state.value;
    const targetValue = props.value;
    // Directly display values which can't be animated
    if (typeof targetValue !== 'number'
        || !Number.isFinite(targetValue)
        || Number.isNaN(targetValue)) {
      return targetValue || null;
    }
    // Fix our animated precision at target value's precision.
    const fraction = String(targetValue).split('.')[1];
    const precision = fraction ? fraction.length : 0;
    return toFixed(currentValue, clamp(precision, 0, 8));
  }
}
