import { Component, Fragment } from 'react';
import { Box } from 'tgui-core/components';

type State = {
  currentIndex: number;
  currentDisplay: string[];
};

export class FakeTerminal extends Component<any, State> {
  timer: ReturnType<typeof setTimeout> | null;

  constructor(props) {
    super(props);
    this.timer = null;
    this.state = {
      currentIndex: 0,
      currentDisplay: [],
    };
  }

  tick() {
    const { props, state } = this;
    if (state.currentIndex <= props.allMessages.length) {
      this.setState((prevState) => {
        return {
          currentIndex: prevState.currentIndex + 1,
        };
      });
      const { currentDisplay } = state;
      currentDisplay.push(props.allMessages[state.currentIndex]);
    } else {
      clearTimeout(this.timer!);
      setTimeout(props.onFinished, props.finishedTimeout);
    }
  }

  componentDidMount() {
    const { linesPerSecond = 2.5 } = this.props;
    this.timer = setInterval(() => this.tick(), 1000 / linesPerSecond);
  }

  componentWillUnmount() {
    clearTimeout(this.timer!);
  }

  render() {
    return (
      <Box m={1}>
        {this.state.currentDisplay.map((value) => (
          <Fragment key={value}>
            {value}
            <br />
          </Fragment>
        ))}
      </Box>
    );
  }
}
