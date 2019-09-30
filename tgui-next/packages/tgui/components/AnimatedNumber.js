import { Component } from 'inferno';

const FPS = 30;
const Q = 0.6;

export class AnimatedNumber extends Component {
  constructor() {
    super();
    this.timer = null;
    this.state = {
      value: 0,
    };
  }

  tick() {
    // Smooth the value using an exponential moving average
    const value = this.state.value * Q
      + this.props.value * (1 - Q);
    this.setState({ value });
  }

  componentDidMount() {
    this.timer = setInterval(() => this.tick(), 1000 / FPS);
  }

  componentWillUnmount() {
    clearTimeout(this.timer);
  }

  render() {
    const { format } = this.props;
    if (this.state.value === null) {
      return null;
    }
    if (format) {
      return format(this.state.value);
    }
    return this.state.value;
  }
}
