import { formatTime } from '../format';
import { Component } from 'inferno';

// AnimatedNumber Copypaste
const isSafeNumber = value => {
  return typeof value === 'number'
    && Number.isFinite(value)
    && !Number.isNaN(value);
};

export class TimeDisplay extends Component {
  constructor(props) {
    super(props);
    this.timer = null;
    this.last_seen_value = undefined;
    this.state = {
      value: 0,
    };
    // Set initial state with value provided in props
    if (isSafeNumber(props.value)) {
      this.state.value = Number(props.value);
      this.last_seen_value = Number(props.value);
    }
  }

  componentDidUpdate() {
    if (this.props.auto !== undefined) {
      clearInterval(this.timer);
      this.timer = setInterval(() => this.tick(), 1000); // every 1 s
    }
  }

  tick() {
    let current = Number(this.state.value);
    if (this.props.value !== this.last_seen_value) {
      this.last_seen_value = this.props.value;
      current = this.props.value;
    }
    const mod = this.props.auto === "up" ? 10 : -10; // Time down by default.
    const value = Math.max(0, current + mod); // one sec tick
    this.setState({ value });
  }

  componentDidMount() {
    if (this.props.auto !== undefined) {
      this.timer = setInterval(() => this.tick(), 1000); // every 1 s
    }
  }

  componentWillUnmount() {
    clearInterval(this.timer);
  }

  render() {
    const val = this.state.value;
    // Directly display weird stuff
    if (!isSafeNumber(val)) {
      return this.state.value || null;
    }

    return formatTime(val);
  }
}
