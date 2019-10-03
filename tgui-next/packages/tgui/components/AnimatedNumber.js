import { Component } from 'inferno';
import { fixed } from 'math';

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
    // Avoid poisoning our state with NaN
    // TODO: Same for infinity?
    if (Number.isNaN(props.value)) {
      return;
    }
    // Smooth the value using an exponential moving average
    const value = state.value * Q + props.value * (1 - Q);
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
    if (state.value === null) {
      return null;
    }
    const frac = String(props.value).split('.')[1];
    const precision = frac ? frac.length : 0;
    if (precision === 0) {
      return Math.round(state.value);
    }
    return fixed(state.value, precision);
  }
}
