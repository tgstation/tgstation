import { Component } from 'react';

const DEFAULT_BLINKING_INTERVAL = 1000;
const DEFAULT_BLINKING_TIME = 1000;

export class Blink extends Component {
  constructor(props) {
    super(props);
    this.state = {
      hidden: false,
    };
  }

  createTimer() {
    const {
      interval = DEFAULT_BLINKING_INTERVAL,
      time = DEFAULT_BLINKING_TIME,
    } = this.props;

    clearInterval(this.interval);
    clearTimeout(this.timer);

    this.setState({
      hidden: false,
    });

    this.interval = setInterval(() => {
      this.setState({
        hidden: true,
      });

      this.timer = setTimeout(() => {
        this.setState({
          hidden: false,
        });
      }, time);
    }, interval + time);
  }

  componentDidMount() {
    this.createTimer();
  }

  componentDidUpdate(prevProps) {
    if (
      prevProps.interval !== this.props.interval ||
      prevProps.time !== this.props.time
    ) {
      this.createTimer();
    }
  }

  componentWillUnmount() {
    clearInterval(this.interval);
    clearTimeout(this.timer);
  }

  render(props) {
    return (
      <span
        style={{
          visibility: this.state.hidden ? 'hidden' : 'visible',
        }}>
        {props.children}
      </span>
    );
  }
}
